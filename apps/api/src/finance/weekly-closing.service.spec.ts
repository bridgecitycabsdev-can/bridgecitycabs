import {
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { WeeklyClosingService } from './weekly-closing.service.js';

const accountsUser = {
  userId: 'acct-1',
  role: 'accounts_admin',
  branchId: 'branch-1',
};
const branchAdmin = {
  userId: 'ba-1',
  role: 'branch_admin',
  branchId: 'branch-1',
};

describe('WeeklyClosingService.closeWeek', () => {
  it('materializes DRAFT lines from ledger sums and never posts ledger', async () => {
    const weekStart = new Date('2026-09-21T06:00:00.000Z');
    const weekEnd = new Date('2026-09-28T06:00:00.000Z');
    const period = {
      id: 'cp-1',
      branchId: 'branch-1',
      weekStart,
      weekEnd,
      status: 'DRAFT',
      finalizedAt: null,
      finalizedById: null,
      createdAt: new Date('2026-09-28T07:00:00.000Z'),
    };
    const prisma = {
      closingPeriod: {
        findUnique: vi.fn(async () => null),
        upsert: vi.fn(async () => period),
        findUniqueOrThrow: vi.fn(async () => ({
          ...period,
          lines: [
            {
              id: 'cl-1',
              accountKey: 'DRIVER_BALANCE:d1',
              accountType: 'DRIVER_BALANCE',
              ownerId: 'd1',
              openingCents: 100,
              movementCents: 400,
              closingCents: 500,
            },
          ],
        })),
      },
      financialAccount: {
        findMany: vi.fn(async () => [
          {
            id: 'a1',
            key: 'DRIVER_BALANCE:d1',
            type: 'DRIVER_BALANCE',
            ownerId: 'd1',
          },
        ]),
      },
      ledgerEntry: {
        aggregate: vi
          .fn()
          .mockResolvedValueOnce({ _sum: { amountCents: -100 } }) // opening
          .mockResolvedValueOnce({ _sum: { amountCents: -500 } }), // through weekEnd
      },
      closingLine: {
        deleteMany: vi.fn(async () => ({ count: 0 })),
        createMany: vi.fn(async () => ({ count: 1 })),
      },
      $transaction: vi.fn(async (fn: (tx: unknown) => unknown) => fn(prisma)),
      ledgerTransaction: { create: vi.fn() },
    };
    const service = new WeeklyClosingService(prisma as never);

    const result = await service.closeWeek(
      'branch-1',
      weekStart,
      weekEnd,
      'acct-1',
    );

    expect(result.status).toBe('DRAFT');
    expect(result.lines).toHaveLength(1);
    expect(prisma.closingLine.createMany).toHaveBeenCalledWith({
      data: [
        {
          accountKey: 'DRIVER_BALANCE:d1',
          accountType: 'DRIVER_BALANCE',
          ownerId: 'd1',
          openingCents: 100,
          movementCents: 400,
          closingCents: 500,
          closingPeriodId: 'cp-1',
        },
      ],
    });
    expect(prisma.ledgerTransaction.create).not.toHaveBeenCalled();
  });

  it('refuses recomputation when FINALIZED', async () => {
    const weekStart = new Date('2026-09-21T06:00:00.000Z');
    const prisma = {
      closingPeriod: {
        findUnique: vi.fn(async () => ({
          id: 'cp-1',
          status: 'FINALIZED',
        })),
      },
    };
    const service = new WeeklyClosingService(prisma as never);
    await expect(
      service.closeWeek(
        'branch-1',
        weekStart,
        new Date('2026-09-28T06:00:00.000Z'),
      ),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it('allows DRAFT recomputation (deleteMany + createMany)', async () => {
    const weekStart = new Date('2026-09-21T06:00:00.000Z');
    const weekEnd = new Date('2026-09-28T06:00:00.000Z');
    const period = {
      id: 'cp-1',
      branchId: 'branch-1',
      weekStart,
      weekEnd,
      status: 'DRAFT',
      finalizedAt: null,
      finalizedById: null,
      createdAt: new Date(),
    };
    const prisma = {
      closingPeriod: {
        findUnique: vi.fn(async () => ({ id: 'cp-1', status: 'DRAFT' })),
        upsert: vi.fn(async () => period),
        findUniqueOrThrow: vi.fn(async () => ({ ...period, lines: [] })),
      },
      financialAccount: { findMany: vi.fn(async () => []) },
      ledgerEntry: { aggregate: vi.fn() },
      closingLine: {
        deleteMany: vi.fn(async () => ({ count: 3 })),
        createMany: vi.fn(),
      },
      $transaction: vi.fn(async (fn: (tx: unknown) => unknown) => fn(prisma)),
    };
    const service = new WeeklyClosingService(prisma as never);
    await service.closeWeek('branch-1', weekStart, weekEnd);
    expect(prisma.closingLine.deleteMany).toHaveBeenCalledWith({
      where: { closingPeriodId: 'cp-1' },
    });
    expect(prisma.closingLine.createMany).not.toHaveBeenCalled();
  });
});

describe('WeeklyClosingService.finalize', () => {
  it('flips DRAFT to FINALIZED with actor stamp', async () => {
    const weekStart = new Date('2026-09-21T06:00:00.000Z');
    const weekEnd = new Date('2026-09-28T06:00:00.000Z');
    const prisma = {
      closingPeriod: {
        findUnique: vi.fn(async () => ({
          id: 'cp-1',
          branchId: 'branch-1',
          status: 'DRAFT',
        })),
        update: vi.fn(async ({ data }) => ({ id: 'cp-1', ...data })),
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'cp-1',
          branchId: 'branch-1',
          weekStart,
          weekEnd,
          status: 'FINALIZED',
          finalizedAt: new Date('2026-09-29T12:00:00.000Z'),
          finalizedById: 'acct-1',
          createdAt: new Date(),
          lines: [],
        })),
      },
    };
    const service = new WeeklyClosingService(prisma as never);
    const result = await service.finalize(accountsUser, 'cp-1');
    expect(result.status).toBe('FINALIZED');
    expect(prisma.closingPeriod.update).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: 'cp-1' },
        data: expect.objectContaining({
          status: 'FINALIZED',
          finalizedById: 'acct-1',
        }),
      }),
    );
  });

  it('returns 409 on a second finalize', async () => {
    const prisma = {
      closingPeriod: {
        findUnique: vi.fn(async () => ({
          id: 'cp-1',
          branchId: 'branch-1',
          status: 'FINALIZED',
        })),
      },
    };
    const service = new WeeklyClosingService(prisma as never);
    await expect(service.finalize(accountsUser, 'cp-1')).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('rejects branch_admin finalize', async () => {
    const service = new WeeklyClosingService({} as never);
    await expect(service.finalize(branchAdmin, 'cp-1')).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });
});

