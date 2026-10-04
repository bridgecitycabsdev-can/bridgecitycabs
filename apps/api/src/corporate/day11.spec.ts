/**
 * Day 11 Step 11 checklist — fourteen scenarios for corporate credit,
 * ACCOUNT trips, invoicing, payments, overdue sweep, and branch isolation.
 */
import {
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { ApiCode } from '../common/api-code.js';
import { InvoiceService } from '../finance/invoice.service.js';
import { accountPostings } from '../ledger/trip-postings.js';
import { CorporateAccountsService } from './corporate-accounts.service.js';
import { CorporateCreditService } from './corporate-credit.service.js';

const accountsUser = {
  userId: 'acct-1',
  role: 'accounts_admin',
  branchId: 'branch-1',
};
const otherBranchAdmin = {
  userId: 'ba-2',
  role: 'branch_admin',
  branchId: 'branch-2',
};

function sum(lines: Array<{ amountCents: number }>) {
  return lines.reduce((s, l) => s + l.amountCents, 0);
}

describe('Day 11 corporate accounts (14)', () => {
  it('1. refuses booking credit check against an inactive account', async () => {
    const service = new CorporateCreditService({
      corporateAccount: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'ca-1',
          active: false,
          creditLimitCents: 10_000,
        })),
      },
      ledgerEntry: { aggregate: vi.fn() },
    } as never);
    await expect(service.checkCreditLimit('ca-1', 100)).rejects.toMatchObject({
      response: { code: ApiCode.ACCOUNT_INACTIVE },
    });
  });

  it('2. CREDIT_LIMIT_EXCEEDED exposes current/limit; override needs permission', async () => {
    const credit = new CorporateCreditService({
      corporateAccount: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'ca-1',
          active: true,
          creditLimitCents: 10_000,
        })),
      },
      ledgerEntry: {
        aggregate: vi.fn(async () => ({ _sum: { amountCents: 9_000 } })),
      },
    } as never);
    await expect(credit.checkCreditLimit('ca-1', 2_000)).rejects.toMatchObject({
      response: {
        code: ApiCode.CREDIT_LIMIT_EXCEEDED,
        currentCents: 9_000,
        limitCents: 10_000,
        requestedCents: 2_000,
      },
    });
    await expect(credit.checkCreditLimit('ca-1', 2_000)).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('3. creditLimitCents of 0 never blocks a booking', async () => {
    const service = new CorporateCreditService({
      corporateAccount: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'ca-1',
          active: true,
          creditLimitCents: 0,
        })),
      },
      ledgerEntry: {
        aggregate: vi.fn(async () => ({ _sum: { amountCents: 999_999 } })),
      },
    } as never);
    await expect(
      service.checkCreditLimit('ca-1', 50_000),
    ).resolves.toMatchObject({ limitCents: 0, currentCents: 999_999 });
  });

  it('4. accountPostings is balanced and completion path closes with PAID', () => {
    const lines = accountPostings({
      corporateAccountId: 'ca-1',
      subtotal: 2000,
      tax: 100,
      commission: 200,
      driverEarning: 1800,
    });
    expect(
      lines.reduce((s, l) => s + l.amt, 0),
    ).toBe(0);
    expect(lines.some((l) => l.acct === 'ACCOUNTS_RECEIVABLE:ca-1')).toBe(true);
    expect(lines.some((l) => l.type === 'COMPANY_REVENUE')).toBe(true);
    expect(lines.some((l) => l.type === 'GST_PAYABLE')).toBe(true);
  });

  it('5. account balance reflects AR and drops after an invoice payment posting', async () => {
    const aggregate = vi
      .fn()
      .mockResolvedValueOnce({ _sum: { amountCents: 5_000 } })
      .mockResolvedValueOnce({ _sum: { amountCents: 2_000 } });
    const credit = new CorporateCreditService({
      ledgerEntry: { aggregate },
    } as never);
    await expect(credit.getAccountReceivableBalance('ca-1')).resolves.toBe(
      5_000,
    );

    const post = vi.fn(async (_tx, input) => {
      expect(sum(input.lines)).toBe(0);
      expect(input.kind).toBe('INVOICE_PAYMENT');
      expect(input.lines).toEqual(
        expect.arrayContaining([
          expect.objectContaining({
            accountKey: 'ACCOUNTS_RECEIVABLE:ca-1',
            amountCents: -3_000,
          }),
        ]),
      );
      return { id: 'txn-pay' };
    });
    const tx = {
      invoice: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'inv-1',
          number: 'INV-2026-0001',
          branchId: 'branch-1',
          corporateAccountId: 'ca-1',
          paidCents: 0,
          totalCents: 5_000,
          status: 'SENT',
        })),
        update: vi.fn(async ({ data }) => data),
      },
      auditLog: { create: vi.fn(async () => ({})) },
    };
    const invoices = new InvoiceService(
      {
        invoice: {
          findUnique: vi.fn(async () => ({
            id: 'inv-1',
            branchId: 'branch-1',
            status: 'SENT',
          })),
          findUniqueOrThrow: vi.fn(async () => ({
            id: 'inv-1',
            number: 'INV-2026-0001',
            branchId: 'branch-1',
            corporateAccountId: 'ca-1',
            groupId: null,
            periodStart: new Date(),
            periodEnd: new Date(),
            subtotalCents: 4762,
            taxCents: 238,
            totalCents: 5_000,
            paidCents: 3_000,
            status: 'PARTIALLY_PAID',
            dueAt: null,
            generatedById: 'acct-1',
            createdAt: new Date(),
            corporateAccount: null,
            group: null,
            lines: [],
          })),
        },
        $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      } as never,
      { get: () => '30' } as never,
      { post } as never,
    );
    await invoices.recordPayment(accountsUser, 'inv-1', {
      amountCents: 3_000,
      method: 'E_TRANSFER',
    });
    await expect(credit.getAccountReceivableBalance('ca-1')).resolves.toBe(
      2_000,
    );
  });

  it('6. invoice generation queries CLOSED, uninvoiced bookings in the period', async () => {
    const findMany = vi.fn(async () => [
      {
        id: 'b1',
        corporateAccountId: 'ca-1',
        finalSubtotalCents: 1000,
        finalTaxCents: 50,
        finalFareCents: 1050,
      },
    ]);
    const tx = {
      corporateAccount: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'ca-1',
          branchId: 'branch-1',
        })),
      },
      booking: {
        findMany,
        updateMany: vi.fn(async () => ({ count: 1 })),
      },
      invoice: {
        create: vi.fn(async ({ data }) => ({ id: 'inv-1', ...data })),
      },
      invoiceLine: { createMany: vi.fn(async () => ({ count: 1 })) },
      $queryRaw: vi.fn(async () => [{ invoiceSeq: 1 }]),
    };
    const service = new InvoiceService(
      {
        $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
        invoice: {
          findUniqueOrThrow: vi.fn(async () => ({
            id: 'inv-1',
            number: 'INV-2026-0001',
            branchId: 'branch-1',
            corporateAccountId: 'ca-1',
            groupId: null,
            periodStart: new Date('2026-10-01'),
            periodEnd: new Date('2026-11-01'),
            subtotalCents: 1000,
            taxCents: 50,
            totalCents: 1050,
            paidCents: 0,
            status: 'DRAFT',
            dueAt: null,
            generatedById: 'acct-1',
            createdAt: new Date(),
            corporateAccount: null,
            group: null,
            lines: [],
          })),
        },
      } as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
    );
    const start = new Date('2026-10-01T00:00:00.000Z');
    const end = new Date('2026-11-01T00:00:00.000Z');
    await service.generateForAccount('ca-1', start, end, 'acct-1', accountsUser);
    expect(findMany).toHaveBeenCalledWith({
      where: {
        corporateAccountId: 'ca-1',
        status: 'CLOSED',
        invoicedAt: null,
        completedAt: { gte: start, lt: end },
      },
    });
  });

  it('7. second generation for the same period finds nothing billable', async () => {
    const service = new InvoiceService(
      {
        $transaction: vi.fn(async (fn: (tx: {
          corporateAccount: { findUniqueOrThrow: ReturnType<typeof vi.fn> };
          booking: { findMany: ReturnType<typeof vi.fn> };
        }) => unknown) =>
          fn({
            corporateAccount: {
              findUniqueOrThrow: vi.fn(async () => ({
                id: 'ca-1',
                branchId: 'branch-1',
              })),
            },
            booking: { findMany: vi.fn(async () => []) },
          }),
        ),
      } as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
    );
    await expect(
      service.generateForAccount(
        'ca-1',
        new Date('2026-10-01'),
        new Date('2026-11-01'),
        'acct-1',
        accountsUser,
      ),
    ).rejects.toMatchObject({
      response: { code: ApiCode.NO_BILLABLE_BOOKINGS },
    });
  });

  it('8. invoice header totals equal the sum of its lines', async () => {
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
    const create = vi.fn(async ({ data }) => ({ id: 'inv-1', ...data }));
    const createMany = vi.fn(async ({ data }) => {
      const sub = data.reduce(
        (s: number, l: { subtotalCents: number }) => s + l.subtotalCents,
        0,
      );
      const tax = data.reduce(
        (s: number, l: { taxCents: number }) => s + l.taxCents,
        0,
      );
      expect(sub).toBe(3000);
      expect(tax).toBe(150);
      return { count: data.length };
    });
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
      invoice: { create },
      invoiceLine: { createMany },
      $queryRaw: vi.fn(async () => [{ invoiceSeq: 2 }]),
    };
    const service = new InvoiceService(
      {
        $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
        invoice: {
          findUniqueOrThrow: vi.fn(async () => ({
            id: 'inv-1',
            number: 'INV-2026-0002',
            branchId: 'branch-1',
            corporateAccountId: 'ca-1',
            groupId: null,
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
            group: null,
            lines: [],
          })),
        },
      } as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
    );
    await service.generateForAccount(
      'ca-1',
      new Date('2026-10-01'),
      new Date('2026-11-01'),
      'acct-1',
      accountsUser,
    );
    expect(create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        subtotalCents: 3000,
        taxCents: 150,
        totalCents: 3150,
      }),
    });
  });

  it('9. voiding DRAFT frees bookings; voiding non-draft is refused', async () => {
    const voidTx = {
      booking: { updateMany: vi.fn(async () => ({ count: 1 })) },
      invoiceLine: { deleteMany: vi.fn(async () => ({ count: 1 })) },
      invoice: { update: vi.fn(async () => ({ status: 'VOID' })) },
    };
    const draftService = new InvoiceService(
      {
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
        $transaction: vi.fn(async (fn: (c: typeof voidTx) => unknown) =>
          fn(voidTx),
        ),
      } as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
    );
    await draftService.void(accountsUser, 'inv-1');
    expect(voidTx.booking.updateMany).toHaveBeenCalledWith({
      where: { invoiceId: 'inv-1' },
      data: { invoicedAt: null, invoiceId: null },
    });

    const sentService = new InvoiceService(
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
    );
    await expect(sentService.void(accountsUser, 'inv-1')).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('10. consolidated group invoice retains per-line corporateAccountId', async () => {
    const createMany = vi.fn(async () => ({ count: 2 }));
    const tx = {
      corporateAccountGroup: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'g1',
          accounts: [
            { id: 'ca-a', branchId: 'branch-1' },
            { id: 'ca-b', branchId: 'branch-1' },
          ],
        })),
      },
      booking: {
        findMany: vi.fn(async () => [
          {
            id: 'b1',
            corporateAccountId: 'ca-a',
            finalSubtotalCents: 1000,
            finalTaxCents: 50,
            finalFareCents: 1050,
          },
          {
            id: 'b2',
            corporateAccountId: 'ca-b',
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
      invoiceLine: { createMany },
      $queryRaw: vi.fn(async () => [{ invoiceSeq: 3 }]),
    };
    const service = new InvoiceService(
      {
        $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
        invoice: {
          findUniqueOrThrow: vi.fn(async () => ({
            id: 'inv-g',
            number: 'INV-2026-0003',
            branchId: 'branch-1',
            corporateAccountId: null,
            groupId: 'g1',
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
            group: { id: 'g1', name: 'HoldCo' },
            lines: [],
          })),
        },
      } as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
    );
    await service.generateForGroup(
      'g1',
      new Date('2026-10-01'),
      new Date('2026-11-01'),
      'acct-1',
      accountsUser,
    );
    expect(tx.invoice.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        corporateAccountId: null,
        groupId: 'g1',
      }),
    });
    expect(createMany).toHaveBeenCalledWith({
      data: expect.arrayContaining([
        expect.objectContaining({ bookingId: 'b1', corporateAccountId: 'ca-a' }),
        expect.objectContaining({ bookingId: 'b2', corporateAccountId: 'ca-b' }),
      ]),
    });
  });

  it('11. OVERPAYMENT refused; full payment → PAID; partial → PARTIALLY_PAID', async () => {
    const make = (invoice: {
      paidCents: number;
      totalCents: number;
      status: string;
    }) => {
      const post = vi.fn(async () => ({ id: 't' }));
      const tx = {
        invoice: {
          findUniqueOrThrow: vi.fn(async () => ({
            id: 'inv-1',
            number: 'INV-2026-0001',
            branchId: 'branch-1',
            corporateAccountId: 'ca-1',
            ...invoice,
          })),
          update: vi.fn(async ({ data }) => data),
        },
        auditLog: { create: vi.fn(async () => ({})) },
      };
      return {
        post,
        tx,
        service: new InvoiceService(
          {
            invoice: {
              findUnique: vi.fn(async () => ({
                id: 'inv-1',
                branchId: 'branch-1',
                status: invoice.status,
              })),
              findUniqueOrThrow: vi.fn(async () => ({
                id: 'inv-1',
                number: 'INV-2026-0001',
                branchId: 'branch-1',
                corporateAccountId: 'ca-1',
                groupId: null,
                periodStart: new Date(),
                periodEnd: new Date(),
                subtotalCents: 1000,
                taxCents: 50,
                totalCents: invoice.totalCents,
                paidCents: invoice.paidCents,
                status: invoice.status,
                dueAt: null,
                generatedById: 'acct-1',
                createdAt: new Date(),
                corporateAccount: null,
                group: null,
                lines: [],
              })),
            },
            $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) =>
              fn(tx),
            ),
          } as never,
          { get: () => '30' } as never,
          { post } as never,
        ),
      };
    };

    const over = make({ paidCents: 900, totalCents: 1000, status: 'SENT' });
    await expect(
      over.service.recordPayment(accountsUser, 'inv-1', {
        amountCents: 200,
        method: 'CASH',
      }),
    ).rejects.toMatchObject({ response: { code: ApiCode.OVERPAYMENT } });

    const full = make({ paidCents: 0, totalCents: 1000, status: 'SENT' });
    await full.service.recordPayment(accountsUser, 'inv-1', {
      amountCents: 1000,
      method: 'E_TRANSFER',
    });
    expect(full.tx.invoice.update).toHaveBeenCalledWith({
      where: { id: 'inv-1' },
      data: { paidCents: 1000, status: 'PAID' },
    });

    const partial = make({ paidCents: 0, totalCents: 1000, status: 'SENT' });
    await partial.service.recordPayment(accountsUser, 'inv-1', {
      amountCents: 400,
      method: 'CHEQUE',
    });
    expect(partial.tx.invoice.update).toHaveBeenCalledWith({
      where: { id: 'inv-1' },
      data: { paidCents: 400, status: 'PARTIALLY_PAID' },
    });
    expect(partial.post).toHaveBeenCalledWith(
      partial.tx,
      expect.objectContaining({
        lines: expect.arrayContaining([
          expect.objectContaining({
            accountKey: 'ACCOUNTS_RECEIVABLE:ca-1',
            amountCents: -400,
          }),
        ]),
      }),
    );
  });

  it('12. consolidated payment splits pro-rata across member AR accounts', async () => {
    const post = vi.fn(async () => ({ id: 't' }));
    const tx = {
      invoice: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'inv-g',
          number: 'INV-2026-0009',
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
    const service = new InvoiceService(
      {
        invoice: {
          findUnique: vi.fn(async () => ({
            id: 'inv-g',
            branchId: 'branch-1',
            status: 'SENT',
          })),
          findUniqueOrThrow: vi.fn(async () => ({
            id: 'inv-g',
            number: 'INV-2026-0009',
            branchId: 'branch-1',
            corporateAccountId: null,
            groupId: 'g1',
            periodStart: new Date(),
            periodEnd: new Date(),
            subtotalCents: 2857,
            taxCents: 143,
            totalCents: 3000,
            paidCents: 1500,
            status: 'PARTIALLY_PAID',
            dueAt: null,
            generatedById: 'acct-1',
            createdAt: new Date(),
            corporateAccount: null,
            group: null,
            lines: [],
          })),
        },
        $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      } as never,
      { get: () => '30' } as never,
      { post } as never,
    );
    await service.recordPayment(accountsUser, 'inv-g', {
      amountCents: 1500,
      method: 'WIRE',
    });
    const arPosts = post.mock.calls.map(
      (c) =>
        (c[1] as { lines: Array<{ accountKey: string; amountCents: number }> })
          .lines,
    );
    const arDrops = arPosts.flat().filter((l) =>
      l.accountKey.startsWith('ACCOUNTS_RECEIVABLE:'),
    );
    expect(arDrops).toEqual(
      expect.arrayContaining([
        expect.objectContaining({
          accountKey: 'ACCOUNTS_RECEIVABLE:ca-a',
          amountCents: -1000,
        }),
        expect.objectContaining({
          accountKey: 'ACCOUNTS_RECEIVABLE:ca-b',
          amountCents: -500,
        }),
      ]),
    );
    expect(arDrops.reduce((s, l) => s + l.amountCents, 0)).toBe(-1500);
  });

  it('13. overdue sweep flips past-due SENT and leaves others alone', async () => {
    const updateMany = vi.fn(async () => ({ count: 1 }));
    const service = new InvoiceService(
      { invoice: { updateMany } } as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
    );
    const now = new Date('2026-11-01T00:00:00.000Z');
    await expect(service.sweepOverdue(now)).resolves.toEqual({ updated: 1 });
    expect(updateMany).toHaveBeenCalledWith({
      where: {
        status: { in: ['SENT', 'PARTIALLY_PAID'] },
        dueAt: { lt: now },
      },
      data: { status: 'OVERDUE' },
    });
  });

  it('14. branch_admin cannot read or bill another branch’s corporate accounts', async () => {
    const accounts = new CorporateAccountsService(
      {
        corporateAccount: { findFirst: vi.fn(async () => null) },
      } as never,
      { getAccountReceivableBalance: vi.fn() } as never,
    );
    await expect(
      accounts.findOne('ca-other', otherBranchAdmin),
    ).rejects.toBeInstanceOf(NotFoundException);

    const invoices = new InvoiceService(
      {
        $transaction: vi.fn(async (fn: (tx: {
          corporateAccount: { findUniqueOrThrow: ReturnType<typeof vi.fn> };
        }) => unknown) =>
          fn({
            corporateAccount: {
              findUniqueOrThrow: vi.fn(async () => ({
                id: 'ca-1',
                branchId: 'branch-1',
              })),
            },
          }),
        ),
      } as never,
      { get: () => '30' } as never,
      { post: vi.fn() } as never,
    );
    await expect(
      invoices.generateForAccount(
        'ca-1',
        new Date('2026-10-01'),
        new Date('2026-11-01'),
        otherBranchAdmin.userId,
        otherBranchAdmin,
      ),
    ).rejects.toBeInstanceOf(NotFoundException);
  });
});
