import {
  ConflictException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { ApiCode } from '../common/api-code.js';
import { InvoiceService } from './invoice.service.js';

const accountsUser = {
  userId: 'acct-1',
  role: 'accounts_admin',
  branchId: 'branch-1',
};

describe('InvoiceService.generateForAccount', () => {
  it('creates a DRAFT invoice, lines, and stamps bookings', async () => {
    const bookings = [
      {
        id: 'b1',
        corporateAccountId: 'ca-1',
        finalSubtotalCents: 2000,
        finalTaxCents: 100,
        finalFareCents: 2100,
      },
      {
        id: 'b2',
        corporateAccountId: 'ca-1',
        finalSubtotalCents: 1000,
        finalTaxCents: 50,
        finalFareCents: 1050,
      },
    ];
    const invoice = {
      id: 'inv-1',
      number: 'INV-2026-0001',
      branchId: 'branch-1',
      corporateAccountId: 'ca-1',
      groupId: null,
      periodStart: new Date('2026-09-01T00:00:00.000Z'),
      periodEnd: new Date('2026-10-01T00:00:00.000Z'),
      subtotalCents: 3000,
      taxCents: 150,
      totalCents: 3150,
      paidCents: 0,
      status: 'DRAFT',
      dueAt: null,
      generatedById: 'acct-1',
      createdAt: new Date(),
    };
    const tx = {
      corporateAccount: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'ca-1',
          branchId: 'branch-1',
        })),
      },
      booking: {
        findMany: vi.fn(async () => bookings),
        updateMany: vi.fn(async () => ({ count: 2 })),
      },
      invoice: {
        create: vi.fn(async ({ data }) => ({ id: 'inv-1', ...data })),
      },
      invoiceLine: {
        createMany: vi.fn(async () => ({ count: 2 })),
      },
      $queryRaw: vi.fn(async () => [{ invoiceSeq: 1 }]),
    };
    const prisma = {
      $transaction: vi.fn(async (fn: (client: typeof tx) => unknown) =>
        fn(tx),
      ),
      invoice: {
        findUniqueOrThrow: vi.fn(async () => ({
          ...invoice,
          corporateAccount: { id: 'ca-1', name: 'Acme' },
          group: null,
          lines: [
            {
              id: 'l1',
              bookingId: 'b1',
              corporateAccountId: 'ca-1',
              corporateAccount: { id: 'ca-1', name: 'Acme' },
              subtotalCents: 2000,
              taxCents: 100,
              totalCents: 2100,
              booking: {
                id: 'b1',
                trackingId: 'BC-1',
                completedAt: new Date(),
                passengerName: 'Pat',
              },
            },
          ],
        })),
      },
    };
    const service = new InvoiceService(
      prisma as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    )

    const result = await service.generateForAccount(
      'ca-1',
      new Date('2026-09-01T00:00:00.000Z'),
      new Date('2026-10-01T00:00:00.000Z'),
      'acct-1',
      accountsUser,
    );

    expect(result.status).toBe('DRAFT');
    expect(result.number).toBe('INV-2026-0001');
    expect(tx.invoice.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        subtotalCents: 3000,
        taxCents: 150,
        totalCents: 3150,
        corporateAccountId: 'ca-1',
        status: 'DRAFT',
      }),
    });
    expect(tx.invoiceLine.createMany).toHaveBeenCalledWith({
      data: expect.arrayContaining([
        expect.objectContaining({ bookingId: 'b1', corporateAccountId: 'ca-1' }),
        expect.objectContaining({ bookingId: 'b2' }),
      ]),
    });
    expect(tx.booking.updateMany).toHaveBeenCalledWith({
      where: { id: { in: ['b1', 'b2'] } },
      data: expect.objectContaining({ invoiceId: 'inv-1' }),
    });
  });

  it('returns NO_BILLABLE_BOOKINGS when none match', async () => {
    const tx = {
      corporateAccount: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'ca-1',
          branchId: 'branch-1',
        })),
      },
      booking: { findMany: vi.fn(async () => []) },
    };
    const service = new InvoiceService(
      {
        $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      } as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    )
    await expect(
      service.generateForAccount(
        'ca-1',
        new Date('2026-09-01T00:00:00.000Z'),
        new Date('2026-10-01T00:00:00.000Z'),
        'acct-1',
        accountsUser,
      ),
    ).rejects.toMatchObject({
      response: { code: 'NO_BILLABLE_BOOKINGS' },
    });
    await expect(
      service.generateForAccount(
        'ca-1',
        new Date('2026-09-01T00:00:00.000Z'),
        new Date('2026-10-01T00:00:00.000Z'),
        'acct-1',
        accountsUser,
      ),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
  });
});

