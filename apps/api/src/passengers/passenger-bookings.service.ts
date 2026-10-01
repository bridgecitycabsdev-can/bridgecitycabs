import {
  BadRequestException,
  ConflictException,
  Inject,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { BookingStatus, Prisma } from '@prisma/client';
import { assertScheduledAt } from '../bookings/booking-schedule.js';
import { BookingStateService } from '../bookings/booking-state.service.js';
import { TRANSITIONS } from '../bookings/booking-transitions.js';
import { newTrackingId } from '../bookings/tracking-id.js';
import type { AuthUser } from '../common/auth-user.js';
import {
  DISTANCE_SERVICE,
  type DistanceService,
} from '../fares/distance.service.js';
import { FaresService } from '../fares/fares.service.js';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type {
  PassengerCancelBookingDto,
  PassengerCreateBookingDto,
} from './dto/passenger-booking.dto.js';
import {
  PASSENGER_ACTIVE_STATUSES,
  PASSENGER_SHARE_LOCATION_STATUSES,
  passengerBookingInclude,
  stopType,
  toPassengerBooking,
  type PassengerBookingRow,
} from './passenger-booking.view.js';

@Injectable()
export class PassengerBookingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly state: BookingStateService,
    private readonly fares: FaresService,
    private readonly fleet: FleetStateService,
    private readonly config: ConfigService,
    private readonly events: EventEmitter2,
    @Inject(DISTANCE_SERVICE) private readonly distance: DistanceService,
  ) {}

  async create(dto: PassengerCreateBookingDto, user: AuthUser) {
    const passenger = await this.requireAccount(user);
    if (passenger.blocked) {
      throw new UnprocessableEntityException('Passenger is blocked');
    }
    this.assertStops(dto.stops);

    const vehicleType = await this.prisma.vehicleType.findUnique({
      where: { id: dto.vehicleTypeId },
    });
    if (!vehicleType) throw new NotFoundException();
    if (!vehicleType.active) {
      throw new UnprocessableEntityException('Vehicle type is not active');
    }

    const scheduledAt = dto.scheduledAt ? new Date(dto.scheduledAt) : null;
    if (scheduledAt) {
      assertScheduledAt(
        scheduledAt,
        new Date(),
        this.readInt('BOOKING_MIN_LEAD_MINUTES', 15),
        this.readInt('BOOKING_MAX_ADVANCE_DAYS', 30),
      );
    }

    const quote = await this.fares.quote(
      {
        branchId: dto.branchId,
        vehicleTypeId: dto.vehicleTypeId,
        zone: dto.zone,
        stops: dto.stops,
      },
      user,
    );

    const initial: BookingStatus = scheduledAt ? 'SCHEDULED' : 'CREATED';
    const openedAt = new Date(Date.now() - 1);
    const phone = passenger.phone;
    const passengerName = [passenger.firstName, passenger.lastName]
      .filter((part) => part && part.trim())
      .join(' ');

    const inserted = await this.insert({
      dto,
      user,
      passengerId: passenger.id,
      passengerName,
      phone,
      scheduledAt,
      initial,
      openedAt,
      meters: quote.distanceMeters,
      seconds: quote.durationSeconds,
      subtotalCents: quote.subtotalCents,
      taxCents: quote.taxCents,
    });

    const row = await this.load(inserted.id);
    await this.events.emitAsync('booking.created', {
      id: row.id,
      branchId: row.branchId,
      trackingId: row.trackingId,
      status: row.status,
      passengerName: row.passengerName,
      scheduledAt: row.scheduledAt?.toISOString() ?? null,
      quotedFareCents: row.quotedFareCents,
      vehicleType: { id: row.vehicleType.id, name: row.vehicleType.name },
      pickupAddress: pickupAddress(row),
    });
    if (inserted.opened) {
      await this.events.emitAsync('booking.status_changed', inserted.opened);
    }
    return toPassengerBooking(row, await this.etaSeconds(row));
  }

  async active(user: AuthUser) {
    const booking = await this.activeForUser(user.userId);
    if (!booking) throw new NotFoundException();
    return booking;
  }

  async activeForUser(userId: string) {
    const passenger = await this.prisma.passenger.findUnique({
      where: { userId },
      select: { id: true },
    });
    if (!passenger) return null;
    const booking = await this.prisma.booking.findFirst({
      where: {
        passengerId: passenger.id,
        status: { in: PASSENGER_ACTIVE_STATUSES },
      },
      orderBy: { createdAt: 'desc' },
      include: passengerBookingInclude,
    });
    if (!booking) return null;
    return toPassengerBooking(booking, await this.etaSeconds(booking));
  }

  async get(user: AuthUser, id: string) {
    const passenger = await this.requireAccount(user);
    const booking = await this.prisma.booking.findFirst({
      where: { id, passengerId: passenger.id },
      include: passengerBookingInclude,
    });
    if (!booking) throw new NotFoundException();
    return toPassengerBooking(booking, await this.etaSeconds(booking));
  }

  /** Snapshot for a status event. Phone numbers are not part of the view. */
  async broadcastSnapshot(bookingId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      include: passengerBookingInclude,
    });
    if (!booking) return null;
    return toPassengerBooking(booking, await this.etaSeconds(booking));
  }

  async cancel(user: AuthUser, id: string, dto: PassengerCancelBookingDto = {}) {
    const passenger = await this.requireAccount(user);
    const reason = dto.reason ?? 'PASSENGER_REQUEST';
    const note = dto.note?.trim() || null;
    const result = await this.prisma.$transaction(async (tx) => {
      const booking = await tx.booking.findFirst({
        where: { id, passengerId: passenger.id },
      });
      if (!booking) throw new NotFoundException();
      const allowed = TRANSITIONS[booking.status]?.CANCELLED;
      if (!allowed?.includes('PASSENGER')) {
        throw new ConflictException('This booking can no longer be cancelled');
      }
      await tx.bookingAssignment.updateMany({
        where: { bookingId: booking.id, endedAt: null },
        data: { endedAt: new Date(), endReason: 'BOOKING_CANCELLED' },
      });
      return this.state.transition(
        booking.id,
        'CANCELLED',
        { type: 'PASSENGER', userId: user.userId },
        {
          tx,
          reason,
          metadata: note ? { note } : undefined,
          patch: {
            cancelledBy: 'PASSENGER',
            cancelReason: reason,
            cancelNote: note,
          },
        },
      );
    });
    // OfferCloseListener cancels any offer still OFFERED once this event is out.
    await this.events.emitAsync('booking.status_changed', result);
    return this.present(result.bookingId);
  }

  async retry(user: AuthUser, id: string) {
    const passenger = await this.requireAccount(user);
    if (passenger.blocked) {
      throw new UnprocessableEntityException('Passenger is blocked');
    }
    const booking = await this.prisma.booking.findFirst({
      where: { id, passengerId: passenger.id },
      select: { id: true, status: true },
    });
    if (!booking) throw new NotFoundException();
    if (booking.status !== 'NO_DRIVER_FOUND') {
      throw new ConflictException('Only a booking with no driver can be retried');
    }
    await this.fleet.clearOfferedDrivers(booking.id);
    const result = await this.state.transition(
      booking.id,
      'SEARCHING_DRIVER',
      { type: 'PASSENGER', userId: user.userId },
      {
        reason: 'Passenger retried',
        patch: { searchStartedAt: new Date() },
      },
    );
    return this.present(result.bookingId);
  }

  private async insert(input: {
    dto: PassengerCreateBookingDto;
    user: AuthUser;
    passengerId: string;
    passengerName: string;
    phone: string;
    scheduledAt: Date | null;
    initial: BookingStatus;
    openedAt: Date;
    meters: number;
    seconds: number;
    subtotalCents: number;
    taxCents: number;
  }) {
    const branchId = await this.branchIdFor(input.user, input.dto.branchId);
    for (let attempt = 0; attempt < 5; attempt += 1) {
      try {
        return await this.prisma.$transaction(async (tx) => {
          const existing = await tx.booking.findFirst({
            where: {
              passengerId: input.passengerId,
              status: { in: PASSENGER_ACTIVE_STATUSES },
            },
            select: { id: true },
          });
          if (existing) {
            throw new ConflictException('You already have an active booking');
          }
          const created = await tx.booking.create({
            data: {
              trackingId: newTrackingId(),
              branchId,
              source: 'PASSENGER_APP',
              assignMode: 'AUTO',
              status: input.initial,
              passengerId: input.passengerId,
              passengerName: input.passengerName,
              passengerPhone: input.phone,
              createdById: input.user.userId,
              vehicleTypeId: input.dto.vehicleTypeId,
              vanOnly: input.dto.vanOnly,
              ladyDriverOnly: input.dto.ladyDriverOnly,
              zone: input.dto.zone,
              scheduledAt: input.scheduledAt,
              distanceMeters: input.meters,
              durationSeconds: input.seconds,
              quotedFareCents: input.subtotalCents,
              quotedTaxCents: input.taxCents,
              paymentMethod: input.dto.paymentMethod,
              notes: input.dto.notes?.trim(),
              stops: {
                create: input.dto.stops.map((stop, index) => ({
                  sequence: index + 1,
                  type: stopType(index, input.dto.stops.length),
                  address: stop.address.trim(),
                  lat: stop.lat,
                  lng: stop.lng,
                  placeId: stop.placeId,
                })),
              },
            },
          });
          await tx.bookingStatusHistory.create({
            data: {
              bookingId: created.id,
              fromStatus: null,
              toStatus: input.initial,
              actorType: 'PASSENGER',
              actorUserId: input.user.userId,
              createdAt: input.openedAt,
            },
          });
          const opened =
            input.initial === 'CREATED'
              ? await this.state.transition(
                  created.id,
                  'SEARCHING_DRIVER',
                  { type: 'SYSTEM' },
                  { tx },
                )
              : null;
          return { id: created.id, opened };
        });
      } catch (error) {
        if (error instanceof ConflictException) throw error;
        if (attempt < 4 && isTrackingCollision(error)) continue;
        if (isActivePassengerCollision(error)) {
          throw new ConflictException('You already have an active booking');
        }
        throw error;
      }
    }
    throw new InternalServerErrorException('Could not allocate a tracking id');
  }

  private async branchIdFor(user: AuthUser, requested?: string) {
    if (user.branchId) return user.branchId;
    if (requested) return requested;
    throw new BadRequestException('branchId is required');
  }

  private async present(id: string) {
    const booking = await this.load(id);
    return toPassengerBooking(booking, await this.etaSeconds(booking));
  }

  private async load(id: string) {
    return this.prisma.booking.findUniqueOrThrow({
      where: { id },
      include: passengerBookingInclude,
    });
  }

  /** Seconds from the distance service. That estimate is straight-line, not a routed drive time. */
  private async etaSeconds(booking: PassengerBookingRow) {
    if (booking.status === 'DRIVER_ARRIVED') return 0;
    const moving =
      booking.status === 'DRIVER_ASSIGNED' ||
      booking.status === 'DRIVER_ARRIVING' ||
      booking.status === 'TRIP_STARTED';
    if (!moving || !booking.driverId) return null;
    if (!PASSENGER_SHARE_LOCATION_STATUSES.includes(booking.status)) return null;
    const position = await this.fleet.sharedPosition(booking.driverId);
    if (!position) return null;
    const stops = [...booking.stops].sort((left, right) => left.sequence - right.sequence);
    const target = booking.status === 'TRIP_STARTED' ? stops[stops.length - 1] : stops[0];
    if (!target) return null;
    const trip = await this.distance.estimate(
      { lat: position.lat, lng: position.lng },
      { lat: target.lat, lng: target.lng },
    );
    return trip.seconds;
  }

  private async requireAccount(user: AuthUser) {
    const passenger = await this.prisma.passenger.findUnique({
      where: { userId: user.userId },
    });
    if (!passenger) throw new NotFoundException();
    return passenger;
  }

  private assertStops(stops: PassengerCreateBookingDto['stops']) {
    const pickup = stops[0];
    const dropoff = stops[stops.length - 1];
    if (!pickup || !dropoff) {
      throw new BadRequestException('At least two stops are required');
    }
    if (pickup.lat === dropoff.lat && pickup.lng === dropoff.lng) {
      throw new BadRequestException('Pickup and drop-off must differ');
    }
  }

  private readInt(key: string, fallback: number) {
    const raw = this.config.get<string | number>(key);
    if (raw === undefined || raw === '') return fallback;
    const value = typeof raw === 'number' ? raw : Number(raw);
    if (!Number.isFinite(value) || value < 0) return fallback;
    return Math.floor(value);
  }
}

function pickupAddress(row: PassengerBookingRow) {
  const pickup = [...row.stops].sort((left, right) => left.sequence - right.sequence)[0];
  return pickup?.address ?? '';
}

function isTrackingCollision(error: unknown) {
  if (!(error instanceof Prisma.PrismaClientKnownRequestError)) return false;
  if (error.code !== 'P2002') return false;
  return JSON.stringify(error.meta?.target ?? '').includes('trackingId');
}

function isActivePassengerCollision(error: unknown) {
  if (!(error instanceof Prisma.PrismaClientKnownRequestError)) return false;
  if (error.code !== 'P2002') return false;
  return !isTrackingCollision(error);
}
