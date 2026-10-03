import {
  BadRequestException,
  ConflictException,
  Inject,
  Injectable,
  InternalServerErrorException,
  Logger,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { OFFER_RESOLVED } from '../dispatch/offer-events.js';
import {
  driverStateSchema,
  fleetDriverSchema,
  type DriverPresenceState,
  type DriverStateSnapshot,
  type FleetDriver,
} from '@bridgecabs/shared-types';
import { Prisma, type BookingStatus, type ShiftEndReason } from '@prisma/client';
import type { Redis } from 'ioredis';
import { LIVE_BOOKING_STATUSES } from '../bookings/booking-transitions.js';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import {
  assertDocumentsPresent,
  missingRequiredDocumentCodes,
} from '../documents/required-documents.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { REDIS } from '../redis/redis.constants.js';
import {
  DRIVER_HASH_FIELDS,
  driverKey,
  geoAvailableKey,
  LOC_BUFFER_KEY,
  offerReserveKey,
  offeredDriversKey,
  onlineKey,
  presenceKey,
  sessionKey,
} from '../redis/redis.keys.js';
import {
  driverIdReleasedBy,
  driverOfferSnapshot,
  passengerFirstName,
  presenceFromBooking,
  presenceOnBookingStatus,
} from './fleet-presence.js';
import { LocationConsentService } from './location-consent.service.js';
import { shouldSampleLocation } from './location-sample.js';

const shiftVehicleSelect = {
  id: true,
  unitNumber: true,
  plateNumber: true,
  active: true,
  branchId: true,
  vehicleType: { select: { name: true } },
} satisfies Prisma.VehicleSelect;

type ShiftVehicle = Prisma.VehicleGetPayload<{ select: typeof shiftVehicleSelect }>;

type PublishInput = {
  driverId: string;
  branchId: string;
  status: DriverPresenceState;
  version: number;
  name: string;
  unit: string;
  vehicleType: string;
  vehicleId: string;
  ladyDriverEligible: boolean;
  bookingId: string | null;
};

type StartResult =
  | { mode: 'existing'; driverId: string }
  | { mode: 'started'; publish: PublishInput };

/**
 * Sole writer of the fleet Redis keys: driver hash, presence, online set,
 * available geo, offer reservation, driver session, and the location history buffer.
 * Location pings go through updateLocation so longitude stays before latitude.
 */
@Injectable()
export class FleetStateService {
  private readonly logger = new Logger(FleetStateService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly consent: LocationConsentService,
    private readonly events: EventEmitter2,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  async startShift(user: AuthUser, vehicleId?: string) {
    let result: StartResult;
    try {
      result = await this.prisma.$transaction((tx) =>
        this.prepareStart(tx, user, vehicleId),
      );
    } catch (error) {
      if (!this.isOpenShiftConflict(error)) throw error;
      const driver = await this.driverForUser(user.userId);
      await this.repairOnline(driver.id);
      return this.snapshot(driver.id);
    }

    if (result.mode === 'started') {
      await this.writeOnline(result.publish);
      return this.snapshot(result.publish.driverId);
    }
    await this.repairOnline(result.driverId);
    return this.snapshot(result.driverId);
  }

  async endShift(user: AuthUser) {
    const driver = await this.driverForUser(user.userId);
    await this.closeShift(driver.id, driver.branchId, {
      force: false,
      endedById: user.userId,
      endReason: 'MANUAL',
      endNote: null,
    });
    return this.snapshot(driver.id);
  }

  async away(user: AuthUser) {
    const driver = await this.driverForUser(user.userId);
    const shift = await this.openShift(driver.id);
    if (!shift) throw new ConflictException('Driver is not on shift');
    const status = await this.redis.hget(driverKey(driver.id), DRIVER_HASH_FIELDS.status);
    if (status !== 'AVAILABLE') {
      throw new ConflictException('Driver is not available');
    }
    const live = await this.liveBooking(driver.id);
    if (live) throw new ConflictException('Driver has a live booking');
    const version = await this.prisma.$transaction((tx) => this.bump(tx, driver.id));
    await this.writeOnline(this.publishFrom(driver, shift.vehicle, version, null, 'AWAY'));
    return this.snapshot(driver.id);
  }

  async back(user: AuthUser) {
    const driver = await this.driverForUser(user.userId);
    const shift = await this.openShift(driver.id);
    if (!shift) throw new ConflictException('Driver is not on shift');
    const status = await this.redis.hget(driverKey(driver.id), DRIVER_HASH_FIELDS.status);
    if (status !== 'AWAY') throw new ConflictException('Driver is not away');
    const live = await this.liveBooking(driver.id);
    const version = await this.prisma.$transaction((tx) => this.bump(tx, driver.id));
    await this.writeOnline(
      this.publishFrom(
        driver,
        shift.vehicle,
        version,
        live?.id ?? null,
        presenceFromBooking(live?.status ?? null),
      ),
    );
    return this.snapshot(driver.id);
  }

  async state(user: AuthUser) {
    const driver = await this.driverForUser(user.userId);
    return this.snapshot(driver.id);
  }

  async forceOffline(driverId: string, user: AuthUser, reason: string) {
    const driver = await this.scopedDriver(driverId, user);
    await this.closeShift(driver.id, driver.branchId, {
      force: true,
      endedById: user.userId,
      endReason: 'ADMIN_FORCED',
      endNote: reason,
    });
    return this.snapshot(driver.id);
  }

  async updateLocation(
    driverId: string,
    point: {
      lng: number;
      lat: number;
      heading?: number;
      speedMps?: number;
      accuracyM?: number;
      nowMs?: number;
    },
  ) {
    const branchId = await this.redis.hget(
      driverKey(driverId),
      DRIVER_HASH_FIELDS.branchId,
    );
    if (!branchId) return 0;
    const updated = await this.redis.updateDriverLocation(
      driverKey(driverId),
      geoAvailableKey(branchId),
      presenceKey(driverId),
      String(point.lng),
      String(point.lat),
      point.heading == null ? '' : String(point.heading),
      point.speedMps == null ? '' : String(point.speedMps),
      point.accuracyM == null ? '' : String(point.accuracyM),
      String(point.nowMs ?? Date.now()),
      String(this.presenceTtl()),
      driverId,
    );
    return Number(updated);
  }

  /**
   * Atomically claim an AVAILABLE driver for one offer.
   * Returns false when another writer already took them.
   */
  async reserveOffer(input: {
    driverId: string;
    branchId: string;
    offerId: string;
    bookingId: string;
    ttlSeconds: number;
  }) {
    const ttl = Math.floor(input.ttlSeconds);
    if (!Number.isFinite(ttl) || ttl < 1) return false;
    const reserved = await this.redis.reserveOffer(
      driverKey(input.driverId),
      geoAvailableKey(input.branchId),
      offerReserveKey(input.driverId),
      input.offerId,
      input.bookingId,
      String(ttl),
      input.driverId,
    );
    return Number(reserved) === 1;
  }

  /**
   * Reverse a reservation only while this booking still has the driver OFFERED.
   * Returns false when the driver has already moved on.
   */
  async releaseOffer(input: { driverId: string; branchId: string; bookingId: string }) {
    const released = await this.redis.releaseOffer(
      driverKey(input.driverId),
      geoAvailableKey(input.branchId),
      offerReserveKey(input.driverId),
      input.bookingId,
      input.driverId,
      String(Date.now()),
    );
    return Number(released) === 1;
  }

  /** A passenger retry may offer drivers who were already tried in the previous search. */
  async clearOfferedDrivers(bookingId: string) {
    await this.redis.del(offeredDriversKey(bookingId));
  }

  /** Remember that this driver was already offered the booking. The set lives for one hour. */
  async rememberOfferedDriver(bookingId: string, driverId: string) {
    const key = offeredDriversKey(bookingId);
    const pipe = this.redis.multi();
    pipe.sadd(key, driverId);
    pipe.expire(key, 60 * 60);
    await this.exec(pipe);
  }

  /** Live point for the passenger on this driver's active trip. No trail and no contact fields. */
  async sharedPosition(driverId: string) {
    const [lat, lng, heading, ts] = await this.redis.hmget(
      driverKey(driverId),
      DRIVER_HASH_FIELDS.lat,
      DRIVER_HASH_FIELDS.lng,
      DRIVER_HASH_FIELDS.heading,
      DRIVER_HASH_FIELDS.ts,
    );
    const latitude = Number(lat);
    const longitude = Number(lng);
    if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) return null;
    const headingValue = heading ? Number(heading) : null;
    const tsValue = ts ? Number(ts) : null;
    return {
      lat: latitude,
      lng: longitude,
      heading: headingValue != null && Number.isFinite(headingValue) ? headingValue : null,
      ts: tsValue != null && Number.isFinite(tsValue) ? tsValue : null,
    };
  }

  /**
   * A driver reserved for this same booking can still be manually assigned.
   * The offer is cancelled in that transaction, then Redis is released after commit.
   */
  async assertAvailableForAssign(driverId: string, bookingId?: string) {
    const [status, reservedFor] = await this.redis.hmget(
      driverKey(driverId),
      DRIVER_HASH_FIELDS.status,
      DRIVER_HASH_FIELDS.bookingId,
    );
    if (status === 'AVAILABLE') return;
    if (bookingId && status === 'OFFERED' && reservedFor === bookingId) return;
    throw new ConflictException('DRIVER_NOT_AVAILABLE');
  }

  async driverIdForUser(userId: string) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId },
      select: { id: true },
    });
    return driver?.id ?? null;
  }

  /** Returns the socket id this connection replaced, if one was stored. */
  async claimDriverSession(driverId: string, socketId: string) {
    const previous = await this.redis.set(sessionKey(driverId), socketId, 'GET');
    if (!previous || previous === socketId) return null;
    return previous;
  }

  async recordDriverPing(
    driverId: string,
    point: {
      lng: number;
      lat: number;
      heading?: number;
      speedMps?: number;
      accuracyM?: number;
      recordedAt: string;
      receivedAtMs: number;
    },
  ) {
    const applied = await this.updateLocation(driverId, {
      lng: point.lng,
      lat: point.lat,
      heading: point.heading,
      speedMps: point.speedMps,
      accuracyM: point.accuracyM,
      nowMs: point.receivedAtMs,
    });
    if (!applied) return null;
    const key = driverKey(driverId);
    const [branchId, bookingId, status, histAt] = await this.redis.hmget(
      key,
      DRIVER_HASH_FIELDS.branchId,
      DRIVER_HASH_FIELDS.bookingId,
      DRIVER_HASH_FIELDS.status,
      DRIVER_HASH_FIELDS.histAt,
    );
    if (!branchId) return null;
    const lastSample = histAt ? Number(histAt) : null;
    if (
      !shouldSampleLocation(
        status,
        lastSample != null && Number.isFinite(lastSample) ? lastSample : null,
        point.receivedAtMs,
      )
    ) {
      return branchId;
    }
    const buffered = this.redis.multi();
    buffered.rpush(
      LOC_BUFFER_KEY,
      JSON.stringify({
        driverId,
        bookingId: bookingId || null,
        lat: point.lat,
        lng: point.lng,
        speedMps: point.speedMps ?? null,
        heading: point.heading ?? null,
        accuracyM: point.accuracyM ?? null,
        recordedAt: point.recordedAt,
      }),
    );
    buffered.hset(key, DRIVER_HASH_FIELDS.histAt, String(point.receivedAtMs));
    await this.exec(buffered);
    return branchId;
  }

  /** Ends an open shift after the presence key has been stale past the cutoff. */
  async endConnectionLost(driverId: string, branchId: string) {
    try {
      await this.closeShift(driverId, branchId, {
        force: false,
        endedById: null,
        endReason: 'CONNECTION_LOST',
        endNote: null,
      });
    } catch (error) {
      if (error instanceof ConflictException) return;
      throw error;
    }
  }

  /**
   * Apply a committed booking status to the driver's hash.
   * The driver is free at dropoff. Payment statuses do not change presence.
   */
  async syncFromBooking(event: {
    bookingId: string;
    to: BookingStatus;
    prevDriverId?: string | null;
    driverId?: string | null;
  }) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: event.bookingId },
      select: { id: true, branchId: true, driverId: true, status: true },
    });
    if (!booking) return null;
    const presence = presenceOnBookingStatus(event.to);
    if (!presence) return { branchId: booking.branchId, driver: null };

    const releasing =
      event.to === 'SEARCHING_DRIVER' ||
      event.to === 'CANCELLED' ||
      event.to === 'NO_DRIVER_FOUND' ||
      event.to === 'TRIP_COMPLETED';
    let driverId: string | null;
    let status = presence;
    let bookingId: string | null = booking.id;
    if (releasing) {
      bookingId = null;
      status = 'AVAILABLE';
      if (event.to === 'TRIP_COMPLETED') {
        driverId = event.driverId !== undefined ? event.driverId : booking.driverId;
      } else if (event.prevDriverId !== undefined) {
        driverId = event.prevDriverId;
      } else {
        driverId = driverIdReleasedBy(
          event.to,
          booking,
          await this.assignmentDriverIds(booking.id),
        );
      }
      if (!driverId) return { branchId: booking.branchId, driver: null };
      const live = await this.liveBooking(driverId);
      if (live) return { branchId: booking.branchId, driver: null };
      const current = await this.redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status);
      if (current === 'AWAY') status = 'AWAY';
    } else {
      driverId = event.driverId !== undefined ? event.driverId : booking.driverId;
      if (!driverId) return { branchId: booking.branchId, driver: null };
    }

    const driver = await this.publishDriver(driverId, status, bookingId);
    return { branchId: booking.branchId, driver };
  }

  /** Rebuild open shifts Redis lost, and clear hashes that still point at a finished booking. */
  async reconcile() {
    await this.expireOffersMissingReserve();
    const shifts = await this.prisma.driverShift.findMany({
      where: { endedAt: null },
      select: { driverId: true },
    });
    const changes: Array<{
      driverId: string;
      branchId: string;
      snapshot: DriverStateSnapshot;
    }> = [];
    for (const shift of shifts) {
      try {
        const change = await this.reconcileDriver(shift.driverId);
        if (change) changes.push(change);
      } catch (error) {
        this.logger.warn(
          `Fleet reconcile skipped ${shift.driverId}: ${
            error instanceof Error ? error.message : 'unknown error'
          }`,
        );
      }
    }
    return changes;
  }

  async fleetDrivers(branchId: string, driverIds?: string[]) {
    const ids = driverIds ?? (await this.redis.smembers(onlineKey(branchId)));
    if (!ids.length) return [];
    const pipe = this.redis.pipeline();
    for (const id of ids) pipe.hgetall(driverKey(id));
    const rows = await pipe.exec();
    if (!rows) return [];
    const drivers: FleetDriver[] = [];
    ids.forEach((id, index) => {
      const row = rows[index];
      if (!row || row[0]) return;
      const hash = row[1] as Record<string, string>;
      if (hash[DRIVER_HASH_FIELDS.branchId] !== branchId) return;
      const driver = this.toFleetDriver(id, hash);
      if (driver) drivers.push(driver);
    });
    return drivers;
  }

  private async prepareStart(
    tx: Prisma.TransactionClient,
    user: AuthUser,
    vehicleId?: string,
  ): Promise<StartResult> {
    const driver = await tx.driver.findUnique({ where: { userId: user.userId } });
    if (!driver) throw new NotFoundException();

    const open = await tx.driverShift.findFirst({
      where: { driverId: driver.id, endedAt: null },
    });
    if (open) return { mode: 'existing', driverId: driver.id };

    if (driver.status !== 'APPROVED') {
      throw new UnprocessableEntityException('Driver is not approved');
    }

    const vehicle = await this.resolveVehicle(tx, driver, vehicleId);
    const missing = await missingRequiredDocumentCodes(tx, {
      driverId: driver.id,
      vehicleId: vehicle.id,
    });
    assertDocumentsPresent(missing);
    await this.consent.assertAccepted(tx, driver.id);

    const booking = await tx.booking.findFirst({
      where: { driverId: driver.id, status: { in: [...LIVE_BOOKING_STATUSES] } },
      select: { id: true, status: true },
    });
    await tx.driverShift.create({
      data: {
        driverId: driver.id,
        vehicleId: vehicle.id,
        branchId: driver.branchId,
      },
    });
    const version = await this.bump(tx, driver.id);

    return {
      mode: 'started',
      publish: this.publishFrom(
        driver,
        vehicle,
        version,
        booking?.id ?? null,
        presenceFromBooking(booking?.status ?? null),
      ),
    };
  }

  private async closeShift(
    driverId: string,
    branchId: string,
    input: {
      force: boolean;
      endedById: string | null;
      endReason: ShiftEndReason;
      endNote: string | null;
    },
  ) {
    await this.prisma.$transaction(async (tx) => {
      const open = await tx.driverShift.findFirst({
        where: { driverId, endedAt: null },
      });
      if (!open) return;

      if (!input.force) {
        const live = await tx.booking.findFirst({
          where: { driverId, status: { in: [...LIVE_BOOKING_STATUSES] } },
          select: { id: true },
        });
        if (live) throw new ConflictException('Driver has a live booking');
      }

      await this.bump(tx, driverId);
      await tx.driverShift.update({
        where: { id: open.id },
        data: {
          endedAt: new Date(),
          endReason: input.endReason,
          endedById: input.endedById,
          endNote: input.endNote,
        },
      });
    });
    await this.clearOnline(driverId, branchId);
  }

  private async repairOnline(driverId: string) {
    const status = await this.redis.hget(driverKey(driverId), DRIVER_HASH_FIELDS.status);
    if (status) return;

    const driver = await this.prisma.driver.findUnique({ where: { id: driverId } });
    const shift = await this.openShift(driverId);
    if (!driver || !shift) return;

    let version = driver.presenceVersion;
    if (version < 1) {
      version = await this.prisma.$transaction((tx) => this.bump(tx, driverId));
    }
    const booking = await this.liveBooking(driverId);
    await this.writeOnline(
      this.publishFrom(
        driver,
        shift.vehicle,
        version,
        booking?.id ?? null,
        presenceFromBooking(booking?.status ?? null),
      ),
    );
  }

  private async resolveVehicle(
    tx: Prisma.TransactionClient,
    driver: { id: string; branchId: string },
    vehicleId?: string,
  ): Promise<ShiftVehicle> {
    const open = await tx.driverVehicleAssignment.findFirst({
      where: { driverId: driver.id, endedAt: null },
      include: { vehicle: { select: shiftVehicleSelect } },
    });

    if (!vehicleId) {
      if (!open) throw new UnprocessableEntityException('Driver has no vehicle');
      if (!open.vehicle.active) throw new BadRequestException('Vehicle is not active');
      if (open.vehicle.branchId !== driver.branchId) {
        throw new BadRequestException('Vehicle is not available in this branch');
      }
      return open.vehicle;
    }

    const vehicle = await tx.vehicle.findFirst({
      where: { id: vehicleId },
      select: shiftVehicleSelect,
    });
    if (!vehicle || !vehicle.active || vehicle.branchId !== driver.branchId) {
      throw new BadRequestException('Vehicle is not available in this branch');
    }
    if (open && open.vehicleId !== vehicle.id) {
      throw new ConflictException('Driver is assigned to a different vehicle');
    }
    return vehicle;
  }

  private publishFrom(
    driver: {
      id: string;
      branchId: string;
      firstName: string;
      lastName: string;
      ladyDriverEligible: boolean | null;
    },
    vehicle: { id: string; unitNumber: string | null; vehicleType: { name: string } },
    version: number,
    bookingId: string | null,
    status: DriverPresenceState,
  ): PublishInput {
    return {
      driverId: driver.id,
      branchId: driver.branchId,
      status,
      version,
      name: `${driver.firstName} ${driver.lastName}`.trim(),
      unit: vehicle.unitNumber ?? '',
      vehicleType: vehicle.vehicleType.name,
      vehicleId: vehicle.id,
      ladyDriverEligible: driver.ladyDriverEligible === true,
      bookingId,
    };
  }

  private async writeOnline(input: PublishInput, options?: { stale?: boolean }) {
    const key = driverKey(input.driverId);
    const [lat, lng, currentStatus, availableSince] = await this.redis.hmget(
      key,
      DRIVER_HASH_FIELDS.lat,
      DRIVER_HASH_FIELDS.lng,
      DRIVER_HASH_FIELDS.status,
      DRIVER_HASH_FIELDS.availableSince,
    );
    const pipe = this.redis.multi();
    pipe.hset(key, {
      [DRIVER_HASH_FIELDS.status]: input.status,
      [DRIVER_HASH_FIELDS.version]: String(input.version),
      [DRIVER_HASH_FIELDS.branchId]: input.branchId,
      [DRIVER_HASH_FIELDS.name]: input.name,
      [DRIVER_HASH_FIELDS.unit]: input.unit,
      [DRIVER_HASH_FIELDS.vehicleType]: input.vehicleType,
      [DRIVER_HASH_FIELDS.vehicleId]: input.vehicleId,
      [DRIVER_HASH_FIELDS.ladyDriverEligible]: input.ladyDriverEligible ? '1' : '0',
    });
    if (input.status === 'AVAILABLE' && (currentStatus !== 'AVAILABLE' || !availableSince)) {
      pipe.hset(key, DRIVER_HASH_FIELDS.availableSince, String(Date.now()));
    } else if (input.status !== 'AVAILABLE') {
      pipe.hdel(key, DRIVER_HASH_FIELDS.availableSince);
    }
    if (options?.stale) {
      pipe.hset(key, DRIVER_HASH_FIELDS.staleSince, String(Date.now()));
    } else {
      pipe.hdel(key, DRIVER_HASH_FIELDS.staleSince);
    }
    if (input.bookingId) {
      pipe.hset(key, DRIVER_HASH_FIELDS.bookingId, input.bookingId);
    } else {
      pipe.hdel(key, DRIVER_HASH_FIELDS.bookingId);
    }
    pipe.sadd(onlineKey(input.branchId), input.driverId);
    pipe.set(presenceKey(input.driverId), '1', 'EX', this.presenceTtl());
    const geo = geoAvailableKey(input.branchId);
    if (input.status === 'AVAILABLE' && lat && lng) {
      pipe.geoadd(geo, lng, lat, input.driverId);
    } else {
      pipe.zrem(geo, input.driverId);
    }
    await this.exec(pipe);
  }

  private async clearOnline(driverId: string, branchId: string) {
    const pipe = this.redis.multi();
    pipe.zrem(geoAvailableKey(branchId), driverId);
    pipe.srem(onlineKey(branchId), driverId);
    pipe.del(presenceKey(driverId), driverKey(driverId));
    await this.exec(pipe);
  }

  /** Notes changed on an assigned trip. Bump v and rebuild the snapshot the driver already has. */
  async republishSnapshot(driverId: string) {
    const driver = await this.prisma.driver.findUnique({
      where: { id: driverId },
      select: { id: true, branchId: true },
    });
    if (!driver) return null;
    const version = await this.prisma.$transaction((tx) => this.bump(tx, driverId));
    if (await this.redis.exists(driverKey(driverId))) {
      await this.redis.hset(
        driverKey(driverId),
        DRIVER_HASH_FIELDS.version,
        String(version),
      );
    }
    return {
      driverId,
      branchId: driver.branchId,
      snapshot: await this.snapshot(driverId),
    };
  }

  private async snapshot(driverId: string) {
    const [driver, shift, booking, hash] = await Promise.all([
      this.prisma.driver.findUnique({
        where: { id: driverId },
        select: { presenceVersion: true },
      }),
      this.prisma.driverShift.findFirst({
        where: { driverId, endedAt: null },
      }),
      this.prisma.booking.findFirst({
        where: { driverId, status: { in: [...LIVE_BOOKING_STATUSES] } },
        select: {
          id: true,
          trackingId: true,
          status: true,
          passengerName: true,
          scheduledAt: true,
          notes: true,
          quotedFareCents: true,
          paymentMethod: true,
          vanOnly: true,
          ladyDriverOnly: true,
          distanceMeters: true,
          passenger: { select: { firstName: true } },
          stops: {
            orderBy: { sequence: 'asc' },
            select: {
              id: true,
              sequence: true,
              type: true,
              address: true,
              lat: true,
              lng: true,
            },
          },
        },
      }),
      this.redis.hgetall(driverKey(driverId)),
    ]);

    const vehicle = shift
      ? await this.prisma.vehicle.findUnique({
          where: { id: shift.vehicleId },
          select: { id: true, unitNumber: true, plateNumber: true },
        })
      : null;
    const hashStatus = hash[DRIVER_HASH_FIELDS.status];
    const status = this.readStatus(hashStatus);
    const hashVersion = Number(hash[DRIVER_HASH_FIELDS.version]);
    const version = Number.isInteger(hashVersion)
      ? hashVersion
      : (driver?.presenceVersion ?? 0);

    const serverNow = new Date();
    const openOffer =
      status === 'OFFERED'
        ? await this.prisma.bookingOffer.findFirst({
            where: { driverId, status: 'OFFERED' },
            select: { id: true, bookingId: true, expiresAt: true, distanceToPickupM: true },
          })
        : null;

    return driverStateSchema.parse({
      v: version,
      status,
      shift:
        shift && vehicle
          ? {
              startedAt: shift.startedAt.toISOString(),
              vehicle: {
                id: vehicle.id,
                unitNumber: vehicle.unitNumber,
                plate: vehicle.plateNumber,
              },
            }
          : null,
      booking: booking
        ? {
            id: booking.id,
            trackingId: booking.trackingId,
            status: booking.status,
            stops: booking.stops,
            passengerFirstName: passengerFirstName(
              booking.passenger?.firstName,
              booking.passengerName,
            ),
            scheduledAt: booking.scheduledAt?.toISOString() ?? null,
            notes: booking.notes,
            quotedFareCents: booking.quotedFareCents,
          }
        : null,
      offer:
        openOffer && booking && openOffer.bookingId === booking.id
          ? driverOfferSnapshot(
              openOffer,
              {
                distanceMeters: booking.distanceMeters,
                quotedFareCents: booking.quotedFareCents,
                paymentMethod: booking.paymentMethod,
                vanOnly: booking.vanOnly,
                ladyDriverOnly: booking.ladyDriverOnly,
                notes: booking.notes,
                passengerName: booking.passengerName,
                passengerFirstName: booking.passenger?.firstName,
                stops: booking.stops,
              },
              serverNow,
            )
          : null,
    });
  }

  private toFleetDriver(id: string, hash: Record<string, string>) {
    const parsed = fleetDriverSchema.safeParse({
      id,
      v: Number(hash[DRIVER_HASH_FIELDS.version] || 0),
      status: hash[DRIVER_HASH_FIELDS.status],
      lat: this.coord(hash[DRIVER_HASH_FIELDS.lat]),
      lng: this.coord(hash[DRIVER_HASH_FIELDS.lng]),
      heading: this.coord(hash[DRIVER_HASH_FIELDS.heading]),
      speedMps: this.coord(hash[DRIVER_HASH_FIELDS.speed]),
      accuracyM: this.coord(hash[DRIVER_HASH_FIELDS.accuracy]),
      ts: hash[DRIVER_HASH_FIELDS.ts] ? Number(hash[DRIVER_HASH_FIELDS.ts]) : null,
      name: hash[DRIVER_HASH_FIELDS.name] ?? '',
      unit: hash[DRIVER_HASH_FIELDS.unit] ?? '',
      vehicleType: hash[DRIVER_HASH_FIELDS.vehicleType] ?? '',
      bookingId: hash[DRIVER_HASH_FIELDS.bookingId] || null,
      stale: Boolean(hash[DRIVER_HASH_FIELDS.staleSince]),
    });
    return parsed.success ? parsed.data : null;
  }

  private coord(value: string | undefined) {
    if (value == null || value === '') return null;
    const number = Number(value);
    return Number.isFinite(number) ? number : null;
  }

  private readStatus(value: string | undefined): DriverPresenceState {
    const known: readonly string[] = [
      'OFFLINE',
      'AVAILABLE',
      'OFFERED',
      'ASSIGNED',
      'EN_ROUTE_PICKUP',
      'ARRIVED',
      'ON_TRIP',
      'AWAY',
    ];
    if (value && known.includes(value)) return value as DriverPresenceState;
    return 'OFFLINE';
  }

  private async openShift(driverId: string) {
    const shift = await this.prisma.driverShift.findFirst({
      where: { driverId, endedAt: null },
    });
    if (!shift) return null;
    const vehicle = await this.prisma.vehicle.findUniqueOrThrow({
      where: { id: shift.vehicleId },
      select: shiftVehicleSelect,
    });
    return { ...shift, vehicle };
  }

  private async publishDriver(
    driverId: string,
    status: DriverPresenceState,
    bookingId: string | null,
    options?: { stale?: boolean },
  ) {
    const driver = await this.prisma.driver.findUnique({ where: { id: driverId } });
    const shift = await this.openShift(driverId);
    if (!driver || !shift) return null;
    const version = await this.prisma.$transaction((tx) => this.bump(tx, driverId));
    await this.writeOnline(
      this.publishFrom(driver, shift.vehicle, version, bookingId, status),
      options,
    );
    return {
      driverId,
      branchId: driver.branchId,
      snapshot: await this.snapshot(driverId),
    };
  }

  /**
   * A Redis flush drops the driver claim while Postgres still says OFFERED.
   * Expire that offer, return the booking to search, and let the status event free the driver.
   */
  private async expireOffersMissingReserve() {
    const offers = await this.prisma.bookingOffer.findMany({
      where: { status: 'OFFERED' },
      select: { id: true, bookingId: true, driverId: true },
    });
    for (const offer of offers) {
      if (await this.redis.exists(offerReserveKey(offer.driverId))) continue;
      try {
        await this.expireUnreservedOffer(offer);
      } catch (error) {
        this.logger.warn(
          `Offer ${offer.id} was not expired: ${
            error instanceof Error ? error.message : 'unknown error'
          }`,
        );
      }
    }
  }

  private async expireUnreservedOffer(offer: {
    id: string;
    bookingId: string;
    driverId: string;
  }) {
    const now = new Date();
    const result = await this.prisma.$transaction(async (tx) => {
      const expired = await tx.bookingOffer.updateMany({
        where: { id: offer.id, status: 'OFFERED' },
        data: { status: 'EXPIRED', respondedAt: now },
      });
      if (expired.count !== 1) return null;

      const booking = await tx.booking.findUnique({
        where: { id: offer.bookingId },
        select: { id: true, branchId: true, status: true, version: true, driverId: true },
      });
      if (!booking || booking.status !== 'MATCHED') {
        throw new Error('Offer is open but the booking is not matched');
      }
      const moved = await tx.booking.updateMany({
        where: { id: booking.id, status: 'MATCHED', version: booking.version },
        data: {
          status: 'SEARCHING_DRIVER',
          version: { increment: 1 },
          driverId: null,
          vehicleId: null,
        },
      });
      if (moved.count !== 1) throw new Error('Booking changed while expiring the offer');

      await tx.bookingStatusHistory.create({
        data: {
          bookingId: booking.id,
          fromStatus: 'MATCHED',
          toStatus: 'SEARCHING_DRIVER',
          actorType: 'SYSTEM',
          reason: 'Offer reservation lost',
        },
      });
      return {
        bookingId: booking.id,
        branchId: booking.branchId,
        from: 'MATCHED' as const,
        to: 'SEARCHING_DRIVER' as const,
        prevDriverId: booking.driverId ?? offer.driverId,
        driverId: null,
      };
    });
    if (!result) return;
    await this.events.emitAsync('booking.status_changed', result);
    await this.events.emitAsync(OFFER_RESOLVED, {
      offerId: offer.id,
      bookingId: offer.bookingId,
      driverId: offer.driverId,
      branchId: result.branchId,
      outcome: 'EXPIRED',
    });
  }

  private async reconcileDriver(driverId: string) {
    const hash = await this.redis.hgetall(driverKey(driverId));
    if (!hash[DRIVER_HASH_FIELDS.status]) {
      const live = await this.liveBooking(driverId);
      return this.publishDriver(
        driverId,
        presenceFromBooking(live?.status ?? null),
        live?.id ?? null,
        { stale: true },
      );
    }

    const bookingId = hash[DRIVER_HASH_FIELDS.bookingId];
    if (!bookingId) return null;
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { status: true },
    });
    const liveStatuses: readonly string[] = LIVE_BOOKING_STATUSES;
    if (booking && liveStatuses.includes(booking.status)) return null;

    const live = await this.liveBooking(driverId);
    const away = hash[DRIVER_HASH_FIELDS.status] === 'AWAY';
    return this.publishDriver(
      driverId,
      live ? presenceFromBooking(live.status) : away ? 'AWAY' : 'AVAILABLE',
      live?.id ?? null,
    );
  }

  private async assignmentDriverIds(bookingId: string) {
    const rows = await this.prisma.bookingAssignment.findMany({
      where: { bookingId },
      select: { driverId: true, endedAt: true, assignedAt: true },
    });
    rows.sort((left, right) => {
      if (left.endedAt == null && right.endedAt == null) {
        return right.assignedAt.getTime() - left.assignedAt.getTime();
      }
      if (left.endedAt == null) return 1;
      if (right.endedAt == null) return -1;
      return right.endedAt.getTime() - left.endedAt.getTime();
    });
    return rows.map((row) => row.driverId);
  }

  private async liveBooking(driverId: string) {
    return this.prisma.booking.findFirst({
      where: { driverId, status: { in: [...LIVE_BOOKING_STATUSES] } },
      select: { id: true, status: true },
    });
  }

  private async bump(tx: Prisma.TransactionClient, driverId: string) {
    const row = await tx.driver.update({
      where: { id: driverId },
      data: { presenceVersion: { increment: 1 } },
      select: { presenceVersion: true },
    });
    return row.presenceVersion;
  }

  private async driverForUser(userId: string) {
    const driver = await this.prisma.driver.findUnique({ where: { userId } });
    if (!driver) throw new NotFoundException();
    return driver;
  }

  private async scopedDriver(id: string, user: AuthUser) {
    if (user.role !== 'super_admin' && !user.branchId) {
      throw new NotFoundException();
    }
    const driver = await this.prisma.driver.findFirst({
      where: { id, ...branchWhere(user) },
    });
    if (!driver) throw new NotFoundException();
    return driver;
  }

  private presenceTtl() {
    const raw = Number(this.config.get('PRESENCE_TTL_SECONDS') ?? 45);
    return Number.isFinite(raw) && raw > 0 ? Math.floor(raw) : 45;
  }

  private async exec(pipe: ReturnType<Redis['multi']>) {
    const result = await pipe.exec();
    if (!result) throw new InternalServerErrorException('Redis unavailable');
  }

  private isOpenShiftConflict(error: unknown) {
    if (error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002') {
      return true;
    }
    return error instanceof Error && error.message.includes('one_open_shift_per_driver');
  }
}
