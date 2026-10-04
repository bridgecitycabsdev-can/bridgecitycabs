import { describe, expect, it, vi } from 'vitest';
import { ACTIVE_STATUSES, DailyStatsService } from './daily-stats.service.js';

const day = new Date('2026-10-03T06:00:00.000Z');

describe('DailyStatsService', () => {
  it('aggregates payment buckets, sources, and gross subtotal without writing', async () => {
    const bookings = [
      {
        status: 'CLOSED',
        paymentMethod: 'CARD',
        paymentStatus: 'PAID',
        source: 'PASSENGER_APP',
        corporateAccountId: null,
        finalSubtotalCents: 1000,
      },
      {
        status: 'TRIP_STARTED',
        paymentMethod: 'CASH',
        paymentStatus: 'UNPAID',
        source: 'DISPATCH',
        corporateAccountId: 'ca-1',
        finalSubtotalCents: 2000,
      },
      {
        status: 'CANCELLED',
        paymentMethod: 'ACCOUNT',
        paymentStatus: 'UNPAID',
        source: 'DRIVER_APP',
        corporateAccountId: 'ca-1',
        finalSubtotalCents: null,
      },
    ];
    const prisma = {
      branch: {
        findUnique: vi.fn(async () => ({ timezone: 'America/Edmonton' })),
      },
      booking: { findMany: vi.fn(async () => bookings) },
      dailyBranchStat: { upsert: vi.fn() },
    };
    const service = new DailyStatsService(prisma as never);

    await expect(
      service.aggregateDailyStat('branch-1', day),
    ).resolves.toMatchObject({
      totalRides: 3,
      completedRides: 1,
      activeRides: 1,
      cancelledRides: 1,
      unpaidRides: 2,
      prepaidRides: 1,
      postpaidRides: 2,
      accountCalls: 2,
      sourceDispatch: 1,
      sourceDriverApp: 1,
      sourcePassengerApp: 1,
      grossSubtotalCents: 3000,
    });
    expect(prisma.dailyBranchStat.upsert).not.toHaveBeenCalled();
    expect(ACTIVE_STATUSES).toContain('TRIP_STARTED');
  });

  it('computeDailyStat upserts the aggregate', async () => {
    const upsert = vi.fn(async ({ create }) => create);
    const prisma = {
      branch: {
        findUnique: vi.fn(async () => ({ timezone: 'America/Edmonton' })),
      },
      booking: { findMany: vi.fn(async () => []) },
      dailyBranchStat: { upsert },
    };
    const service = new DailyStatsService(prisma as never);
    await service.computeDailyStat('branch-1', day);
    expect(upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { branchId_date: { branchId: 'branch-1', date: day } },
      }),
    );
  });
});
