import {
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { BookingStatus, Prisma } from '@prisma/client';
import { describe, expect, it, vi } from 'vitest';
import { BookingStateService } from './booking-state.service.js';
import { driverRelease, stampFor, TRANSITIONS } from './booking-transitions.js';

const FORWARD: BookingStatus[] = [
  'TRIP_STARTED',
  'TRIP_COMPLETED',
  'PAYMENT_PENDING',
  'PAYMENT_COMPLETED',
  'CLOSED',
];

describe('TRANSITIONS', () => {
  it('has no cancellation once the trip has started', () => {
    for (const status of FORWARD) {
      expect(TRANSITIONS[status]?.CANCELLED).toBeUndefined();
    }
    expect(TRANSITIONS.TRIP_STARTED).toEqual({
      TRIP_COMPLETED: ['DRIVER', 'STAFF'],
    });
  });

  it('leaves CLOSED and CANCELLED terminal', () => {
    expect(TRANSITIONS.CLOSED).toBeUndefined();
    expect(TRANSITIONS.CANCELLED).toBeUndefined();
  });

  it('sends a driver cancel back to search, and a no-show to cancelled', () => {
    expect(TRANSITIONS.DRIVER_ASSIGNED?.CANCELLED).not.toContain('DRIVER');
    expect(TRANSITIONS.DRIVER_ASSIGNED?.SEARCHING_DRIVER).toContain('DRIVER');
    expect(TRANSITIONS.DRIVER_ARRIVED?.CANCELLED).toContain('DRIVER');
  });
});

describe('stampFor', () => {
  const now = new Date('2026-09-30T12:00:00.000Z');

  it('stamps the timestamp that matches the destination status', () => {
    expect(stampFor('DRIVER_ARRIVED', now)).toEqual({ arrivedAt: now });
    expect(stampFor('TRIP_STARTED', now)).toEqual({ startedAt: now });
    expect(stampFor('TRIP_COMPLETED', now)).toEqual({ completedAt: now });
    expect(stampFor('CLOSED', now)).toEqual({ closedAt: now });
    expect(stampFor('CANCELLED', now)).toEqual({ cancelledAt: now });
    expect(stampFor('SEARCHING_DRIVER', now)).toEqual({});
  });
});

describe('driverRelease', () => {
  it('clears the driver snapshot when an assigned booking returns to search', () => {
    for (const from of [
      'MATCHED',
      'DRIVER_ASSIGNED',
      'DRIVER_ARRIVING',
      'DRIVER_ARRIVED',
    ] as const) {
      expect(driverRelease(from, 'SEARCHING_DRIVER')).toEqual({
        driverId: null,
        vehicleId: null,
      });
    }
  });

  it('leaves the snapshot alone when search is the first step', () => {
    expect(driverRelease('CREATED', 'SEARCHING_DRIVER')).toEqual({});
    expect(driverRelease('NO_DRIVER_FOUND', 'SEARCHING_DRIVER')).toEqual({});
    expect(driverRelease('DRIVER_ASSIGNED', 'CANCELLED')).toEqual({});
  });
});

describe('BookingStateService.transition', () => {
  function setup(
    status: BookingStatus = 'CREATED',
    version = 3,
    driverId: string | null = null,
  ) {
    const booking = {
      id: 'booking-1',
      branchId: 'branch-1',
      driverId,
      status,
      version,
    };
    const history: Prisma.BookingStatusHistoryUncheckedCreateInput[] = [];
    const updates: Prisma.BookingUpdateManyArgs[] = [];
    let committed = false;
    const tx = {
      booking: {
        findUnique: vi.fn(async (): Promise<typeof booking | null> => booking),
        updateMany: vi.fn(async (args: Prisma.BookingUpdateManyArgs) => {
          updates.push(args);
          const where = args.where ?? {};
          if (where.status !== booking.status || where.version !== booking.version) {
            return { count: 0 };
          }
          return { count: 1 };
        }),
      },
      bookingStatusHistory: {
        create: vi.fn(
          async (args: {
            data: Prisma.BookingStatusHistoryUncheckedCreateInput;
          }) => {
            history.push(args.data);
          },
        ),
      },
    };
    const events = { emit: vi.fn(), emitAsync: vi.fn(async () => []) };
    const prisma = {
      $transaction: vi.fn(async (run: (client: typeof tx) => Promise<unknown>) => {
        const result = await run(tx);
        committed = true;
        return result;
      }),
    };
    const service = new BookingStateService(
      prisma as never,
      events as never,
    );
    return { service, tx, events, history, updates, prisma, isCommitted: () => committed };
  }

  it('writes history and emits only after the transaction commits', async () => {
    const { service, events, history, updates, isCommitted } = setup();

    events.emitAsync.mockImplementation(async () => {
      expect(isCommitted()).toBe(true);
      return [];
    });

    const result = await service.transition(
      'booking-1',
      'SEARCHING_DRIVER',
      { type: 'STAFF', userId: 'user-1' },
      { reason: 'dispatch' },
    );

    expect(result).toEqual({
      bookingId: 'booking-1',
      branchId: 'branch-1',
      from: 'CREATED',
      to: 'SEARCHING_DRIVER',
      prevDriverId: null,
      driverId: null,
    });
    expect(updates[0]?.where).toEqual({
      id: 'booking-1',
      status: 'CREATED',
      version: 3,
    });
    expect(updates[0]?.data).toMatchObject({
      status: 'SEARCHING_DRIVER',
      version: { increment: 1 },
    });
    expect(history).toEqual([
      {
        bookingId: 'booking-1',
        fromStatus: 'CREATED',
        toStatus: 'SEARCHING_DRIVER',
        actorType: 'STAFF',
        actorUserId: 'user-1',
        reason: 'dispatch',
        metadata: undefined,
      },
    ]);
    expect(events.emitAsync).toHaveBeenCalledWith('booking.status_changed', result);
  });

  it('does not emit when the caller owns the transaction', async () => {
    const { service, tx, events, prisma } = setup('SCHEDULED');

    await service.transition(
      'booking-1',
      'CREATED',
      { type: 'SYSTEM' },
      { tx: tx as never },
    );

    expect(prisma.$transaction).not.toHaveBeenCalled();
    expect(events.emitAsync).not.toHaveBeenCalled();
  });

  it('accepts every legal transition for each permitted actor', async () => {
    let checked = 0;
    for (const from of Object.keys(TRANSITIONS) as BookingStatus[]) {
      const targets = TRANSITIONS[from];
      if (!targets) continue;
      for (const to of Object.keys(targets) as BookingStatus[]) {
        for (const actor of targets[to] ?? []) {
          const { service, history } = setup(from);
          const result = await service.transition('booking-1', to, {
            type: actor,
            userId: actor === 'SYSTEM' ? undefined : 'user-1',
          });
          expect(result).toEqual({
            bookingId: 'booking-1',
            branchId: 'branch-1',
            from,
            to,
            prevDriverId: null,
            driverId: null,
          });
          expect(history[0]).toMatchObject({
            fromStatus: from,
            toStatus: to,
            actorType: actor,
          });
          checked += 1;
        }
      }
    }
    expect(checked).toBeGreaterThan(20);
  });

  it('returns 409 for an illegal transition such as TRIP_STARTED to CANCELLED', async () => {
    const { service, events, tx } = setup('TRIP_STARTED');

    const error = await service
      .transition('booking-1', 'CANCELLED', { type: 'STAFF' })
      .catch((caught: unknown) => caught);

    expect(error).toBeInstanceOf(ConflictException);
    expect((error as ConflictException).getStatus()).toBe(409);
    expect((error as ConflictException).message).toBe(
      'Illegal transition TRIP_STARTED → CANCELLED',
    );
    expect(tx.booking.updateMany).not.toHaveBeenCalled();
    expect(events.emitAsync).not.toHaveBeenCalled();
  });

  it('returns 403 when a passenger attempts TRIP_STARTED', async () => {
    const { service, tx, events } = setup('DRIVER_ARRIVED');

    const error = await service
      .transition('booking-1', 'TRIP_STARTED', { type: 'PASSENGER', userId: 'rider' })
      .catch((caught: unknown) => caught);

    expect(error).toBeInstanceOf(ForbiddenException);
    expect((error as ForbiddenException).getStatus()).toBe(403);
    expect(tx.booking.updateMany).not.toHaveBeenCalled();
    expect(events.emitAsync).not.toHaveBeenCalled();
  });

  it('lets exactly one of two simultaneous transitions win', async () => {
    const committed = {
      branchId: 'branch-1',
      driverId: 'driver-1',
      status: 'DRIVER_ASSIGNED' as BookingStatus,
      version: 4,
    };
    let reads = 0;
    let releaseReads: () => void = () => undefined;
    const bothRead = new Promise<void>((resolve) => {
      releaseReads = resolve;
    });
    const history: Prisma.BookingStatusHistoryUncheckedCreateInput[] = [];
    const tx = {
      booking: {
        findUnique: vi.fn(async () => {
          const snapshot = { id: 'booking-1', ...committed };
          reads += 1;
          if (reads === 2) releaseReads();
          await bothRead;
          return snapshot;
        }),
        updateMany: vi.fn(async (args: Prisma.BookingUpdateManyArgs) => {
          const where = args.where ?? {};
          if (where.status !== committed.status || where.version !== committed.version) {
            return { count: 0 };
          }
          committed.status = (args.data as { status: BookingStatus }).status;
          committed.version += 1;
          return { count: 1 };
        }),
      },
      bookingStatusHistory: {
        create: vi.fn(
          async (args: { data: Prisma.BookingStatusHistoryUncheckedCreateInput }) => {
            history.push(args.data);
          },
        ),
      },
    };
    const events = { emit: vi.fn(), emitAsync: vi.fn(async () => []) };
    const prisma = {
      $transaction: vi.fn(async (run: (client: typeof tx) => Promise<unknown>) => run(tx)),
    };
    const service = new BookingStateService(prisma as never, events as never);

    const results = await Promise.allSettled([
      service.transition('booking-1', 'CANCELLED', { type: 'STAFF', userId: 'user-1' }),
      service.transition('booking-1', 'SEARCHING_DRIVER', {
        type: 'STAFF',
        userId: 'user-1',
      }),
    ]);

    const won = results.filter((result) => result.status === 'fulfilled');
    const lost = results.filter((result) => result.status === 'rejected');
    expect(won).toHaveLength(1);
    expect(lost).toHaveLength(1);
    const reason = (lost[0] as PromiseRejectedResult).reason as ConflictException;
    expect(reason).toBeInstanceOf(ConflictException);
    expect(reason.getStatus()).toBe(409);
    expect(reason.message).toBe('Booking changed, retry');
    expect(history).toHaveLength(1);
    expect(events.emitAsync).toHaveBeenCalledTimes(1);
  });

  it('rejects an actor who cannot make an otherwise legal move', async () => {
    const { service } = setup('SEARCHING_DRIVER');

    await expect(
      service.transition('booking-1', 'MATCHED', { type: 'STAFF' }),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });

  it('returns not found and does not emit when the booking is missing', async () => {
    const { service, tx, events } = setup();
    tx.booking.findUnique.mockResolvedValue(null);

    await expect(
      service.transition('booking-1', 'CANCELLED', { type: 'STAFF' }),
    ).rejects.toBeInstanceOf(NotFoundException);
    expect(events.emitAsync).not.toHaveBeenCalled();
  });

  it('refuses the write when the version changed underneath', async () => {
    const { service, tx, events } = setup('DRIVER_ASSIGNED');
    tx.booking.updateMany.mockResolvedValue({ count: 0 });

    await expect(
      service.transition('booking-1', 'SEARCHING_DRIVER', { type: 'DRIVER' }),
    ).rejects.toThrow('Booking changed, retry');
    expect(tx.bookingStatusHistory.create).not.toHaveBeenCalled();
    expect(events.emitAsync).not.toHaveBeenCalled();
  });

  it('clears the assigned driver when returning to search, unless the patch sets one', async () => {
    const released = setup('DRIVER_ARRIVING', 3, 'driver-a');
    const freed = await released.service.transition('booking-1', 'SEARCHING_DRIVER', {
      type: 'STAFF',
    });
    expect(freed.prevDriverId).toBe('driver-a');
    expect(freed.driverId).toBeNull();
    expect(released.updates[0]?.data).toMatchObject({
      driverId: null,
      vehicleId: null,
    });

    const patched = setup('DRIVER_ASSIGNED', 3, 'driver-a');
    const kept = await patched.service.transition(
      'booking-1',
      'SEARCHING_DRIVER',
      { type: 'SYSTEM' },
      { patch: { driverId: 'driver-b' } },
    );
    expect(kept.prevDriverId).toBe('driver-a');
    expect(kept.driverId).toBe('driver-b');
    expect(patched.updates[0]?.data).toMatchObject({
      driverId: 'driver-b',
      vehicleId: null,
    });
  });
});
