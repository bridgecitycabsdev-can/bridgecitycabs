import { randomUUID } from 'node:crypto';
import { Redis } from 'ioredis';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { registerOfferCommands } from './offer-reservation.js';
import {
  DRIVER_HASH_FIELDS,
  driverKey,
  geoAvailableKey,
  offerReserveKey,
} from './redis.keys.js';

const LETHBRIDGE = { lat: '49.6935', lng: '-112.8418' };

describe('offer reservation', () => {
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

  it('claims an available driver and ignores a second writer', async () => {
    const driverId = randomUUID();
    const offerId = randomUUID();
    const bookingId = randomUUID();
    keys.push(driverKey(driverId), offerReserveKey(driverId));
    await redis.hset(driverKey(driverId), {
      [DRIVER_HASH_FIELDS.status]: 'AVAILABLE',
      [DRIVER_HASH_FIELDS.version]: '4',
      [DRIVER_HASH_FIELDS.lat]: LETHBRIDGE.lat,
      [DRIVER_HASH_FIELDS.lng]: LETHBRIDGE.lng,
    });
    await redis.geoadd(geoAvailableKey(branchId), LETHBRIDGE.lng, LETHBRIDGE.lat, driverId);

    expect(
      await fleet.reserveOffer({ driverId, branchId, offerId, bookingId, ttlSeconds: 15 }),
    ).toBe(true);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('OFFERED');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBe(bookingId);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.version)).toBe('5');
    expect(await redis.geopos(geoAvailableKey(branchId), driverId)).toEqual([null]);
    expect(await redis.hgetall(offerReserveKey(driverId))).toEqual({
      offerId,
      bookingId,
      driverId,
    });
    const ttl = await redis.ttl(offerReserveKey(driverId));
    expect(ttl).toBeGreaterThan(0);
    expect(ttl).toBeLessThanOrEqual(15);

    expect(
      await fleet.reserveOffer({
        driverId,
        branchId,
        offerId: randomUUID(),
        bookingId: randomUUID(),
        ttlSeconds: 15,
      }),
    ).toBe(false);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBe(bookingId);
    expect(await redis.hget(offerReserveKey(driverId), 'offerId')).toBe(offerId);
  });

  it('releases only the booking that still holds the offer and puts the driver back on the map', async () => {
    const driverId = randomUUID();
    const offerId = randomUUID();
    const bookingId = randomUUID();
    keys.push(driverKey(driverId), offerReserveKey(driverId));
    await redis.hset(driverKey(driverId), {
      [DRIVER_HASH_FIELDS.status]: 'AVAILABLE',
      [DRIVER_HASH_FIELDS.version]: '4',
      [DRIVER_HASH_FIELDS.lat]: LETHBRIDGE.lat,
      [DRIVER_HASH_FIELDS.lng]: LETHBRIDGE.lng,
      [DRIVER_HASH_FIELDS.availableSince]: '1',
    });
    await redis.geoadd(geoAvailableKey(branchId), LETHBRIDGE.lng, LETHBRIDGE.lat, driverId);
    expect(
      await fleet.reserveOffer({ driverId, branchId, offerId, bookingId, ttlSeconds: 15 }),
    ).toBe(true);

    expect(
      await fleet.releaseOffer({ driverId, branchId, bookingId: randomUUID() }),
    ).toBe(false);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('OFFERED');

    await redis.hset(driverKey(driverId), DRIVER_HASH_FIELDS.status, 'ASSIGNED');
    expect(await fleet.releaseOffer({ driverId, branchId, bookingId })).toBe(false);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('ASSIGNED');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBe(bookingId);
    expect(await redis.exists(offerReserveKey(driverId))).toBe(1);
    expect(await redis.geopos(geoAvailableKey(branchId), driverId)).toEqual([null]);

    await redis.hset(driverKey(driverId), DRIVER_HASH_FIELDS.status, 'OFFERED');
    expect(await fleet.releaseOffer({ driverId, branchId, bookingId })).toBe(true);
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status)).toBe('AVAILABLE');
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.bookingId)).toBeNull();
    expect(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.version)).toBe('6');
    expect(Number(await redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.availableSince))).toBeGreaterThan(1);
    expect(await redis.exists(offerReserveKey(driverId))).toBe(0);
    const [stored] = await redis.geopos(geoAvailableKey(branchId), driverId);
    expect(Number(stored?.[0])).toBeCloseTo(Number(LETHBRIDGE.lng), 4);
    expect(Number(stored?.[1])).toBeCloseTo(Number(LETHBRIDGE.lat), 4);
  });
});
