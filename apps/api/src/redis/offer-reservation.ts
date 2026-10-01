import { Redis, type Result } from 'ioredis';

/**
 * Claim an AVAILABLE driver for one offer.
 * KEYS: driver hash, available geo, offer key.
 * ARGV: offerId, bookingId, ttlSeconds, driverId.
 * offerId is part of the call so a later reader can tell which offer holds the driver.
 */
export const RESERVE_OFFER_LUA = `
local status = redis.call('HGET', KEYS[1], 'status')
if status ~= 'AVAILABLE' then return 0 end
redis.call('HSET', KEYS[1], 'status', 'OFFERED', 'bookingId', ARGV[2])
redis.call('HINCRBY', KEYS[1], 'v', 1)
redis.call('ZREM', KEYS[2], ARGV[4])
redis.call('HSET', KEYS[3], 'offerId', ARGV[1], 'bookingId', ARGV[2], 'driverId', ARGV[4])
redis.call('EXPIRE', KEYS[3], ARGV[3])
return 1
`;

/**
 * Free the driver only while this booking still holds the offer.
 * A late timeout must not move a driver who has already gone on to another status.
 * ARGV: bookingId, driverId, availableSinceMs.
 */
export const RELEASE_OFFER_LUA = `
local status = redis.call('HGET', KEYS[1], 'status')
local bookingId = redis.call('HGET', KEYS[1], 'bookingId')
if status ~= 'OFFERED' or bookingId ~= ARGV[1] then return 0 end
redis.call('HSET', KEYS[1], 'status', 'AVAILABLE', 'availableSince', ARGV[3])
redis.call('HDEL', KEYS[1], 'bookingId')
redis.call('HINCRBY', KEYS[1], 'v', 1)
local lng = redis.call('HGET', KEYS[1], 'lng')
local lat = redis.call('HGET', KEYS[1], 'lat')
if lng and lng ~= '' and lat and lat ~= '' then
  redis.call('GEOADD', KEYS[2], lng, lat, ARGV[2])
end
redis.call('DEL', KEYS[3])
return 1
`;

declare module 'ioredis' {
  interface RedisCommander<Context> {
    reserveOffer(
      driverHash: string,
      geoAvailable: string,
      offerKey: string,
      offerId: string,
      bookingId: string,
      ttlSeconds: string,
      driverId: string,
    ): Result<number, Context>;
    releaseOffer(
      driverHash: string,
      geoAvailable: string,
      offerKey: string,
      bookingId: string,
      driverId: string,
      availableSinceMs: string,
    ): Result<number, Context>;
  }
}

export function registerOfferCommands(redis: Redis) {
  redis.defineCommand('reserveOffer', {
    numberOfKeys: 3,
    lua: RESERVE_OFFER_LUA,
  });
  redis.defineCommand('releaseOffer', {
    numberOfKeys: 3,
    lua: RELEASE_OFFER_LUA,
  });
}
