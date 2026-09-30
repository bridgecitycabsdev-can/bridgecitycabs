import { Inject, Injectable, Logger } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { Redis } from 'ioredis';
import { PrismaService } from '../prisma/prisma.service.js';
import { REDIS } from '../redis/redis.constants.js';
import { LOC_BUFFER_KEY } from '../redis/redis.keys.js';
import { LOCATION_FLUSH_BATCH } from './job-names.js';

const DRAIN_BUFFER = `
local count = tonumber(ARGV[1])
local items = redis.call('LRANGE', KEYS[1], 0, count - 1)
if #items > 0 then
  redis.call('LTRIM', KEYS[1], #items, -1)
end
return items
`;

@Injectable()
export class LocationFlushService {
  private readonly logger = new Logger(LocationFlushService.name);

  constructor(
    private readonly prisma: PrismaService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  async flush() {
    let written = 0;
    for (let pass = 0; pass < 20; pass += 1) {
      const batch = await this.drain();
      if (!batch.length) break;
      written += await this.store(batch);
      if (batch.length < LOCATION_FLUSH_BATCH) break;
    }
    return written;
  }

  private async drain() {
    const raw = await this.redis.eval(DRAIN_BUFFER, 1, LOC_BUFFER_KEY, String(LOCATION_FLUSH_BATCH));
    return Array.isArray(raw) ? raw.map((line) => String(line)) : [];
  }

  private async store(lines: string[]) {
    const kept: string[] = [];
    const data: Prisma.DriverLocationLogCreateManyInput[] = [];
    for (const line of lines) {
      const row = parseLocationLine(line);
      if (!row) {
        this.logger.warn('Dropped a location buffer line that could not be parsed');
        continue;
      }
      kept.push(line);
      data.push(row);
    }
    if (!data.length) return 0;
    try {
      const result = await this.prisma.driverLocationLog.createMany({ data });
      return result.count;
    } catch (error) {
      await this.redis.rpush(LOC_BUFFER_KEY, ...kept);
      throw error;
    }
  }
}

export function parseLocationLine(line: string): Prisma.DriverLocationLogCreateManyInput | null {
  let body: unknown;
  try {
    body = JSON.parse(line);
  } catch {
    return null;
  }
  if (!body || typeof body !== 'object') return null;
  const row = body as Record<string, unknown>;
  if (typeof row.driverId !== 'string' || !row.driverId) return null;
  const lat = Number(row.lat);
  const lng = Number(row.lng);
  const recordedAt = new Date(String(row.recordedAt ?? ''));
  if (!Number.isFinite(lat) || !Number.isFinite(lng) || Number.isNaN(recordedAt.getTime())) {
    return null;
  }
  return {
    driverId: row.driverId,
    bookingId: typeof row.bookingId === 'string' && row.bookingId ? row.bookingId : null,
    lat,
    lng,
    speedMps: optionalNumber(row.speedMps),
    heading: optionalNumber(row.heading),
    accuracyM: optionalNumber(row.accuracyM),
    recordedAt,
  };
}

function optionalNumber(value: unknown) {
  if (value == null || value === '') return null;
  const number = Number(value);
  return Number.isFinite(number) ? number : null;
}