describe('WeeklyClosingService.closeWeek totals', () => {
  it('recomputes the same movementCents from ledger aggregates on a DRAFT', async () => {
    const weekStart = new Date('2026-09-21T06:00:00.000Z');
    const weekEnd = new Date('2026-09-28T06:00:00.000Z');
    // Raw ledger: opening SUM=-100; through weekEnd SUM=-500 → movement = -((-500)-(-100)) = -400 reported as +400 after negate convention… 
    // Service: openingCents=-opening, movementCents=-(through-opening), closingCents=-through
    // opening=-100 → openingCents=100; through=-500 → movementCents=-(-400)=400; closingCents=500
    const period = {
      id: 'cp-1',
      branchId: 'branch-1',
      weekStart,
      weekEnd,
      status: 'DRAFT',
      finalizedAt: null,
      finalizedById: null,
      createdAt: new Date(),
    };
    const linesOut = [
      {
        id: 'cl-1',
        accountKey: 'DRIVER_BALANCE:d1',
        accountType: 'DRIVER_BALANCE',
        ownerId: 'd1',
        openingCents: 100,
        movementCents: 400,
        closingCents: 500,
      },
    ];
    const createMany = vi.fn(async () => ({ count: 1 }));
    const prisma = {
      closingPeriod: {
        findUnique: vi.fn(async () => ({ id: 'cp-1', status: 'DRAFT' })),
        upsert: vi.fn(async () => period),
        findUniqueOrThrow: vi.fn(async () => ({ ...period, lines: linesOut })),
      },
      financialAccount: {
        findMany: vi.fn(async () => [
          {
            id: 'a1',
            key: 'DRIVER_BALANCE:d1',
            type: 'DRIVER_BALANCE',
            ownerId: 'd1',
          },
        ]),
      },
      ledgerEntry: {
        aggregate: vi
          .fn()
          .mockResolvedValueOnce({ _sum: { amountCents: -100 } })
          .mockResolvedValueOnce({ _sum: { amountCents: -500 } })
          .mockResolvedValueOnce({ _sum: { amountCents: -100 } })
          .mockResolvedValueOnce({ _sum: { amountCents: -500 } }),
      },
      closingLine: {
        deleteMany: vi.fn(async () => ({ count: 1 })),
        createMany,
      },
      $transaction: vi.fn(async (fn: (tx: unknown) => unknown) => fn(prisma)),
    };

    const service = new WeeklyClosingService(prisma as never);
    const first = await service.closeWeek('branch-1', weekStart, weekEnd);
    const second = await service.closeWeek('branch-1', weekStart, weekEnd);

    expect(first.lines[0]?.movementCents).toBe(400);
    expect(second.lines[0]?.movementCents).toBe(400);
    expect(createMany).toHaveBeenCalledTimes(2);
    const handMovement = -((-500) - (-100)); // -(through - opening)
    expect(first.lines[0]?.movementCents).toBe(handMovement);
    expect(createMany.mock.calls[0]?.[0].data).toEqual(
      createMany.mock.calls[1]?.[0].data,
    );
  });
});

describe('WeeklyClosingService.runOnDemand', () => {
  it('rejects branch_admin', async () => {
    const service = new WeeklyClosingService({} as never);
    await expect(service.runOnDemand(branchAdmin)).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });
});
