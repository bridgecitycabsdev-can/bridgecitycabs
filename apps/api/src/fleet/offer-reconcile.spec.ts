import { randomUUID } from 'node:crypto';
import { Redis } from 'ioredis';
import { afterAll, beforeAll, describe, expect, it, vi } from 'vitest';
import { DispatchJobsService } from '../dispatch/dispatch-jobs.service.js';
import { OFFER_RESOLVED } from '../dispatch/offer-events.js';
import { offerReserveKey } from '../redis/redis.keys.js';
import { FleetStateService } from './fleet-state.service.js';

describe('offer reconcile after a Redis flush', () => {
  const redis = new Redis(process.env.REDIS_URL ?? 'redis://localhost:6379', {
    maxRetriesPerRequest: 2,
  });
  const offerId = randomUUID();
  const bookingId = randomUUID();
  const driverId = randomUUID();
  const branchId = randomUUID();
  const reserveKey = offerReserveKey(driverId);

  beforeAll(async () => {
    await redis.hset(reserveKey, { offerId, bookingId, driverId });
  });

  afterAll(async () => {
    await redis.del(reserveKey);
    await redis.quit();
  });

  it('expires the orphaned offer and the search is queued again', async () => {
    const events: unknown[][] = [];
    const tx = {
      bookingOffer: {
        findMany: vi.fn(async () => [{ id: offerId, bookingId, driverId }]),
        updateMany: vi.fn(async () => ({ count: 1 })),
      },
      booking: {
        findUnique: vi.fn(async () => ({
          id: bookingId,
          branchId,
          status: 'MATCHED',
          version: 2,
          driverId,
        })),
        updateMany: vi.fn(async () => ({ count: 1 })),
      },
      bookingStatusHistory: { create: vi.fn(async () => ({})) },
      driverShift: { findMany: vi.fn(async () => []) },
    };
    const prisma = {
      ...tx,
      $transaction: vi.fn(async (run: (client: typeof tx) => Promise<unknown>) => run(tx)),
    };
    const fleet = new FleetStateService(
      prisma as never,
      { get: () => undefined } as never,
      {} as never,
      { emitAsync: async (...args: unknown[]) => { events.push(args); return []; } } as never,
      redis,
    );

    await fleet.reconcile();
    expect(events).toEqual([]);
    expect(tx.bookingOffer.updateMany).not.toHaveBeenCalled();

    await redis.del(reserveKey);
    await fleet.reconcile();

    expect(tx.bookingOffer.updateMany).toHaveBeenCalledWith({
      where: { id: offerId, status: 'OFFERED' },
      data: { status: 'EXPIRED', respondedAt: expect.any(Date) },
    });
    expect(tx.booking.updateMany).toHaveBeenCalledWith({
      where: { id: bookingId, status: 'MATCHED', version: 2 },
      data: {
        status: 'SEARCHING_DRIVER',
        version: { increment: 1 },
        driverId: null,
        vehicleId: null,
      },
    });
    const status = events.find((event) => event[0] === 'booking.status_changed')?.[1] as {
      bookingId: string;
      to: string;
    };
    expect(status).toMatchObject({
      bookingId,
      branchId,
      from: 'MATCHED',
      to: 'SEARCHING_DRIVER',
      prevDriverId: driverId,
      driverId: null,
    });
    expect(events).toContainEqual([
      OFFER_RESOLVED,
      expect.objectContaining({ offerId, bookingId, driverId, outcome: 'EXPIRED' }),
    ]);

    const queue = {
      enqueueAttempt: vi.fn(async () => undefined),
      removeAttempts: vi.fn(async () => undefined),
      scheduleRelease: vi.fn(),
    };
    const jobs = new DispatchJobsService(
      {
        booking: {
          findUnique: vi.fn(async () => ({
            assignMode: 'AUTO',
            status: 'SEARCHING_DRIVER',
            version: 3,
          })),
        },
      } as never,
      { get: () => undefined } as never,
      {} as never,
      {} as never,
      {} as never,
      { emitAsync: async () => [] } as never,
      queue,
    );
    await jobs.onStatus({ bookingId: status.bookingId, to: 'SEARCHING_DRIVER' });
    expect(queue.enqueueAttempt).toHaveBeenCalledWith(bookingId, 3);
  });
});
