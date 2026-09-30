import { Inject, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Redis } from 'ioredis';
import { LIVE_BOOKING_STATUSES } from '../bookings/booking-transitions.js';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { REDIS } from '../redis/redis.constants.js';
import {
  DRIVER_HASH_FIELDS,
  driverKey,
  geoAvailableKey,
  onlineKey,
  presenceKey,
} from '../redis/redis.keys.js';

const ON_A_TRIP = new Set(['ASSIGNED', 'EN_ROUTE_PICKUP', 'ARRIVED', 'ON_TRIP']);

@Injectable()
export class PresenceSweepService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly fleet: FleetStateService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  async sweep(nowMs = Date.now(), onlyBranchId?: string) {
    const branches = onlyBranchId
      ? [{ id: onlyBranchId }]
      : await this.prisma.branch.findMany({ select: { id: true } });
    for (const branch of branches) {
      const ids = await this.redis.smembers(onlineKey(branch.id));
      if (!ids.length) continue;
      const missing = await this.missingPresence(ids);
      if (!missing.length) continue;
      const live = await this.liveDriverIds(missing);
      for (const driverId of missing) {
        await this.markStale(branch.id, driverId, nowMs, live.has(driverId));
      }
    }
  }

  private async missingPresence(ids: string[]) {
    const pipe = this.redis.pipeline();
    for (const id of ids) pipe.exists(presenceKey(id));
    const rows = await pipe.exec();
    if (!rows) return [];
    return ids.filter((_, index) => {
      const row = rows[index];
      return !!row && !row[0] && row[1] === 0;
    });
  }

  private async liveDriverIds(ids: string[]) {
    const bookings = await this.prisma.booking.findMany({
      where: { driverId: { in: ids }, status: { in: [...LIVE_BOOKING_STATUSES] } },
      select: { driverId: true },
    });
    return new Set(bookings.map((booking) => booking.driverId).filter((id): id is string => !!id));
  }

  private async markStale(branchId: string, driverId: string, nowMs: number, liveBooking: boolean) {
    const key = driverKey(driverId);
    const status = await this.redis.hget(key, DRIVER_HASH_FIELDS.status);
    const created = await this.redis.hsetnx(key, DRIVER_HASH_FIELDS.staleSince, String(nowMs));
    const staleSince =
      created === 1
        ? nowMs
        : Number(await this.redis.hget(key, DRIVER_HASH_FIELDS.staleSince));
    const onTrip = liveBooking || (status != null && ON_A_TRIP.has(status));
    if (status === 'AVAILABLE' && !onTrip) {
      await this.redis.zrem(geoAvailableKey(branchId), driverId);
    }
    if (onTrip || !Number.isFinite(staleSince)) return;
    if (nowMs - staleSince < this.staleAfterMs()) return;
    await this.fleet.endConnectionLost(driverId, branchId);
  }

  private staleAfterMs() {
    const raw = Number(this.config.get('STALE_OFFLINE_AFTER_SECONDS') ?? 120);
    const seconds = Number.isFinite(raw) && raw > 0 ? Math.floor(raw) : 120;
    return seconds * 1000;
  }
}
