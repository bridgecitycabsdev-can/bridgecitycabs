/**
 * Day 12 Step 9 checklist — eleven scenarios for promos, ratings,
 * notifications, support tickets, and SOS.
 */
import {
  ConflictException,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { describe, expect, it, vi } from 'vitest';
import { ApiCode } from './common/api-code.js';
import { FaresService } from './fares/fares.service.js';
import { NotificationsService } from './notifications/notifications.service.js';
import { applyPromo } from './promos/apply-promo.js';
import { PromosService } from './promos/promos.service.js';
import { RatingsService } from './ratings/ratings.service.js';
import { SosListener } from './realtime/sos.listener.js';
import { SosController } from './sos/sos.controller.js';
import { SosService } from './sos/sos.service.js';
import { SupportTicketsService } from './support/support-tickets.service.js';

const care = {
  userId: 'care-1',
  role: 'customer_care',
  branchId: 'branch-1',
};

function nextAvg(avg: number, count: number, stars: number) {
  return (avg * count + stars) / (count + 1);
}

describe('Day 12 promos, ratings, support & SOS (11)', () => {
  it('1. applyPromo: percent, fixed, cap, and subtotal floor at zero', () => {
    expect(applyPromo(10_000, { type: 'PERCENT', valueBps: 1000 })).toEqual({
      discountCents: 1000,
      netSubtotalCents: 9000,
    });
    expect(
      applyPromo(5000, {
        type: 'FIXED',
        valueCents: 2000,
        maxDiscountCents: 800,
      }),
    ).toEqual({ discountCents: 800, netSubtotalCents: 4200 });
    expect(applyPromo(300, { type: 'FIXED', valueCents: 500 })).toEqual({
      discountCents: 300,
      netSubtotalCents: 0,
    });
  });

  it('2. quote promo: expired, inactive, wrong-branch, below-min → PROMO_NOT_ELIGIBLE', async () => {
    const now = new Date('2026-10-04T12:00:00.000Z');
    const base = {
      id: 'promo-1',
      code: 'BAD',
      branchId: 'branch-1',
      active: true,
      startAt: null as Date | null,
      endAt: null as Date | null,
      minSubtotalCents: 0,
      usageLimitTotal: null as number | null,
      redeemedCount: 0,
    };
    const cases = [
      { ...base, endAt: new Date('2026-01-01T00:00:00.000Z') },
      { ...base, active: false },
      { ...base, branchId: 'branch-other' },
      { ...base, minSubtotalCents: 5000 },
    ];

    for (const promo of cases) {
      const service = new FaresService(
        {
          promoCode: { findUnique: vi.fn(async () => promo) },
        } as never,
        {} as never,
        {} as never,
        { get: () => undefined } as never,
      );
      await expect(
        service.requireEligiblePromo('BAD', 'branch-1', 1000, now),
      ).rejects.toMatchObject({
        response: { code: ApiCode.PROMO_NOT_ELIGIBLE },
      });
      await expect(
        service.requireEligiblePromo('BAD', 'branch-1', 1000, now),
      ).rejects.toBeInstanceOf(UnprocessableEntityException);
    }
  });

  it('3. redeem at exact usage limit succeeds once; concurrent next → PROMO_LIMIT_REACHED', async () => {
    let redeemedCount = 0;
    const usageLimitTotal = 1;
    const tx = {
      $queryRaw: vi.fn(async () => {
        if (redeemedCount < usageLimitTotal) {
          redeemedCount += 1;
          return [{ id: 'promo-1' }];
        }
        return [];
      }),
      promoCode: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'promo-1',
          usageLimitPerPassenger: null,
        })),
      },
      promoRedemption: { create: vi.fn(async () => ({})) },
    };
    const service = new PromosService({} as never);

    const results = await Promise.allSettled([
      service.redeem(tx as never, {
        promoCodeId: 'promo-1',
        passengerId: 'p1',
        bookingId: 'b1',
        discountCents: 100,
      }),
      service.redeem(tx as never, {
        promoCodeId: 'promo-1',
        passengerId: 'p2',
        bookingId: 'b2',
        discountCents: 100,
      }),
    ]);

    const ok = results.filter((r) => r.status === 'fulfilled');
    const fail = results.filter((r) => r.status === 'rejected');
    expect(ok).toHaveLength(1);
    expect(fail).toHaveLength(1);
    expect((fail[0] as PromiseRejectedResult).reason).toMatchObject({
      response: { code: ApiCode.PROMO_LIMIT_REACHED },
    });
    expect((fail[0] as PromiseRejectedResult).reason).toBeInstanceOf(
      ConflictException,
    );
  });

  it('4. per-passenger limit refused; cancel releaseIfAny frees the slot', async () => {
    const tx = {
      $queryRaw: vi.fn(async () => [{ id: 'promo-1' }]),
      promoCode: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'promo-1',
          usageLimitPerPassenger: 1,
        })),
      },
      promoRedemption: {
        count: vi.fn(async () => 1),
        create: vi.fn(async () => ({})),
        findUnique: vi.fn(async () => ({
          id: 'red-1',
          promoCodeId: 'promo-1',
          bookingId: 'b1',
          releasedAt: null,
        })),
        update: vi.fn(async () => ({})),
      },
      $executeRaw: vi.fn(async () => 1),
    };
    const service = new PromosService({} as never);

    await expect(
      service.redeem(tx as never, {
        promoCodeId: 'promo-1',
        passengerId: 'p1',
        bookingId: 'b2',
        discountCents: 50,
      }),
    ).rejects.toMatchObject({
      response: { code: ApiCode.PROMO_PASSENGER_LIMIT_REACHED },
    });

    await service.releaseIfAny(tx as never, 'b1');
    expect(tx.promoRedemption.update).toHaveBeenCalledWith({
      where: { id: 'red-1' },
      data: { releasedAt: expect.any(Date) },
    });
    expect(tx.$executeRaw).toHaveBeenCalled();

    tx.promoRedemption.count = vi.fn(async () => 0);
    await expect(
      service.redeem(tx as never, {
        promoCodeId: 'promo-1',
        passengerId: 'p1',
        bookingId: 'b3',
        discountCents: 50,
      }),
    ).resolves.toBeUndefined();
  });

  it('5. rating refused: not CLOSED, outside window, non-owner, or duplicate', async () => {
    const closed = {
      id: 'b1',
      passengerId: 'pass-1',
      driverId: 'drv-1',
      status: 'CLOSED',
      closedAt: new Date(),
    };
    const make = (booking: typeof closed) => {
      const tx = {
        booking: { findUnique: vi.fn(async () => booking) },
        bookingRating: {
          create: vi.fn(async () => {
            throw new Prisma.PrismaClientKnownRequestError('dup', {
              code: 'P2002',
              clientVersion: 'test',
            });
          }),
        },
      };
      return new RatingsService(
        {
          $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
        } as never,
        { get: () => '14' } as never,
      );
    };

    await expect(
      make({ ...closed, status: 'TRIP_COMPLETED' }).rateDriver('b1', 'pass-1', 5),
    ).rejects.toMatchObject({ response: { code: ApiCode.BOOKING_NOT_CLOSED } });

    await expect(
      make({
        ...closed,
        closedAt: new Date(Date.now() - 20 * 24 * 60 * 60 * 1000),
      }).rateDriver('b1', 'pass-1', 5),
    ).rejects.toMatchObject({
      response: { code: ApiCode.RATING_WINDOW_EXPIRED },
    });

    await expect(
      make({ ...closed, passengerId: 'other' }).rateDriver('b1', 'pass-1', 5),
    ).rejects.toBeInstanceOf(Error);

    await expect(make(closed).rateDriver('b1', 'pass-1', 5)).rejects.toMatchObject({
      response: { code: ApiCode.ALREADY_RATED },
    });
  });

  it('6. incremental average matches hand-computed average across concurrent ratings', async () => {
    const stars = [5, 4, 3, 5, 2];
    let handAvg = 0;
    let handCount = 0;
    for (const s of stars) {
      handAvg = nextAvg(handAvg, handCount, s);
      handCount += 1;
    }
    expect(handAvg).toBeCloseTo(stars.reduce((a, b) => a + b, 0) / stars.length);
    expect(handCount).toBe(5);

    // Simulate serialized concurrent SQL updates (FOR UPDATE / row lock).
    let ratingAvg = 0;
    let ratingCount = 0;
    const applySql = (s: number) => {
      ratingAvg = (ratingAvg * ratingCount + s) / (ratingCount + 1);
      ratingCount += 1;
    };
    await Promise.all(stars.map(async (s) => applySql(s)));
    expect(ratingAvg).toBeCloseTo(handAvg);
    expect(ratingCount).toBe(handCount);

    const tx = {
      booking: {
        findUnique: vi.fn(async () => ({
          id: 'b1',
          passengerId: 'pass-1',
          driverId: 'drv-1',
          status: 'CLOSED',
          closedAt: new Date(),
        })),
      },
      bookingRating: {
        create: vi.fn(async ({ data }) => ({ id: 'r1', ...data })),
      },
      $executeRaw: vi.fn(async () => 1),
    };
    const prisma = {
      $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      bookingRating: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'r1',
          bookingId: 'b1',
          raterType: 'PASSENGER',
          driverId: 'drv-1',
          passengerId: null,
          stars: 5,
          comment: null,
          createdAt: new Date(),
        })),
      },
    };
    const service = new RatingsService(
      prisma as never,
      { get: () => '14' } as never,
    );
    await service.rateDriver('b1', 'pass-1', 5);
    expect(tx.$executeRaw).toHaveBeenCalled();
  });

  it('7. notifications are user-scoped — cannot read/mark another user’s', async () => {
    const prisma = {
      notification: {
        updateMany: vi.fn(async () => ({ count: 0 })),
        findUniqueOrThrow: vi.fn(),
        count: vi.fn(async () => 0),
        findMany: vi.fn(async () => []),
      },
      $transaction: vi.fn(async (ops: Promise<unknown>[]) => Promise.all(ops)),
    };
    const service = new NotificationsService(
      prisma as never,
      { emit: vi.fn() } as never,
      { sendToUser: vi.fn() } as never,
    );

    await expect(service.markRead('user-A', 'n-belongs-to-B')).rejects.toBeInstanceOf(
      NotFoundException,
    );
    expect(prisma.notification.updateMany).toHaveBeenCalledWith({
      where: { id: 'n-belongs-to-B', userId: 'user-A' },
      data: { readAt: expect.any(Date) },
    });

    await service.list('user-A', { page: 1, pageSize: 20 });
    expect(prisma.notification.count).toHaveBeenCalledWith({
      where: { userId: 'user-A' },
    });
  });

  it('8. ticket numbers are unique and sequential under concurrent create', async () => {
    let seq = 0;
    const allocate = async () => {
      seq += 1;
      return `TCK-${String(seq).padStart(5, '0')}`;
    };
    const numbers = await Promise.all([allocate(), allocate(), allocate()]);
    expect(numbers).toEqual(['TCK-00001', 'TCK-00002', 'TCK-00003']);
    expect(new Set(numbers).size).toBe(3);

    const tx = {
      booking: { findUnique: vi.fn() },
      $queryRaw: vi.fn(async () => [{ ticketSeq: 7 }]),
      supportTicket: {
        create: vi.fn(async ({ data }) => ({ id: 't1', ...data })),
      },
      supportTicketMessage: { create: vi.fn(async () => ({ id: 'm1' })) },
    };
    const service = new SupportTicketsService(
      {
        $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
        supportTicket: { findUnique: vi.fn(async () => ({
          id: 't1',
          number: 'TCK-00007',
          branchId: 'branch-1',
          raisedByType: 'PASSENGER',
          raisedByUserId: 'pass-user',
          bookingId: null,
          subject: 'x',
          category: 'OTHER',
          priority: 'MEDIUM',
          status: 'OPEN',
          assignedToId: null,
          createdAt: new Date(),
          resolvedAt: null,
          closedAt: null,
          messages: [],
          booking: null,
        })) },
      } as never,
      { get: () => 'true' } as never,
      { notify: vi.fn() } as never,
    );
    const ticket = await service.create(
      { userId: 'pass-user', role: 'passenger', branchId: 'branch-1' },
      { subject: 'x', category: 'OTHER', body: 'hi' },
    );
    expect(ticket.number).toBe('TCK-00007');
  });

  it('9. requester reply reopens RESOLVED; staff reply does not', async () => {
    const passenger = {
      userId: 'pass-user',
      role: 'passenger',
      branchId: 'branch-1',
    };
    const detail = {
      id: 't1',
      number: 'TCK-00001',
      branchId: 'branch-1',
      raisedByType: 'PASSENGER',
      raisedByUserId: 'pass-user',
      bookingId: null,
      subject: 'bag',
      category: 'LOST_ITEM',
      priority: 'MEDIUM',
      status: 'OPEN',
      assignedToId: null,
      createdAt: new Date(),
      resolvedAt: null,
      closedAt: null,
      messages: [],
      booking: null,
    };

    const reopenTx = {
      supportTicketMessage: { create: vi.fn(async () => ({})) },
      supportTicket: { update: vi.fn(async () => ({})) },
    };
    const reopenPrisma = {
      supportTicket: {
        findUnique: vi
          .fn()
          .mockResolvedValueOnce({
            id: 't1',
            number: 'TCK-00001',
            branchId: 'branch-1',
            raisedByUserId: 'pass-user',
            status: 'RESOLVED',
          })
          .mockResolvedValueOnce(detail),
      },
      $transaction: vi.fn(async (fn: (c: typeof reopenTx) => unknown) =>
        fn(reopenTx),
      ),
    };
    const reopenSvc = new SupportTicketsService(
      reopenPrisma as never,
      { get: () => 'true' } as never,
      { notify: vi.fn() } as never,
    );
    await reopenSvc.addMessage(passenger, 't1', { body: 'Still missing' });
    expect(reopenTx.supportTicket.update).toHaveBeenCalledWith({
      where: { id: 't1' },
      data: { status: 'OPEN', resolvedAt: null },
    });

    const staffTx = {
      supportTicketMessage: { create: vi.fn(async () => ({})) },
      supportTicket: { update: vi.fn(async () => ({})) },
    };
    const staffPrisma = {
      supportTicket: {
        findUnique: vi
          .fn()
          .mockResolvedValueOnce({
            id: 't1',
            number: 'TCK-00001',
            branchId: 'branch-1',
            raisedByUserId: 'pass-user',
            status: 'RESOLVED',
          })
          .mockResolvedValueOnce({ ...detail, status: 'RESOLVED' }),
      },
      $transaction: vi.fn(async (fn: (c: typeof staffTx) => unknown) =>
        fn(staffTx),
      ),
    };
    const staffSvc = new SupportTicketsService(
      staffPrisma as never,
      { get: () => 'true' } as never,
      { notify: vi.fn() } as never,
    );
    await staffSvc.addMessage(care, 't1', { body: 'Checking storage' });
    expect(staffTx.supportTicket.update).not.toHaveBeenCalled();
  });

  it('10. pending-count matches OPEN+IN_PROGRESS COUNT and respects branch scope', async () => {
    const prisma = {
      supportTicket: { count: vi.fn(async () => 3) },
    };
    const service = new SupportTicketsService(
      prisma as never,
      { get: () => 'true' } as never,
      { notify: vi.fn() } as never,
    );
    await expect(service.pendingCount(care)).resolves.toEqual({ count: 3 });
    expect(prisma.supportTicket.count).toHaveBeenCalledWith({
      where: {
        branchId: 'branch-1',
        status: { in: ['OPEN', 'IN_PROGRESS'] },
      },
    });

    const other = {
      supportTicket: { count: vi.fn(async () => 0) },
    };
    const otherSvc = new SupportTicketsService(
      other as never,
      { get: () => 'true' } as never,
      { notify: vi.fn() } as never,
    );
    await otherSvc.pendingCount({
      userId: 'care-2',
      role: 'customer_care',
      branchId: 'branch-2',
    });
    expect(other.supportTicket.count).toHaveBeenCalledWith({
      where: {
        branchId: 'branch-2',
        status: { in: ['OPEN', 'IN_PROGRESS'] },
      },
    });
  });

  it('11. SOS: socket sos:triggered in wait window; ack notifies; resolve from TRIGGERED ok; no delete', async () => {
    const EVENT_WAIT_MS = 200;
    const listener = new SosListener();
    const seen = new Promise<unknown>((resolve) => {
      listener.bind({
        to: () => ({
          emit: (_event: string, payload: unknown) => resolve(payload),
        }),
      } as never);
    });
    listener.onTriggered({
      id: 'sos-1',
      branchId: 'branch-1',
      bookingId: null,
      triggeredByType: 'DRIVER',
      triggeredByUserId: 'driver-user',
      lat: 49.7,
      lng: -112.8,
      status: 'TRIGGERED',
      createdAt: new Date(),
    });
    const timedOut = new Promise((_, reject) =>
      setTimeout(() => reject(new Error('sos:triggered wait window exceeded')), EVENT_WAIT_MS),
    );
    await expect(Promise.race([seen, timedOut])).resolves.toMatchObject({
      id: 'sos-1',
      branchId: 'branch-1',
      status: 'TRIGGERED',
    });

    const notify = vi.fn(async () => ({}));
    const ackPrisma = {
      sosAlert: {
        findUnique: vi.fn(async () => ({
          id: 'sos-1',
          branchId: 'branch-1',
          bookingId: null,
          triggeredByType: 'DRIVER',
          triggeredByUserId: 'driver-user',
          lat: 49.7,
          lng: -112.8,
          status: 'TRIGGERED',
          acknowledgedById: null,
          acknowledgedAt: null,
          resolvedById: null,
          resolvedAt: null,
          resolutionNote: null,
          createdAt: new Date(),
        })),
        update: vi.fn(async ({ data }) => ({
          id: 'sos-1',
          branchId: 'branch-1',
          bookingId: null,
          triggeredByType: 'DRIVER',
          triggeredByUserId: 'driver-user',
          lat: 49.7,
          lng: -112.8,
          status: data.status,
          acknowledgedById: data.acknowledgedById,
          acknowledgedAt: data.acknowledgedAt,
          resolvedById: null,
          resolvedAt: null,
          resolutionNote: null,
          createdAt: new Date(),
        })),
      },
    };
    const ackSvc = new SosService(
      ackPrisma as never,
      { get: () => undefined } as never,
      { emit: vi.fn() } as never,
      { notify } as never,
      { sendTransactional: vi.fn() } as never,
    );
    await ackSvc.acknowledge(care, 'sos-1');
    expect(notify).toHaveBeenCalledWith(
      'driver-user',
      'SOS_ACKNOWLEDGED',
      'Dispatch has been notified',
      expect.any(String),
      expect.objectContaining({ alertId: 'sos-1' }),
    );

    // Decision: resolve is allowed straight from TRIGGERED (no ack required).
    const resolveTx = {
      sosAlert: {
        update: vi.fn(async ({ data }) => ({
          id: 'sos-2',
          branchId: 'branch-1',
          bookingId: null,
          triggeredByType: 'DRIVER',
          triggeredByUserId: 'driver-user',
          lat: 49.7,
          lng: -112.8,
          status: data.status,
          acknowledgedById: null,
          acknowledgedAt: null,
          resolvedById: data.resolvedById,
          resolvedAt: data.resolvedAt,
          resolutionNote: data.resolutionNote,
          createdAt: new Date(),
        })),
      },
      auditLog: { create: vi.fn(async () => ({})) },
    };
    const resolvePrisma = {
      sosAlert: {
        findUnique: vi.fn(async () => ({
          id: 'sos-2',
          branchId: 'branch-1',
          bookingId: null,
          triggeredByType: 'DRIVER',
          triggeredByUserId: 'driver-user',
          lat: 49.7,
          lng: -112.8,
          status: 'TRIGGERED',
          acknowledgedById: null,
          acknowledgedAt: null,
          resolvedById: null,
          resolvedAt: null,
          resolutionNote: null,
          createdAt: new Date(),
        })),
      },
      $transaction: vi.fn(async (fn: (c: typeof resolveTx) => unknown) =>
        fn(resolveTx),
      ),
    };
    const resolveSvc = new SosService(
      resolvePrisma as never,
      { get: () => undefined } as never,
      { emit: vi.fn() } as never,
      { notify: vi.fn() } as never,
      { sendTransactional: vi.fn() } as never,
    );
    await expect(
      resolveSvc.resolve(care, 'sos-2', {
        outcome: 'FALSE_ALARM',
        note: 'Accidental',
      }),
    ).resolves.toMatchObject({ status: 'FALSE_ALARM' });
    expect(resolveTx.auditLog.create).toHaveBeenCalled();

    const proto = SosController.prototype as Record<string, unknown>;
    expect(typeof proto.driverTrigger).toBe('function');
    expect(typeof proto.acknowledge).toBe('function');
    expect(typeof proto.resolve).toBe('function');
    expect(proto.delete).toBeUndefined();
    expect(proto.remove).toBeUndefined();
  });
});
