import { describe, expect, it, vi } from 'vitest';
import { LeaseDeductionService } from './lease-deduction.service.js';

describe('LeaseDeductionService', () => {
  it('posts a LEASE_DEDUCTION with week-scoped sourceId', async () => {
    const post = vi.fn(async () => ({ id: 'txn-1' }));
    const prisma = {
      leaseAgreement: {
        findMany: vi.fn(async () => [
          {
            id: 'lease-1',
            driverId: 'driver-1',
            weeklyAmountCents: 50000,
            startDate: new Date('2026-01-01T00:00:00.000Z'),
            endDate: null,
            active: true,
            driver: {
              id: 'driver-1',
              branchId: 'branch-1',
              branch: { id: 'branch-1', timezone: 'America/Edmonton' },
            },
          },
        ]),
      },
      $transaction: vi.fn(async (fn: (tx: unknown) => unknown) => fn({})),
    };
    const service = new LeaseDeductionService(
      prisma as never,
      { post } as never,
    );

    const result = await service.run({
      timezone: 'America/Edmonton',
      now: new Date('2026-10-06T12:00:00.000Z'),
    });

    expect(result).toEqual({ considered: 1, posted: 1 });
    expect(post).toHaveBeenCalledWith(
      {},
      expect.objectContaining({
        kind: 'LEASE_DEDUCTION',
        sourceType: 'LEASE_WEEK',
        sourceId: 'lease-1:2026-10-05T06:00:00.000Z',
        branchId: 'branch-1',
        lines: [
          {
            accountKey: 'DRIVER_BALANCE:driver-1',
            type: 'DRIVER_BALANCE',
            ownerId: 'driver-1',
            amountCents: 50000,
          },
          {
            accountKey: 'LEASE_RECEIVABLE:branch-1',
            type: 'COMPANY_REVENUE',
            amountCents: -50000,
          },
        ],
      }),
    );
  });

  it('is safe to re-run because ledger.post is idempotent on sourceId', async () => {
    const post = vi.fn(async () => ({ id: 'txn-1' }));
    const prisma = {
      leaseAgreement: {
        findMany: vi.fn(async () => [
          {
            id: 'lease-1',
            driverId: 'driver-1',
            weeklyAmountCents: 100,
            startDate: new Date('2026-01-01T00:00:00.000Z'),
            endDate: null,
            driver: {
              id: 'driver-1',
              branchId: 'branch-1',
              branch: { timezone: 'America/Edmonton' },
            },
          },
        ]),
      },
      $transaction: vi.fn(async (fn: (tx: unknown) => unknown) => fn({})),
    };
    const service = new LeaseDeductionService(
      prisma as never,
      { post } as never,
    );
    const now = new Date('2026-10-06T12:00:00.000Z');
    await service.run({ now });
    await service.run({ now });
    expect(post).toHaveBeenCalledTimes(2);
    expect(post.mock.calls[0]?.[1].sourceId).toBe(post.mock.calls[1]?.[1].sourceId);
  });

  it('posts one deduction per driver when two leases share a week', async () => {
    const post = vi.fn(async () => ({ id: 'txn-1' }));
    const prisma = {
      leaseAgreement: {
        findMany: vi.fn(async () => [
          {
            id: 'lease-a',
            driverId: 'driver-a',
            weeklyAmountCents: 100,
            startDate: new Date('2026-01-01T00:00:00.000Z'),
            endDate: null,
            driver: {
              id: 'driver-a',
              branchId: 'branch-1',
              branch: { timezone: 'America/Edmonton' },
            },
          },
          {
            id: 'lease-b',
            driverId: 'driver-b',
            weeklyAmountCents: 200,
            startDate: new Date('2026-01-01T00:00:00.000Z'),
            endDate: null,
            driver: {
              id: 'driver-b',
              branchId: 'branch-1',
              branch: { timezone: 'America/Edmonton' },
            },
          },
        ]),
      },
      $transaction: vi.fn(async (fn: (tx: unknown) => unknown) => fn({})),
    };
    const service = new LeaseDeductionService(
      prisma as never,
      { post } as never,
    );
    const now = new Date('2026-10-06T12:00:00.000Z');
    await expect(service.run({ now })).resolves.toEqual({
      considered: 2,
      posted: 2,
    });
    const sourceIds = post.mock.calls.map((c) => c[1].sourceId).sort();
    expect(sourceIds).toEqual([
      'lease-a:2026-10-05T06:00:00.000Z',
      'lease-b:2026-10-05T06:00:00.000Z',
    ]);

    await service.run({ now });
    expect(post).toHaveBeenCalledTimes(4);
    expect(new Set(post.mock.calls.map((c) => c[1].sourceId)).size).toBe(2);
  });
});
