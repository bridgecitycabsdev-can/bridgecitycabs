import { Redis, type Result } from 'ioredis';

/**
 * One round trip per location ping.
 * GEOADD takes longitude, then latitude.
 *
 * 14 drivers pinging every 5 seconds for an 8-hour shift is about 80,640
 * calls. Each call runs several Redis commands inside this script, so check
 * that total against the Upstash plan before production. Idle drivers should
 * ping about every 15 seconds instead.
 */
export const UPDATE_DRIVER_LOCATION_LUA = `
local status = redis.call('HGET', KEYS[1], 'status')
if not status or status == 'OFFLINE' then return 0 end
redis.call('HSET', KEYS[1], 'lng', ARGV[1], 'lat', ARGV[2], 'heading', ARGV[3],
           'speed', ARGV[4], 'acc', ARGV[5], 'ts', ARGV[6])
redis.call('HDEL', KEYS[1], 'staleSince')
redis.call('SET', KEYS[3], '1', 'EX', ARGV[7])
if status == 'AVAILABLE' then
  redis.call('GEOADD', KEYS[2], ARGV[1], ARGV[2], ARGV[8])
else
  redis.call('ZREM', KEYS[2], ARGV[8])
end
return 1
`;

declare module 'ioredis' {
  interface RedisCommander<Context> {
    updateDriverLocation(
      driverHash: string,
      geoAvailable: string,
      presence: string,
      lng: string,
      lat: string,
      heading: string,
      speed: string,
      accuracy: string,
      nowMs: string,
      ttlSeconds: string,
      driverId: string,
    ): Result<number, Context>;
  }
}

export function registerLocationCommand(redis: Redis) {
  redis.defineCommand('updateDriverLocation', {
    numberOfKeys: 3,
    lua: UPDATE_DRIVER_LOCATION_LUA,
  });
}