describe('InvoiceService.generateForGroup', () => {
  it('builds one invoice with null corporateAccountId and per-line accounts', async () => {
    const tx = {
      corporateAccountGroup: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'g-1',
          accounts: [
            { id: 'ca-1', branchId: 'branch-1' },
            { id: 'ca-2', branchId: 'branch-1' },
          ],
        })),
      },
      booking: {
        findMany: vi.fn(async () => [
          {
            id: 'b1',
            corporateAccountId: 'ca-1',
            finalSubtotalCents: 1000,
            finalTaxCents: 50,
            finalFareCents: 1050,
          },
          {
            id: 'b2',
            corporateAccountId: 'ca-2',
            finalSubtotalCents: 2000,
            finalTaxCents: 100,
            finalFareCents: 2100,
          },
        ]),
        updateMany: vi.fn(async () => ({ count: 2 })),
      },
      invoice: {
        create: vi.fn(async ({ data }) => ({ id: 'inv-g', ...data })),
      },
      invoiceLine: { createMany: vi.fn(async () => ({ count: 2 })) },
      $queryRaw: vi.fn(async () => [{ invoiceSeq: 2 }]),
    };
    const prisma = {
      $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      invoice: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'inv-g',
          number: 'INV-2026-0002',
          branchId: 'branch-1',
          corporateAccountId: null,
          groupId: 'g-1',
          periodStart: new Date(),
          periodEnd: new Date(),
          subtotalCents: 3000,
          taxCents: 150,
          totalCents: 3150,
          paidCents: 0,
          status: 'DRAFT',
          dueAt: null,
          generatedById: 'acct-1',
          createdAt: new Date(),
          corporateAccount: null,
          group: { id: 'g-1', name: 'West' },
          lines: [],
        })),
      },
    };
    const service = new InvoiceService(
      prisma as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    )
    const result = await service.generateForGroup(
      'g-1',
      new Date('2026-09-01T00:00:00.000Z'),
      new Date('2026-10-01T00:00:00.000Z'),
      'acct-1',
      { userId: 'sa', role: 'super_admin', branchId: null },
    );
    expect(result.corporateAccountId).toBeNull();
    expect(result.groupId).toBe('g-1');
    expect(tx.invoice.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        groupId: 'g-1',
        corporateAccountId: null,
      }),
    });
    expect(tx.invoiceLine.createMany).toHaveBeenCalledWith({
      data: expect.arrayContaining([
        expect.objectContaining({ corporateAccountId: 'ca-1' }),
        expect.objectContaining({ corporateAccountId: 'ca-2' }),
      ]),
    });
  });
});

describe('InvoiceService.send / void / sweepOverdue', () => {
  it('sets SENT and dueAt from INVOICE_DUE_DAYS', async () => {
    const prisma = {
      invoice: {
        findUnique: vi.fn(async () => ({
          id: 'inv-1',
          branchId: 'branch-1',
          status: 'DRAFT',
        })),
        update: vi.fn(async ({ data }) => data),
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'inv-1',
          number: 'INV-2026-0001',
          branchId: 'branch-1',
          corporateAccountId: 'ca-1',
          groupId: null,
          periodStart: new Date(),
          periodEnd: new Date(),
          subtotalCents: 100,
          taxCents: 5,
          totalCents: 105,
          paidCents: 0,
          status: 'SENT',
          dueAt: new Date('2026-11-03T00:00:00.000Z'),
          generatedById: 'acct-1',
          createdAt: new Date(),
          corporateAccount: null,
          group: null,
          lines: [],
        })),
      },
    };
    const service = new InvoiceService(
      prisma as never,
      { get: (k: string) => (k === 'INVOICE_DUE_DAYS' ? '30' : undefined) } as never,
      { post: vi.fn() } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    )
    const result = await service.send(accountsUser, 'inv-1');
    expect(result.status).toBe('SENT');
    expect(prisma.invoice.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({ status: 'SENT' }),
      }),
    );
  });

  it('voids DRAFT and clears booking invoice stamps', async () => {
    const tx = {
      booking: { updateMany: vi.fn(async () => ({ count: 2 })) },
      invoiceLine: { deleteMany: vi.fn(async () => ({ count: 2 })) },
      invoice: {
        update: vi.fn(async () => ({ status: 'VOID' })),
      },
    };
    const prisma = {
      invoice: {
        findUnique: vi.fn(async () => ({
          id: 'inv-1',
          branchId: 'branch-1',
          status: 'DRAFT',
        })),
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'inv-1',
          number: 'INV-2026-0001',
          branchId: 'branch-1',
          corporateAccountId: 'ca-1',
          groupId: null,
          periodStart: new Date(),
          periodEnd: new Date(),
          subtotalCents: 0,
          taxCents: 0,
          totalCents: 0,
          paidCents: 0,
          status: 'VOID',
          dueAt: null,
          generatedById: 'acct-1',
          createdAt: new Date(),
          corporateAccount: null,
          group: null,
          lines: [],
        })),
      },
      $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
    };
    const service = new InvoiceService(
      prisma as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    )
    await expect(service.void(accountsUser, 'inv-1')).resolves.toMatchObject({
      status: 'VOID',
    });
    expect(tx.booking.updateMany).toHaveBeenCalledWith({
      where: { invoiceId: 'inv-1' },
      data: { invoicedAt: null, invoiceId: null },
    });
    expect(tx.invoiceLine.deleteMany).toHaveBeenCalled();
  });

  it('rejects voiding a non-DRAFT invoice', async () => {
    const service = new InvoiceService(
      {
        invoice: {
          findUnique: vi.fn(async () => ({
            id: 'inv-1',
            branchId: 'branch-1',
            status: 'SENT',
          })),
        },
      } as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    )
    await expect(service.void(accountsUser, 'inv-1')).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('marks past-due SENT invoices OVERDUE', async () => {
    const prisma = {
      invoice: {
        updateMany: vi.fn(async () => ({ count: 3 })),
      },
    };
    const service = new InvoiceService(
      prisma as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    )
    await expect(service.sweepOverdue()).resolves.toEqual({ updated: 3 });
    expect(prisma.invoice.updateMany).toHaveBeenCalledWith({
      where: {
        status: { in: ['SENT', 'PARTIALLY_PAID'] },
        dueAt: { lt: expect.any(Date) },
      },
      data: { status: 'OVERDUE' },
    });
  });
});

