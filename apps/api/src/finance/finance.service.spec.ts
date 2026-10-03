import { ConflictException, NotFoundException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { FinanceService } from './finance.service.js';

const accountsUser = {
  userId: 'acct-1',
  role: 'accounts_admin',
  branchId: 'branch-1',
};
const driverUser = {
  userId: 'driver-user',
  role: 'driver',
  branchId: 'branch-1',
};

describe('FinanceService.reverse', () => {
  it('posts negated lines once, refunds the booking, and audits', async () => {
    const original = {
      id: 'txn-1',
      kind: 'TRIP_CASH',
      sourceType: 'BOOKING',
      sourceId: 'booking-1',
      branchId: 'branch-1',
      entries: [
        {
          amountCents: 300,
          account: {
            key: 'DRIVER_BALANCE:d1',
            type: 'DRIVER_BALANCE',
            ownerId: 'd1',
          },
        },
        {
          amountCents: -200,
          account: {
            key: 'COMPANY_REVENUE:branch-1',
            type: 'COMPANY_REVENUE',
            ownerId: null,
          },
        },
        {
          amountCents: -100,
          account: {
            key: 'GST_PAYABLE:branch-1',
            type: 'GST_PAYABLE',
            ownerId: null,
          },
        },
      ],
    };
    const tx = {
      ledgerTransaction: {
        findUnique: vi
          .fn()
          .mockResolvedValueOnce(original)
          .mockResolvedValueOnce(null),
      },
      booking: { updateMany: vi.fn(async () => ({ count: 1 })) },
      auditLog: { create: vi.fn(async () => ({ id: 'audit-1' })) },
    };
    const prisma = {
      $transaction: vi.fn(async (fn: (client: typeof tx) => Promise<unknown>) =>
        fn(tx),
      ),
    };
    const ledger = {
      post: vi.fn(async () => ({
        id: 'rev-1',
        kind: 'REVERSAL',
        sourceType: 'REVERSAL',
        sourceId: 'txn-1',
        branchId: 'branch-1',
        description: 'Passenger refund',
        createdAt: new Date('2026-10-03T12:00:00Z'),
      })),
    };
    const service = new FinanceService(prisma as never, ledger as never);

    await expect(
      service.reverse(accountsUser, 'txn-1', 'Passenger refund'),
    ).resolves.toMatchObject({
      id: 'rev-1',
      kind: 'REVERSAL',
      reversalOfId: 'txn-1',
    });

    expect(ledger.post).toHaveBeenCalledWith(
      tx,
      expect.objectContaining({
        kind: 'REVERSAL',
        sourceType: 'REVERSAL',
        sourceId: 'txn-1',
        reversalOfId: 'txn-1',
        lines: [
          {
            accountKey: 'DRIVER_BALANCE:d1',
            type: 'DRIVER_BALANCE',
            ownerId: 'd1',
            amountCents: -300,
          },
          {
            accountKey: 'COMPANY_REVENUE:branch-1',
            type: 'COMPANY_REVENUE',
            ownerId: undefined,
            amountCents: 200,
          },
          {
            accountKey: 'GST_PAYABLE:branch-1',
            type: 'GST_PAYABLE',
            ownerId: undefined,
            amountCents: 100,
          },
        ],
      }),
    );
    expect(tx.booking.updateMany).toHaveBeenCalledWith({
      where: { id: 'booking-1' },
      data: { paymentStatus: 'REFUNDED' },
    });
    expect(tx.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({ action: 'ledger.reversed' }),
    });
  });

  it('rejects a second reversal', async () => {
    const tx = {
      ledgerTransaction: {
        findUnique: vi
          .fn()
          .mockResolvedValueOnce({
            id: 'txn-1',
            kind: 'TRIP_CASH',
            branchId: 'branch-1',
            entries: [],
          })
          .mockResolvedValueOnce({ id: 'rev-1' }),
      },
    };
    const prisma = {
      $transaction: vi.fn(async (fn: (client: typeof tx) => Promise<unknown>) =>
        fn(tx),
      ),
    };
    const service = new FinanceService(prisma as never, { post: vi.fn() } as never);
    await expect(
      service.reverse(accountsUser, 'txn-1', 'again'),
    ).rejects.toBeInstanceOf(ConflictException);
  });
});

describe('FinanceService.driverBalance', () => {
  it('returns -SUM of DRIVER_BALANCE entries', async () => {
    const prisma = {
      driver: {
        findUnique: vi.fn(async () => ({ id: 'd1', branchId: 'branch-1' })),
      },
      financialAccount: {
        findUnique: vi.fn(async () => ({ id: 'acct-1' })),
      },
      ledgerEntry: {
        aggregate: vi.fn(async () => ({ _sum: { amountCents: 300 } })),
      },
    };
    const service = new FinanceService(prisma as never, { post: vi.fn() } as never);
    await expect(service.driverBalance(accountsUser, 'd1')).resolves.toEqual({
      balanceCents: -300,
      asOf: expect.any(String),
    });
  });

  it('hides drivers outside the caller branch', async () => {
    const prisma = {
      driver: {
        findUnique: vi.fn(async () => ({ id: 'd1', branchId: 'other' })),
      },
    };
    const service = new FinanceService(prisma as never, { post: vi.fn() } as never);
    await expect(
      service.driverBalance(accountsUser, 'd1'),
    ).rejects.toBeInstanceOf(NotFoundException);
  });
});

describe('FinanceService.driverEarnings', () => {
  it('sums closed trips and reports the live ledger balance', async () => {
    const prisma = {
      driver: {
        findUnique: vi.fn(async () => ({ id: 'd1' })),
      },
      booking: {
        findMany: vi.fn(async () => [
          {
            id: 'b1',
            trackingId: 'BC-1',
            completedAt: new Date('2026-10-01T10:00:00Z'),
            paymentMethod: 'CASH',
            paymentStatus: 'PAID',
            finalSubtotalCents: 2000,
            commissionCents: 200,
            driverEarningCents: 1800,
            finalFareCents: 2100,
          },
        ]),
      },
      financialAccount: {
        findUnique: vi.fn(async () => ({ id: 'acct-1' })),
      },
      ledgerEntry: {
        aggregate: vi.fn(async () => ({ _sum: { amountCents: -1800 } })),
      },
    };
    const service = new FinanceService(prisma as never, { post: vi.fn() } as never);
    await expect(
      service.driverEarnings(driverUser, {
        from: '2026-10-01T00:00:00.000Z',
        to: '2026-10-31T23:59:59.999Z',
      }),
    ).resolves.toMatchObject({
      grossSubtotalCents: 2000,
      commissionCents: 200,
      netEarningsCents: 1800,
      balanceCents: 1800,
      trips: [expect.objectContaining({ trackingId: 'BC-1' })],
    });
  });
});
