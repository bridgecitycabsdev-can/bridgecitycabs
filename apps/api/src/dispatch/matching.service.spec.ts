import { randomUUID } from 'node:crypto';
import { ConflictException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { Redis } from 'ioredis';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { registerOfferCommands } from '../redis/offer-reservation.js';
import {
  DRIVER_HASH_FIELDS,
  driverKey,
  geoAvailableKey,
  offerReserveKey,
  offeredDriversKey,
} from '../redis/redis.keys.js';
import { MatchingService, offerExpireDelay, radiusFor, rankCandidates } from './matching.service.js';

const PICKUP = { lat: 49.6935, lng: -112.8418 };

describe('radius and ranking', () => {
  it('widens the radius across the search window', () => {
    const radii = [3, 6, 10];
    expect(radiusFor(0, radii, 120)).toBe(3);
    expect(radiusFor(39, radii, 120)).toBe(3);
    expect(radiusFor(40, radii, 120)).toBe(6);
    expect(radiusFor(80, radii, 120)).toBe(10);
    expect(radiusFor(500, radii, 120)).toBe(10);
    expect(offerExpireDelay(new Date(1_000), 500)).toBe(1_500);
  });

  it('keeps the nearest driver, and the longest wait inside 200 m', () => {
    const ranked = rankCandidates([
      { driverId: 'close', vehicleId: 'v1', distanceM: 40, availableSince: 2_000 },
      { driverId: 'waiting', vehicleId: 'v2', distanceM: 180, availableSince: 100 },
      { driverId: 'far', vehicleId: 'v3', distanceM: 900, availableSince: 1 },
    ]);
    expect(ranked.map((row) => row.driverId)).toEqual(['waiting', 'close', 'far']);
  });
});

describe('MatchingService.offerNext', () => {
  const redis = new Redis(process.env.REDIS_URL ?? 'redis://localhost:6379', {
    maxRetriesPerRequest: 2,
  });
  const branchId = randomUUID();
  const keys: string[] = [geoAvailableKey(branchId)];
  const fleet = new FleetStateService(
    {} as never,
    { get: () => undefined } as never,
    {} as never,
    { emitAsync: async () => [] } as never,
    redis,
  );

  beforeAll(() => {
    registerOfferCommands(redis);
  });

  afterAll(async () => {
    if (keys.length) await redis.del(...keys);
    await redis.quit();
  });

  it('offers the longest-waiting nearby driver and leaves the others free', async () => {
    const bookingId = randomUUID();
    const close = await seed('Sedan', 0, Date.now() - 1_000);
    const waiting = await seed('Sedan', 0.0007, Date.now() - 120_000);
    const scheduled: unknown[] = [];
    const events: unknown[] = [];
    const matching = service(bookingId, {
      scheduled,
      events,
      transition: async () => ({
        bookingId,
        branchId,
        from: 'SEARCHING_DRIVER' as const,
        to: 'MATCHED' as const,
        prevDriverId: null,
        driverId: waiting,
      }),
    });

    const offer = await matching.offerNext(bookingId);

    expect(offer?.driverId).toBe(waiting);
    expect(offer?.attempt).toBe(1);
    expect(await redis.hget(driverKey(waiting), DRIVER_HASH_FIELDS.status)).toBe('OFFERED');
    expect(await redis.hget(driverKey(close), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    expect(await redis.sismember(offeredDriversKey(bookingId), waiting)).toBe(1);
    expect(await redis.ttl(offeredDriversKey(bookingId))).toBeGreaterThan(3_000);
    expect(scheduled[0]).toMatchObject({ offerId: offer?.id, bookingId, driverId: waiting });
    const delayMs = (scheduled[0] as { delayMs: number }).delayMs;
    expect(delayMs).toBeGreaterThan(15_000);
    expect(delayMs).toBeLessThanOrEqual(16_000);
    expect(events).toEqual([
      ['booking.status_changed', expect.objectContaining({ to: 'MATCHED', driverId: waiting })],
      [
        'offer.opened',
        expect.objectContaining({
          bookingId,
          driverId: waiting,
          offerId: offer?.id,
        }),
      ],
    ]);
    keys.push(offeredDriversKey(bookingId));
  });

  it('tries the next driver when reserve loses, and releases when Postgres rejects the offer', async () => {
    const bookingId = randomUUID();
    const first = await seed('Sedan', 0, Date.now() - 50_000);
    const second = await seed('Sedan', 0.002, Date.now() - 1_000);
    let reserves = 0;
    const realReserve = fleet.reserveOffer.bind(fleet);
    fleet.reserveOffer = async (input) => {
      reserves += 1;
      if (reserves === 1) return false;
      return realReserve(input);
    };
    const matching = service(bookingId, {
      transition: async () => {
        throw new Prisma.PrismaClientKnownRequestError('unique', {
          code: 'P2002',
          clientVersion: '6.19.3',
          meta: { target: 'one_active_booking_per_driver' },
        });
      },
    });

    try {
      await expect(matching.offerNext(bookingId)).resolves.toBeNull();
    } finally {
      fleet.reserveOffer = realReserve;
    }

    expect(await redis.hget(driverKey(first), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    expect(await redis.hget(driverKey(second), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    const [position] = await redis.geopos(geoAvailableKey(branchId), second);
    expect(position).not.toBeNull();
  });

  it('stops when the booking changed underneath the offer', async () => {
    const bookingId = randomUUID();
    const only = await seed('Sedan', 0, Date.now());
    const matching = service(bookingId, {
      transition: async () => {
        throw new ConflictException('Booking changed, retry');
      },
    });

    await expect(matching.offerNext(bookingId)).rejects.toBeInstanceOf(ConflictException);
    expect(await redis.hget(driverKey(only), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
  });

  it('returns the nearest eligible driver and skips the rest', async () => {
    await redis.del(geoAvailableKey(branchId));
    const bookingId = randomUUID();
    const nearest = await seed('Sedan', 0.001, Date.now() - 10_000);
    await seed('Sedan', 0, Date.now() - 500_000, { ts: Date.now() - 60_000 });
    await seed('SUV', 0, Date.now() - 500_000);
    await seed('Sedan', 0, Date.now() - 500_000, { status: 'ASSIGNED' });
    const already = await seed('Sedan', 0, Date.now() - 500_000);
    await seed('Sedan', 0.01, Date.now() - 500_000);
    await redis.sadd(offeredDriversKey(bookingId), already);
    keys.push(offeredDriversKey(bookingId));

    const offer = await service(bookingId, {
      transition: async () => ({ bookingId, to: 'MATCHED' }),
    }).offerNext(bookingId);

    expect(offer?.driverId).toBe(nearest);
    expect(await redis.hget(driverKey(nearest), DRIVER_HASH_FIELDS.status)).toBe('OFFERED');
    expect(await redis.hget(driverKey(already), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
  });

  it('offers a minivan only when the booking is van-only, and a lady driver only when asked', async () => {
    await redis.del(geoAvailableKey(branchId));
    const vanBooking = randomUUID();
    const sedan = await seed('Sedan', 0, Date.now() - 80_000);
    const van = await seed('Minivan', 0.001, Date.now() - 1_000);
    const vanOffer = await service(
      vanBooking,
      { transition: async () => ({ bookingId: vanBooking, to: 'MATCHED' }) },
      { vehicleType: 'Minivan', vanOnly: true },
    ).offerNext(vanBooking);
    expect(vanOffer?.driverId).toBe(van);
    expect(await redis.hget(driverKey(sedan), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');

    await redis.del(geoAvailableKey(branchId));
    const blocked = randomUUID();
    const sedanOnly = await seed('Sedan', 0, Date.now());
    const skipped = await service(
      blocked,
      { transition: async () => ({ bookingId: blocked, to: 'MATCHED' }) },
      { vehicleType: 'Sedan', vanOnly: true },
    ).offerNext(blocked);
    expect(skipped).toBeNull();
    expect(await redis.hget(driverKey(sedanOnly), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');

    await redis.del(geoAvailableKey(branchId));
    const ladyBooking = randomUUID();
    const other = await seed('Sedan', 0, Date.now() - 80_000);
    const lady = await seed('Sedan', 0.001, Date.now() - 1_000, { lady: '1' });
    const ladyOffer = await service(
      ladyBooking,
      { transition: async () => ({ bookingId: ladyBooking, to: 'MATCHED' }) },
      { ladyDriverOnly: true },
    ).offerNext(ladyBooking);
    expect(ladyOffer?.driverId).toBe(lady);
    expect(await redis.hget(driverKey(other), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
  });

  it('lets exactly one of two matchers reserve the driver', async () => {
    await redis.del(geoAvailableKey(branchId));
    const driverId = await seed('Sedan', 0, Date.now());
    const bookingA = randomUUID();
    const bookingB = randomUUID();
    const transition = async () => ({ to: 'MATCHED' as const });
    const [left, right] = await Promise.all([
      service(bookingA, { transition }).offerNext(bookingA),
      service(bookingB, { transition }).offerNext(bookingB),
    ]);

    const won = [left, right].filter((offer) => offer != null);
    expect(won).toHaveLength(1);
    expect(won[0]?.driverId).toBe(driverId);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBe(
      won[0]?.bookingId,
    );
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('OFFERED');
  });

  it('moves on after a timeout and does not offer that driver the same booking again', async () => {
    await redis.del(geoAvailableKey(branchId));
    const bookingId = randomUUID();
    const first = await seed('Sedan', 0, Date.now() - 60_000);
    const second = await seed('Sedan', 0.002, Date.now() - 1_000);
    const matching = service(bookingId, {
      transition: async () => ({ bookingId, to: 'MATCHED' }),
    });

    const opened = await matching.offerNext(bookingId);
    expect(opened?.driverId).toBe(first);
    expect(await fleet.releaseOffer({ branchId, driverId: first, bookingId })).toBe(true);
    expect(await redis.hget(driverKey(first), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');

    const next = await matching.offerNext(bookingId);
    expect(next?.driverId).toBe(second);
    expect(await redis.sismember(offeredDriversKey(bookingId), first)).toBe(1);
    keys.push(offeredDriversKey(bookingId));
  });

  async function seed(
    vehicleType: string,
    latOffset: number,
    availableSince: number,
    extra?: { status?: string; ts?: number; lady?: '0' | '1' },
  ) {
    const driverId = randomUUID();
    const vehicleId = randomUUID();
    keys.push(driverKey(driverId), offerReserveKey(driverId));
    const lat = PICKUP.lat + latOffset;
    await redis.hset(driverKey(driverId), {
      [DRIVER_HASH_FIELDS.status]: extra?.status ?? 'AVAILABLE',
      [DRIVER_HASH_FIELDS.version]: '2',
      [DRIVER_HASH_FIELDS.lat]: String(lat),
      [DRIVER_HASH_FIELDS.lng]: String(PICKUP.lng),
      [DRIVER_HASH_FIELDS.vehicleType]: vehicleType,
      [DRIVER_HASH_FIELDS.vehicleId]: vehicleId,
      [DRIVER_HASH_FIELDS.ladyDriverEligible]: extra?.lady ?? '0',
      [DRIVER_HASH_FIELDS.ts]: String(extra?.ts ?? Date.now()),
      [DRIVER_HASH_FIELDS.availableSince]: String(availableSince),
    });
    await redis.geoadd(geoAvailableKey(branchId), PICKUP.lng, lat, driverId);
    return driverId;
  }

  function service(
    bookingId: string,
    hooks: {
      scheduled?: unknown[];
      events?: unknown[];
      transition: () => Promise<unknown>;
    },
    patch?: { vanOnly?: boolean; ladyDriverOnly?: boolean; vehicleType?: string },
  ) {
    const booking = {
      id: bookingId,
      branchId,
      status: 'SEARCHING_DRIVER',
      assignMode: 'AUTO',
      searchStartedAt: new Date(),
      vanOnly: patch?.vanOnly ?? false,
      ladyDriverOnly: patch?.ladyDriverOnly ?? false,
      vehicleType: { name: patch?.vehicleType ?? 'Sedan' },
      branch: { offerTimeoutSeconds: 15 },
      stops: [{ type: 'PICKUP', lat: PICKUP.lat, lng: PICKUP.lng }],
    };
    const create = async ({ data }: { data: Record<string, unknown> }) => data;
    const prisma = {
      booking: {
        findUnique: async () => booking,
        updateMany: async () => ({ count: 0 }),
      },
      bookingOffer: {
        count: async () => 0,
        findFirst: async () => null,
        create,
      },
      $transaction: async (
        run: (tx: { bookingOffer: { create: typeof create } }) => Promise<unknown>,
      ) => run({ bookingOffer: { create } }),
    };
    return new MatchingService(
      prisma as never,
      { get: (key: string) => (key === 'SEARCH_RADII_KM' ? '3,6,10' : undefined) } as never,
      fleet,
      { transition: hooks.transition } as never,
      { emitAsync: async (...args: unknown[]) => { hooks.events?.push(args); return []; } } as never,
      redis,
      { schedule: async (job: unknown) => { hooks.scheduled?.push(job); } } as never,
    );
  }
});
