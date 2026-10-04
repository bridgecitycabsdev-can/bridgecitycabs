import { ConflictException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { InvoiceService } from './invoice.service.js';

const accountsUser = {
  userId: 'acct-1',
  role: 'accounts_admin',
  branchId: 'branch-1',
};

describe('InvoiceService.generatePdf', () => {
  it('refuses regeneration past DRAFT without confirm', async () => {
    const service = new InvoiceService(
      {
        invoice: {
          findUnique: vi.fn(async () => ({
            id: 'inv-1',
            branchId: 'branch-1',
            status: 'SENT',
            number: 'INV-2026-0001',
          })),
        },
      } as never,
      { get: () => '3600' } as never,
      { post: vi.fn() } as never,
      { buildInvoicePdf: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    );
    await expect(service.generatePdf(accountsUser, 'inv-1', {})).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('builds PDF, upserts GeneratedReport, returns signed URL', async () => {
    const putObject = vi.fn(async () => undefined);
    const signedUrl = vi.fn(async () => 'https://example.test/inv.pdf');
    const buildInvoicePdf = vi.fn(async () => Buffer.from('%PDF-test'));
    const prisma = {
      invoice: {
        findUnique: vi.fn(async () => ({
          id: 'inv-1',
          branchId: 'branch-1',
          corporateAccountId: 'ca-1',
          groupId: null,
          status: 'DRAFT',
          number: 'INV-2026-0001',
          createdAt: new Date('2026-10-01T00:00:00.000Z'),
          dueAt: null,
          subtotalCents: 1000,
          taxCents: 50,
          totalCents: 1050,
        })),
      },
      branch: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'branch-1',
          name: 'Lethbridge',
          city: 'Lethbridge',
        })),
      },
      corporateAccount: {
        findUnique: vi.fn(async () => ({
          name: 'Prairie Hotel',
          billingAddress: '500 Scenic',
        })),
      },
      corporateAccountGroup: { findUnique: vi.fn() },
      invoiceLine: {
        findMany: vi.fn(async () => [
          {
            subtotalCents: 1000,
            taxCents: 50,
            booking: {
              trackingId: 'BC-1',
              completedAt: new Date('2026-09-15T00:00:00.000Z'),
            },
          },
        ]),
      },
      generatedReport: {
        findFirst: vi.fn(async () => null),
        create: vi.fn(async ({ data }) => ({ id: 'rep-inv-1', ...data })),
      },
    };

    const service = new InvoiceService(
      prisma as never,
      { get: () => '3600' } as never,
      { post: vi.fn() } as never,
      { buildInvoicePdf } as never,
      { putObject, signedUrl } as never,
    );

    await expect(
      service.generatePdf(accountsUser, 'inv-1', {}),
    ).resolves.toMatchObject({
      reportId: 'rep-inv-1',
      number: 'INV-2026-0001',
      storageKey: 'invoices/branch-1/INV-2026-0001.pdf',
      downloadUrl: 'https://example.test/inv.pdf',
    });
    expect(putObject).toHaveBeenCalledWith(
      'invoices/branch-1/INV-2026-0001.pdf',
      expect.any(Buffer),
      'application/pdf',
    );
    expect(prisma.generatedReport.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        type: 'INVOICE',
        status: 'READY',
        storageKey: 'invoices/branch-1/INV-2026-0001.pdf',
      }),
    });
  });
});