describe('InvoiceService.recordPayment', () => {
  const detail = {
    id: 'inv-1',
    number: 'INV-2026-0001',
    branchId: 'branch-1',
    corporateAccountId: 'ca-1',
    groupId: null,
    periodStart: new Date(),
    periodEnd: new Date(),
    subtotalCents: 3000,
    taxCents: 150,
    totalCents: 3150,
    paidCents: 1000,
    status: 'PARTIALLY_PAID',
    dueAt: null,
    generatedById: 'acct-1',
    createdAt: new Date(),
    corporateAccount: { id: 'ca-1', name: 'Acme' },
    group: null,
    lines: [],
  };

  it('posts AR→BANK_CLEARING and marks PARTIALLY_PAID', async () => {
    const post = vi.fn(async () => ({ id: 'txn-1' }));
    const tx = {
      invoice: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'inv-1',
          number: 'INV-2026-0001',
          branchId: 'branch-1',
          corporateAccountId: 'ca-1',
          paidCents: 0,
          totalCents: 3150,
          status: 'SENT',
        })),
        update: vi.fn(async ({ data }) => data),
      },
      auditLog: { create: vi.fn(async () => ({})) },
    };
    const prisma = {
      invoice: {
        findUnique: vi.fn(async () => ({
          id: 'inv-1',
          branchId: 'branch-1',
          status: 'SENT',
        })),
        findUniqueOrThrow: vi.fn(async () => detail),
      },
      $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
    };
    const service = new InvoiceService(
      prisma as never,
      { get: () => '30' } as never,
      { post } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    )

    const result = await service.recordPayment(accountsUser, 'inv-1', {
      amountCents: 1000,
      method: 'E_TRANSFER',
      reference: 'ref-9',
    });

    expect(result.status).toBe('PARTIALLY_PAID');
    expect(tx.invoice.update).toHaveBeenCalledWith({
      where: { id: 'inv-1' },
      data: { paidCents: 1000, status: 'PARTIALLY_PAID' },
    });
    expect(post).toHaveBeenCalledWith(
      tx,
      expect.objectContaining({
        kind: 'INVOICE_PAYMENT',
        sourceType: 'INVOICE_PAYMENT',
        branchId: 'branch-1',
        lines: [
          {
            accountKey: 'ACCOUNTS_RECEIVABLE:ca-1',
            type: 'ACCOUNTS_RECEIVABLE',
            amountCents: -1000,
          },
          {
            accountKey: 'BANK_CLEARING:branch-1',
            type: 'BANK_CLEARING',
            amountCents: 1000,
          },
        ],
      }),
    );
    expect(tx.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        action: 'invoice.payment_recorded',
        after: expect.objectContaining({
          amountCents: 1000,
          method: 'E_TRANSFER',
          reference: 'ref-9',
        }),
      }),
    });
  });

  it('marks PAID when payment clears the balance', async () => {
    const post = vi.fn(async () => ({ id: 'txn-1' }));
    const tx = {
      invoice: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'inv-1',
          number: 'INV-2026-0001',
          branchId: 'branch-1',
          corporateAccountId: 'ca-1',
          paidCents: 2150,
          totalCents: 3150,
          status: 'PARTIALLY_PAID',
        })),
        update: vi.fn(async ({ data }) => data),
      },
      auditLog: { create: vi.fn(async () => ({})) },
    };
    const prisma = {
      invoice: {
        findUnique: vi.fn(async () => ({
          id: 'inv-1',
          branchId: 'branch-1',
          status: 'PARTIALLY_PAID',
        })),
        findUniqueOrThrow: vi.fn(async () => ({
          ...detail,
          paidCents: 3150,
          status: 'PAID',
        })),
      },
      $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
    };
    const service = new InvoiceService(
      prisma as never,
      { get: () => '30' } as never,
      { post } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    )

    await expect(
      service.recordPayment(accountsUser, 'inv-1', {
        amountCents: 1000,
        method: 'CHEQUE',
      }),
    ).resolves.toMatchObject({ status: 'PAID', paidCents: 3150 });
    expect(tx.invoice.update).toHaveBeenCalledWith({
      where: { id: 'inv-1' },
      data: { paidCents: 3150, status: 'PAID' },
    });
  });

  it('rejects overpayment and void invoices', async () => {
    const voidTx = {
      invoice: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'inv-1',
          status: 'VOID',
          paidCents: 0,
          totalCents: 100,
          corporateAccountId: 'ca-1',
          branchId: 'branch-1',
          number: 'INV-2026-0001',
        })),
      },
    };
    const overTx = {
      invoice: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'inv-1',
          status: 'SENT',
          paidCents: 3000,
          totalCents: 3150,
          corporateAccountId: 'ca-1',
          branchId: 'branch-1',
          number: 'INV-2026-0001',
        })),
      },
    };
    const make = (tx: typeof voidTx | typeof overTx) =>
      new InvoiceService(
        {
          invoice: {
            findUnique: vi.fn(async () => ({
              id: 'inv-1',
              branchId: 'branch-1',
              status: 'SENT',
            })),
          },
          $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
        } as never,
        { get: () => '30' } as never,
        { post: vi.fn() } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
      )

    await expect(
      make(voidTx).recordPayment(accountsUser, 'inv-1', {
        amountCents: 10,
        method: 'CASH',
      }),
    ).rejects.toMatchObject({
      response: { code: ApiCode.INVOICE_VOID },
    });
    await expect(
      make(overTx).recordPayment(accountsUser, 'inv-1', {
        amountCents: 200,
        method: 'CASH',
      }),
    ).rejects.toMatchObject({
      response: { code: ApiCode.OVERPAYMENT },
    });
  });

  it('splits consolidated payments pro-rata by line totals', async () => {
    const post = vi.fn(async () => ({ id: 'txn-1' }));
    const tx = {
      invoice: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'inv-g',
          number: 'INV-2026-0002',
          branchId: 'branch-1',
          corporateAccountId: null,
          paidCents: 0,
          totalCents: 3000,
          status: 'SENT',
        })),
        update: vi.fn(async ({ data }) => data),
      },
      invoiceLine: {
        findMany: vi.fn(async () => [
          { corporateAccountId: 'ca-a' },
          { corporateAccountId: 'ca-b' },
        ]),
        groupBy: vi.fn(async () => [
          { corporateAccountId: 'ca-a', _sum: { totalCents: 2000 } },
          { corporateAccountId: 'ca-b', _sum: { totalCents: 1000 } },
        ]),
      },
      auditLog: { create: vi.fn(async () => ({})) },
    };
    const prisma = {
      invoice: {
        findUnique: vi.fn(async () => ({
          id: 'inv-g',
          branchId: 'branch-1',
          status: 'SENT',
        })),
        findUniqueOrThrow: vi.fn(async () => ({
          ...detail,
          id: 'inv-g',
          corporateAccountId: null,
          paidCents: 1500,
          status: 'PARTIALLY_PAID',
        })),
      },
      $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
    };
    const service = new InvoiceService(
      prisma as never,
      { get: () => '30' } as never,
      { post } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    )

    await service.recordPayment(accountsUser, 'inv-g', {
      amountCents: 1500,
      method: 'WIRE',
    });

    expect(post).toHaveBeenCalledTimes(2);
    expect(post).toHaveBeenCalledWith(
      tx,
      expect.objectContaining({
        lines: expect.arrayContaining([
          expect.objectContaining({
            accountKey: 'ACCOUNTS_RECEIVABLE:ca-a',
            amountCents: -1000,
          }),
        ]),
      }),
    );
    expect(post).toHaveBeenCalledWith(
      tx,
      expect.objectContaining({
        lines: expect.arrayContaining([
          expect.objectContaining({
            accountKey: 'ACCOUNTS_RECEIVABLE:ca-b',
            amountCents: -500,
          }),
        ]),
      }),
    );
  });
});
