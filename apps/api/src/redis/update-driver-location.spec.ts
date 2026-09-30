import { randomUUID } from 'node:crypto';
import { Redis } from 'ioredis';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { driverKey, geoAvailableKey, presenceKey } from './redis.keys.js';
import { registerLocationCommand } from './update-driver-location.js';

const LETHBRIDGE = { lat: '49.6935', lng: '-112.8418' };
const CALGARY = { lat: '51.0447', lng: '-114.0719' };

describe('updateDriverLocation', () => {
  const redis = new Redis(process.env.REDIS_URL ?? 'redis://localhost:6379', {
    maxRetriesPerRequest: 2,
  });
  const branchId = randomUUID();
  const keys: string[] = [geoAvailableKey(branchId)];

  beforeAll(() => {
    registerLocationCommand(redis);
  });

  afterAll(async () => {
    if (keys.length) await redis.del(...keys);
    await redis.quit();
  });

  it('stores Lethbridge with longitude first and keeps Calgary far away', async () => {
    const lethbridge = randomUUID();
    const calgary = randomUUID();
    keys.push(driverKey(lethbridge), presenceKey(lethbridge), driverKey(calgary), presenceKey(calgary));
    await redis.hset(driverKey(lethbridge), 'status', 'AVAILABLE', 'staleSince', '1');
    await redis.hset(driverKey(calgary), 'status', 'AVAILABLE');

    expect(await ping(lethbridge, LETHBRIDGE.lng, LETHBRIDGE.lat)).toBe(1);
    expect(await ping(calgary, CALGARY.lng, CALGARY.lat)).toBe(1);

    expect(await redis.hget(driverKey(lethbridge), 'lng')).toBe(LETHBRIDGE.lng);
    expect(await redis.hget(driverKey(lethbridge), 'lat')).toBe(LETHBRIDGE.lat);
    expect(await redis.hget(driverKey(lethbridge), 'staleSince')).toBeNull();
    expect(await redis.ttl(presenceKey(lethbridge))).toBeGreaterThan(0);

    const [stored] = await redis.geopos(geoAvailableKey(branchId), lethbridge);
    expect(stored).not.toBeNull();
    expect(Number(stored?.[0])).toBeCloseTo(Number(LETHBRIDGE.lng), 4);
    expect(Number(stored?.[1])).toBeCloseTo(Number(LETHBRIDGE.lat), 4);

    const km = await redis.geodist(geoAvailableKey(branchId), lethbridge, calgary, 'KM');
    expect(Number(km)).toBeGreaterThan(150);
    expect(Number(km)).toBeLessThan(200);
  });

  it('rejects a latitude and longitude swap', async () => {
    const driverId = randomUUID();
    keys.push(driverKey(driverId), presenceKey(driverId));
    await redis.hset(driverKey(driverId), 'status', 'AVAILABLE');

    await expect(ping(driverId, LETHBRIDGE.lat, LETHBRIDGE.lng)).rejects.toThrow(
      /latitude|longitude|out of range|invalid/i,
    );
  });

  it('leaves an offline driver and skips the available geo index otherwise', async () => {
    const offline = randomUUID();
    const onTrip = randomUUID();
    keys.push(driverKey(offline), driverKey(onTrip), presenceKey(onTrip));
    await redis.hset(driverKey(offline), 'status', 'OFFLINE', 'lat', '0', 'lng', '0');
    await redis.hset(driverKey(onTrip), 'status', 'ON_TRIP', 'staleSince', '9');

    expect(await ping(offline, LETHBRIDGE.lng, LETHBRIDGE.lat)).toBe(0);
    expect(await redis.hget(driverKey(offline), 'lat')).toBe('0');

    expect(await ping(onTrip, LETHBRIDGE.lng, LETHBRIDGE.lat)).toBe(1);
    expect(await redis.hget(driverKey(onTrip), 'lat')).toBe(LETHBRIDGE.lat);
    expect(await redis.hget(driverKey(onTrip), 'staleSince')).toBeNull();
    const [position] = await redis.geopos(geoAvailableKey(branchId), onTrip);
    expect(position).toBeNull();
  });

  function ping(driverId: string, lng: string, lat: string) {
    return redis.updateDriverLocation(
      driverKey(driverId),
      geoAvailableKey(branchId),
      presenceKey(driverId),
      lng,
      lat,
      '90',
      '10',
      '5',
      String(Date.now()),
      '45',
      driverId,
    );
  }
});
