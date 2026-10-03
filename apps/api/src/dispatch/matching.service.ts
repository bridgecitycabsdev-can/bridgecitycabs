import { randomUUID } from 'node:crypto';
import { ConflictException, Inject, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { Prisma } from '@prisma/client';
import type { Redis } from 'ioredis';
import { BookingStateService } from '../bookings/booking-state.service.js';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import {
  OFFER_EXPIRY_SCHEDULER,
  type OfferExpiryScheduler,
} from '../jobs/offer-expiry.scheduler.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { REDIS } from '../redis/redis.constants.js';
import { OFFER_OPENED } from './offer-events.js';
import {
  DRIVER_HASH_FIELDS,
  driverKey,
  geoAvailableKey,
  offeredDriversKey,
} from '../redis/redis.keys.js';

const CANDIDATE_COUNT = 20;
/** Drivers inside one band are treated as the same distance. */
export const SAME_BLOCK_METERS = 200;

const bookingSelect = {
  id: true,
  branchId: true,
  status: true,
  assignMode: true,
  searchStartedAt: true,
  vanOnly: true,
  ladyDriverOnly: true,
  vehicleType: { select: { name: true } },
  branch: { select: { offerTimeoutSeconds: true } },
  stops: {
    orderBy: { sequence: 'asc' as const },
    select: { type: true, lat: true, lng: true },
  },
} satisfies Prisma.BookingSelect;

const NEARBY_FIELDS = [
  DRIVER_HASH_FIELDS.status,
  DRIVER_HASH_FIELDS.vehicleType,
  DRIVER_HASH_FIELDS.ladyDriverEligible,
  DRIVER_HASH_FIELDS.ts,
  DRIVER_HASH_FIELDS.name,
  DRIVER_HASH_FIELDS.unit,
  DRIVER_HASH_FIELDS.vehicleId,
] as const;

const HASH_FIELDS = [
  DRIVER_HASH_FIELDS.status,
  DRIVER_HASH_FIELDS.vehicleType,
  DRIVER_HASH_FIELDS.ladyDriverEligible,
  DRIVER_HASH_FIELDS.ts,
  DRIVER_HASH_FIELDS.availableSince,
  DRIVER_HASH_FIELDS.vehicleId,
] as const;

type BookingForMatch = Prisma.BookingGetPayload<{ select: typeof bookingSelect }>;

export type MatchCandidate = {
  driverId: string;
  vehicleId: string;
  distanceM: number;
  availableSince: number | null;
};

export const CANDIDATE_REASONS = [
  'VEHICLE_TYPE_MISMATCH',
  'NOT_VAN',
  'NOT_LADY_ELIGIBLE',
  'STALE_LOCATION',
] as const;

export type CandidateReason = (typeof CANDIDATE_REASONS)[number];

export type NearbyDriver = {
  driverId: string;
  name: string;
  unit: string;
  vehicleId: string;
  distanceM: number;
  eligible: boolean;
  reasons: CandidateReason[];
};

@Injectable()
export class MatchingService {
  private readonly logger = new Logger(MatchingService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly fleet: FleetStateService,
    private readonly state: BookingStateService,
    private readonly events: EventEmitter2,
    @Inject(REDIS) private readonly redis: Redis,
    @Inject(OFFER_EXPIRY_SCHEDULER) private readonly expiry: OfferExpiryScheduler,
  ) {}

  /**
   * Offer the booking to one eligible driver.
   * Returns the open offer when the booking is already matched.
   */
  async offerNext(bookingId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: bookingSelect,
    });
    if (!booking || booking.assignMode !== 'AUTO') return null;
    if (booking.status === 'MATCHED') return this.rejoinOpenOffer(booking.id);
    if (booking.status !== 'SEARCHING_DRIVER') return null;

    // A passenger retry moves searchStartedAt forward, so earlier offers do not use up the new search.
    const attempts = await this.prisma.bookingOffer.count({
      where: offersInThisSearch(bookingId, booking.searchStartedAt),
    });
    if (attempts >= this.readInt('MAX_OFFERS_PER_BOOKING', 6)) return null;

    const started = await this.ensureSearchStarted(booking);
    const pickup = booking.stops.find((stop) => stop.type === 'PICKUP') ?? booking.stops[0];
    if (!pickup) return null;

    const radiusKm = radiusFor(
      (Date.now() - started.getTime()) / 1000,
      this.radiiKm(),
      this.readInt('SEARCH_WINDOW_SECONDS', 120),
    );
    const candidates = await this.rankEligible(booking, pickup, radiusKm);
    const timeoutSeconds = booking.branch.offerTimeoutSeconds;

    for (const candidate of candidates) {
      const offerId = randomUUID();
      const held = await this.fleet.reserveOffer({
        driverId: candidate.driverId,
        branchId: booking.branchId,
        offerId,
        bookingId: booking.id,
        ttlSeconds: timeoutSeconds,
      });
      if (!held) continue;

      try {
        const created = await this.prisma.$transaction(async (tx) => {
          const offer = await tx.bookingOffer.create({
            data: {
              id: offerId,
              bookingId: booking.id,
              driverId: candidate.driverId,
              vehicleId: candidate.vehicleId,
              attempt: attempts + 1,
              distanceToPickupM: candidate.distanceM,
              expiresAt: new Date(Date.now() + timeoutSeconds * 1000),
            },
          });
          const transition = await this.state.transition(
            booking.id,
            'MATCHED',
            { type: 'SYSTEM' },
            {
              tx,
              patch: { driverId: candidate.driverId, vehicleId: candidate.vehicleId },
            },
          );
          return { offer, transition };
        });
        await this.fleet.rememberOfferedDriver(booking.id, candidate.driverId);
        await this.expiry.schedule({
          offerId: created.offer.id,
          bookingId: booking.id,
          driverId: candidate.driverId,
          delayMs: offerExpireDelay(created.offer.expiresAt),
        });
        await this.events.emitAsync('booking.status_changed', created.transition);
        try {
          await this.events.emitAsync(OFFER_OPENED, {
            offerId: created.offer.id,
            bookingId: booking.id,
            driverId: candidate.driverId,
            branchId: booking.branchId,
            expiresAt: created.offer.expiresAt.toISOString(),
          });
        } catch (error) {
          this.logger.warn(
            `Offer ${created.offer.id} was saved before the driver was told: ${
              error instanceof Error ? error.message : 'unknown error'
            }`,
          );
        }
        return created.offer;
      } catch (error) {
        await this.releaseQuietly(booking.branchId, candidate.driverId, booking.id);
        if (isDriverConflict(error)) continue;
        throw error;
      }
    }
    return null;
  }

  /**
   * Drivers currently marked available within the radius, nearest first.
   * Nothing is reserved and nobody is offered.
   */
  async listNearby(bookingId: string, radiusKm: number): Promise<NearbyDriver[]> {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: bookingSelect,
    });
    if (!booking) return [];
    const pickup = booking.stops.find((stop) => stop.type === 'PICKUP') ?? booking.stops[0];
    if (!pickup) return [];

    const raw = await this.redis.call(
      'GEOSEARCH',
      geoAvailableKey(booking.branchId),
      'FROMLONLAT',
      String(pickup.lng),
      String(pickup.lat),
      'BYRADIUS',
      String(radiusKm),
      'km',
      'ASC',
      'COUNT',
      String(CANDIDATE_COUNT),
      'WITHDIST',
    );
    const hits = parseGeoHits(raw);
    if (!hits.length) return [];

    const pipe = this.redis.pipeline();
    for (const hit of hits) {
      pipe.hmget(driverKey(hit.driverId), ...NEARBY_FIELDS);
    }
    const rows = await pipe.exec();
    const nowMs = Date.now();
    const maxAgeSeconds = this.readInt('DRIVER_LOCATION_MAX_AGE_SECONDS', 30);
    const nearby: NearbyDriver[] = [];
    hits.forEach((hit, index) => {
      const row = rows?.[index];
      if (!row || row[0]) return;
      const fields = row[1] as (string | null)[];
      const driver = describeNearby(hit, fields, {
        bookingVehicleType: booking.vehicleType.name,
        vanOnly: booking.vanOnly,
        ladyDriverOnly: booking.ladyDriverOnly,
        nowMs,
        maxAgeSeconds,
      });
      if (driver) nearby.push(driver);
    });
    return nearby.sort((left, right) => left.distanceM - right.distanceM);
  }

  private async rankEligible(
    booking: BookingForMatch,
    pickup: { lat: number; lng: number },
    radiusKm: number,
  ) {
    const raw = await this.redis.call(
      'GEOSEARCH',
      geoAvailableKey(booking.branchId),
      'FROMLONLAT',
      String(pickup.lng),
      String(pickup.lat),
      'BYRADIUS',
      String(radiusKm),
      'km',
      'ASC',
      'COUNT',
      String(CANDIDATE_COUNT),
      'WITHDIST',
    );
    const hits = parseGeoHits(raw);
    if (!hits.length) return [];

    const offered = new Set(await this.redis.smembers(offeredDriversKey(booking.id)));
    const pipe = this.redis.pipeline();
    for (const hit of hits) {
      pipe.hmget(driverKey(hit.driverId), ...HASH_FIELDS);
    }
    const rows = await pipe.exec();
    const nowMs = Date.now();
    const maxAgeSeconds = this.readInt('DRIVER_LOCATION_MAX_AGE_SECONDS', 30);
    const eligible: MatchCandidate[] = [];
    hits.forEach((hit, index) => {
      const row = rows?.[index];
      if (!row || row[0]) return;
      const fields = row[1] as (string | null)[];
      const candidate = toCandidate(hit, fields, {
        bookingVehicleType: booking.vehicleType.name,
        vanOnly: booking.vanOnly,
        ladyDriverOnly: booking.ladyDriverOnly,
        alreadyOffered: offered.has(hit.driverId),
        nowMs,
        maxAgeSeconds,
      });
      if (candidate) eligible.push(candidate);
    });
    return rankCandidates(eligible);
  }

  private async ensureSearchStarted(booking: BookingForMatch) {
    if (booking.searchStartedAt) return booking.searchStartedAt;
    const started = new Date();
    await this.prisma.booking.updateMany({
      where: { id: booking.id, searchStartedAt: null },
      data: { searchStartedAt: started },
    });
    const fresh = await this.prisma.booking.findUnique({
      where: { id: booking.id },
      select: { searchStartedAt: true },
    });
    return fresh?.searchStartedAt ?? started;
  }

  private async rejoinOpenOffer(bookingId: string) {
    const open = await this.prisma.bookingOffer.findFirst({
      where: { bookingId, status: 'OFFERED' },
    });
    if (!open) return null;
    await this.fleet.rememberOfferedDriver(bookingId, open.driverId);
    await this.expiry.schedule({
      offerId: open.id,
      bookingId,
      driverId: open.driverId,
      delayMs: offerExpireDelay(open.expiresAt),
    });
    return open;
  }

  private async releaseQuietly(branchId: string, driverId: string, bookingId: string) {
    try {
      await this.fleet.releaseOffer({ branchId, driverId, bookingId });
    } catch (error) {
      this.logger.warn(
        `Could not release ${driverId} after a failed offer: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }

  private radiiKm() {
    const raw = this.config.get<string>('SEARCH_RADII_KM') ?? '3,6,10';
    const radii = raw
      .split(',')
      .map((part) => Number(part.trim()))
      .filter((value) => Number.isFinite(value) && value > 0);
    return radii.length ? radii : [3, 6, 10];
  }

  private readInt(key: string, fallback: number) {
    const raw = this.config.get<string | number>(key);
    if (raw === undefined || raw === '') return fallback;
    const value = typeof raw === 'number' ? raw : Number(raw);
    if (!Number.isFinite(value) || value < 0) return fallback;
    return Math.floor(value);
  }
}

/** Fire one second after the offer's expiresAt so a last-moment accept wins the row. */
export function offerExpireDelay(expiresAt: Date, now = Date.now()) {
  return expiresAt.getTime() + 1000 - now;
}

/** 3 km, then 6, then 10, spread across the search window. */
export function radiusFor(
  elapsedSeconds: number,
  radiiKm: readonly number[],
  windowSeconds: number,
) {
  if (!radiiKm.length) return 0;
  const elapsed = Math.max(0, elapsedSeconds);
  if (radiiKm.length === 1 || windowSeconds <= 0) return radiiKm[radiiKm.length - 1];
  const slice = windowSeconds / radiiKm.length;
  const index = Math.min(radiiKm.length - 1, Math.floor(elapsed / slice));
  return radiiKm[index];
}

/** Nearest band first. Inside about 200 m, the driver who has waited longest goes first. */
export function rankCandidates<T extends MatchCandidate>(candidates: readonly T[]) {
  return [...candidates].sort((left, right) => {
    const band =
      Math.floor(left.distanceM / SAME_BLOCK_METERS) -
      Math.floor(right.distanceM / SAME_BLOCK_METERS);
    if (band !== 0) return band;
    const leftWait = left.availableSince ?? Number.POSITIVE_INFINITY;
    const rightWait = right.availableSince ?? Number.POSITIVE_INFINITY;
    if (leftWait !== rightWait) return leftWait - rightWait;
    return left.distanceM - right.distanceM;
  });
}

export function describeNearby(
  hit: { driverId: string; distanceM: number },
  fields: (string | null)[],
  rule: {
    bookingVehicleType: string;
    vanOnly: boolean;
    ladyDriverOnly: boolean;
    nowMs: number;
    maxAgeSeconds: number;
  },
): NearbyDriver | null {
  const [status, vehicleType, ladyDriverEligible, ts, name, unit, vehicleId] = fields;
  if (status !== 'AVAILABLE' || !vehicleId) return null;
  const reasons: CandidateReason[] = [];
  const seenAt = Number(ts);
  if (!Number.isFinite(seenAt) || rule.nowMs - seenAt > rule.maxAgeSeconds * 1000) {
    reasons.push('STALE_LOCATION');
  }
  const driverType = (vehicleType ?? '').trim().toLowerCase();
  const wanted = rule.bookingVehicleType.trim().toLowerCase();
  if (!driverType || driverType !== wanted) reasons.push('VEHICLE_TYPE_MISMATCH');
  if (rule.vanOnly && driverType !== 'minivan') reasons.push('NOT_VAN');
  if (rule.ladyDriverOnly && ladyDriverEligible !== '1') reasons.push('NOT_LADY_ELIGIBLE');
  return {
    driverId: hit.driverId,
    name: (name ?? '').trim(),
    unit: (unit ?? '').trim(),
    vehicleId,
    distanceM: hit.distanceM,
    eligible: reasons.length === 0,
    reasons,
  };
}

function toCandidate(
  hit: { driverId: string; distanceM: number },
  fields: (string | null)[],
  rule: {
    bookingVehicleType: string;
    vanOnly: boolean;
    ladyDriverOnly: boolean;
    alreadyOffered: boolean;
    nowMs: number;
    maxAgeSeconds: number;
  },
): MatchCandidate | null {
  const [status, vehicleType, ladyDriverEligible, ts, availableSince, vehicleId] = fields;
  if (!vehicleId) return null;
  if (status !== 'AVAILABLE' || rule.alreadyOffered) return null;
  const seenAt = Number(ts);
  if (!Number.isFinite(seenAt) || rule.nowMs - seenAt > rule.maxAgeSeconds * 1000) return null;
  const driverType = (vehicleType ?? '').trim().toLowerCase();
  const wanted = rule.bookingVehicleType.trim().toLowerCase();
  if (!driverType || driverType !== wanted) return null;
  if (rule.vanOnly && driverType !== 'minivan') return null;
  if (rule.ladyDriverOnly && ladyDriverEligible !== '1') return null;
  const waiting = Number(availableSince);
  return {
    driverId: hit.driverId,
    vehicleId,
    distanceM: hit.distanceM,
    availableSince: Number.isFinite(waiting) ? waiting : null,
  };
}

function parseGeoHits(raw: unknown) {
  if (!Array.isArray(raw)) return [];
  const hits: { driverId: string; distanceM: number }[] = [];
  for (const row of raw) {
    if (!Array.isArray(row) || row.length < 2) continue;
    const driverId = String(row[0]);
    const kilometers = Number(row[1]);
    if (!driverId || !Number.isFinite(kilometers)) continue;
    hits.push({ driverId, distanceM: Math.round(kilometers * 1000) });
  }
  return hits;
}

/** Offers from an earlier search do not count after a passenger retry moves searchStartedAt. */
export function offersInThisSearch(bookingId: string, searchStartedAt: Date | null) {
  return {
    bookingId,
    ...(searchStartedAt ? { offeredAt: { gte: searchStartedAt } } : {}),
  };
}

function isDriverConflict(error: unknown) {
  if (error instanceof ConflictException) return false;
  if (!(error instanceof Prisma.PrismaClientKnownRequestError) || error.code !== 'P2002') {
    return false;
  }
  const target = Array.isArray(error.meta?.target)
    ? error.meta.target.join(' ')
    : String(error.meta?.target ?? error.message);
  return /driver/i.test(target);
}
