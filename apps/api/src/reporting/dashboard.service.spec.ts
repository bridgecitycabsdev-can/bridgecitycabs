import { describe, expect, it, vi } from 'vitest';
import { DashboardService } from './dashboard.service.js';

const admin = {
  userId: 'admin-1',
  role: 'branch_admin',
  branchId: 'branch-1',
};

const pastMidnight = new Date('2026-10-01T06:00:00.000Z');

describe('DashboardService.getDailyStats', () => {
  it('today is live aggregate and never upserts', async () => {
    const aggregateDailyStat = vi.fn(async () => ({
      totalRides: 2,
      completedRides: 1,
      activeRides: 1,
      cancelledRides: 0,
      unpaidRides: 1,
      prepaidRides: 0,
      postpaidRides: 2,
      accountCalls: 0,
      sourceDispatch: 2,
      sourceDriverApp: 0,
      sourcePassengerApp: 0,
      grossSubtotalCents: 500,
    }));
    const computeDailyStat = vi.fn();
    const prisma = {
      dailyBranchStat: { findUnique: vi.fn() },
    };
    const service = new DashboardService(
      prisma as never,
      { aggregateDailyStat, computeDailyStat } as never,
    );

    const todayStart = new Date('2026-10-04T06:00:00.000Z');
    const now = new Date('2026-10-04T18:00:00.000Z');
    await expect(
      service.getDailyStats('branch-1', todayStart, 'America/Edmonton', now),
    ).resolves.toMatchObject({ totalRides: 2, live: true });
    expect(aggregateDailyStat).toHaveBeenCalled();
    expect(prisma.dailyBranchStat.findUnique).not.toHaveBeenCalled();
    expect(computeDailyStat).not.toHaveBeenCalled();
  });

  it('past date reads rollup and self-heals when missing', async () => {
    const computeDailyStat = vi.fn(async () => ({
      totalRides: 4,
      completedRides: 3,
      activeRides: 0,
      cancelledRides: 1,
      unpaidRides: 0,
      prepaidRides: 1,
      postpaidRides: 3,
      accountCalls: 1,
      sourceDispatch: 2,
      sourceDriverApp: 0,
      sourcePassengerApp: 2,
      grossSubtotalCents: 900,
    }));
    const findUnique = vi
      .fn()
      .mockResolvedValueOnce(null)
      .mockResolvedValueOnce({
        totalRides: 4,
        completedRides: 3,
        activeRides: 0,
        cancelledRides: 1,
        unpaidRides: 0,
        prepaidRides: 1,
        postpaidRides: 3,
        accountCalls: 1,
        sourceDispatch: 2,
        sourceDriverApp: 0,
        sourcePassengerApp: 2,
        grossSubtotalCents: 900,
      });
    const service = new DashboardService(
      { dailyBranchStat: { findUnique } } as never,
      {
        aggregateDailyStat: vi.fn(),
        computeDailyStat,
      } as never,
    );

    const now = new Date('2026-10-04T18:00:00.000Z');
    await expect(
      service.getDailyStats('branch-1', pastMidnight, 'America/Edmonton', now),
    ).resolves.toMatchObject({ totalRides: 4, live: false });
    expect(computeDailyStat).toHaveBeenCalledWith('branch-1', pastMidnight);

    await expect(
      service.getDailyStats('branch-1', pastMidnight, 'America/Edmonton', now),
    ).resolves.toMatchObject({ totalRides: 4, live: false });
    expect(computeDailyStat).toHaveBeenCalledTimes(1);
  });

  it('metrics runs four scoped counts', async () => {
    const prisma = {
      passenger: { count: vi.fn(async () => 10) },
      vehicle: { count: vi.fn(async () => 4) },
      booking: { count: vi.fn(async () => 100) },
      user: { count: vi.fn(async () => 12) },
    };
    const service = new DashboardService(
      prisma as never,
      { aggregateDailyStat: vi.fn(), computeDailyStat: vi.fn() } as never,
    );
    await expect(service.metrics(admin, {})).resolves.toEqual({
      registeredPassengers: 10,
      registeredVehicles: 4,
      completedRides: 100,
      registeredUsers: 12,
    });
    expect(prisma.vehicle.count).toHaveBeenCalledWith({
      where: { branchId: 'branch-1' },
    });
    expect(prisma.booking.count).toHaveBeenCalledWith({
      where: { status: 'CLOSED', branchId: 'branch-1' },
    });
  });
});
