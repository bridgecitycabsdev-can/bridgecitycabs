import {
  BadRequestException,
  ConflictException,
  HttpStatus,
  Inject,
  Injectable,
  InternalServerErrorException,
  Logger,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { BookingStatus, Prisma } from '@prisma/client';
import { randomUUID } from 'node:crypto';
import { ApiCode } from '../common/api-code.js';
import { ApiException } from '../common/api-exception.js';
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
import { CardHoldService } from '../payments/card-hold.service.js';
import { PaymentProvidersService } from '../payments/payment-providers.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { PromosService } from '../promos/promos.service.js';
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

type CardAuth = {
  bookingId: string;
  paymentMethodId: string;
  stripePaymentIntentId: string;
  authorizedAmountCents: number;
  authBufferBps: number;
  idempotencyKey: string;
};

@Injectable()
export class PassengerBookingsService {
  private readonly logger = new Logger(PassengerBookingsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly state: BookingStateService,
    private readonly fares: FaresService,
    private readonly fleet: FleetStateService,
    private readonly config: ConfigService,
    private readonly events: EventEmitter2,
    @Inject(DISTANCE_SERVICE) private readonly distance: DistanceService,
    private readonly paymentProviders: PaymentProvidersService,
    private readonly cardHolds: CardHoldService,
    private readonly promos: PromosService,
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

    if (!dto.quoteToken) {
      throw new ApiException(
        HttpStatus.BAD_REQUEST,
        ApiCode.VALIDATION,
        'Validation failed',
        {
          quoteToken: 'A quote is required',
        },
      );
    }
    const branch = await this.branchFor(user, dto.branchId);
    const accepted = this.fares.acceptQuote(dto.quoteToken, {
      branchId: branch.id,
      vehicleTypeId: dto.vehicleTypeId,
      zone: dto.zone,
      stops: dto.stops,
    });
    if (!accepted) {
      throw new ApiException(
        HttpStatus.CONFLICT,
        ApiCode.QUOTE_EXPIRED,
        'Quote expired',
        undefined,
        await this.fares.quotes({ stops: dto.stops, branchId: branch.id }, user),
      );
    }

    const paymentMethod = dto.paymentMethod ?? 'CASH';
    let cardAuth: CardAuth | undefined;
    let providerRefToCancel: string | undefined;
    if (paymentMethod === 'CARD') {
      cardAuth = await this.authorizeCard({
        passengerId: passenger.id,
        paymentMethodId: dto.paymentMethodId,
        totalCents: accepted.totalCents,
      });
      providerRefToCancel = cardAuth.stripePaymentIntentId;
    }

    const initial: BookingStatus = scheduledAt ? 'SCHEDULED' : 'CREATED';
    const openedAt = new Date(Date.now() - 1);
    const phone = passenger.phone;
    const passengerName = [passenger.firstName, passenger.lastName]
      .filter((part) => part && part.trim())
      .join(' ');

    let inserted: { id: string; opened: unknown };
    try {
      inserted = await this.insert({
        dto: { ...dto, paymentMethod },
        user,
        branchId: branch.id,
        gstRateBps: branch.gstRateBps,
        passengerId: passenger.id,
        passengerName,
        phone,
        scheduledAt,
        initial,
        openedAt,
        meters: accepted.distanceM,
        seconds: accepted.durationS,
        subtotalCents: accepted.subtotalCents,
        taxCents: accepted.taxCents,
        promoCodeId: accepted.promoCodeId ?? null,
        promoDiscountCents: accepted.discountCents ?? 0,
        cardAuth,
      });
      providerRefToCancel = undefined;
    } finally {
      if (providerRefToCancel) {
        await this.paymentProviders
          .get('STRIPE')
          .cancel({ providerRef: providerRefToCancel })
          .catch((error: unknown) => {
            this.logger.warn(
              `Failed to cancel Stripe PI ${providerRefToCancel} after booking create failed: ${String(error)}`,
            );
          });
      }
    }

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

  async cancel(
    user: AuthUser,
    id: string,
    dto: PassengerCancelBookingDto = {},
  ) {
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
      await this.promos.releaseIfAny(tx, booking.id);
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
    await this.cardHolds.releaseAuthorized(result.bookingId);
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
      throw new ConflictException(
        'Only a booking with no driver can be retried',
      );
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

  /**
   * Authorize a card hold before the booking row exists. Uses a pre-allocated
   * booking id so a decline never leaves an orphaned booking.
   */
  private async authorizeCard(input: {
    passengerId: string;
    paymentMethodId?: string;
    totalCents: number;
  }): Promise<CardAuth> {
    if (!input.paymentMethodId) {
      throw new BadRequestException('paymentMethodId is required for CARD');
    }
    const [ppm, sc] = await Promise.all([
      this.prisma.passengerPaymentMethod.findFirst({
        where: {
          id: input.paymentMethodId,
          passengerId: input.passengerId,
        },
      }),
      this.prisma.stripeCustomer.findUnique({
        where: { passengerId: input.passengerId },
      }),
    ]);
    if (!ppm) throw new NotFoundException('Payment method not found');
    if (!sc) {
      throw new UnprocessableEntityException(
        'Save a card before booking with CARD',
      );
    }

    const bookingId = randomUUID();
    const authBufferBps = this.readInt('AUTH_BUFFER_BPS', 2000);
    const authAmount = Math.round(
      input.totalCents * (1 + authBufferBps / 10000),
    );
    const idempotencyKey = `card-auth:${bookingId}`;
    const auth = await this.paymentProviders.get('STRIPE').authorize({
      bookingId,
      amountCents: authAmount,
      customerId: sc.stripeCustomerId,
      paymentMethodId: ppm.stripePmId,
      idempotencyKey,
    });
    if (auth.status === 'REQUIRES_ACTION') {
      throw new ApiException(
        HttpStatus.CONFLICT,
        ApiCode.CARD_REQUIRES_ACTION,
        'Card requires additional authentication',
        { providerRef: auth.providerRef },
      );
    }
    if (auth.status !== 'AUTHORIZED') {
      throw new ApiException(
        HttpStatus.UNPROCESSABLE_ENTITY,
        ApiCode.CARD_DECLINED,
        'Card was declined',
      );
    }
    return {
      bookingId,
      paymentMethodId: ppm.id,
      stripePaymentIntentId: auth.providerRef,
      authorizedAmountCents: authAmount,
      authBufferBps,
      idempotencyKey,
    };
  }

  private async insert(input: {
    dto: PassengerCreateBookingDto;
    user: AuthUser;
    branchId: string;
    gstRateBps: number;
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
    promoCodeId: string | null;
    promoDiscountCents: number;
    cardAuth?: CardAuth;
  }) {
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
              ...(input.cardAuth ? { id: input.cardAuth.bookingId } : {}),
              trackingId: newTrackingId(),
              branchId: input.branchId,
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
              promoCodeId: input.promoCodeId,
              promoDiscountCents: input.promoDiscountCents,
              gstRateBps: input.gstRateBps,
              paymentMethod: input.dto.paymentMethod,
              paymentMethodId: input.cardAuth?.paymentMethodId,
              stripePaymentIntentId: input.cardAuth?.stripePaymentIntentId,
              authorizedAmountCents: input.cardAuth?.authorizedAmountCents,
              authBufferBps: input.cardAuth?.authBufferBps,
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
          if (input.promoCodeId) {
            await this.promos.redeem(tx, {
              promoCodeId: input.promoCodeId,
              passengerId: input.passengerId,
              bookingId: created.id,
              discountCents: input.promoDiscountCents,
            });
          }
          if (input.cardAuth) {
            await tx.payment.create({
              data: {
                bookingId: created.id,
                method: 'CARD',
                provider: 'STRIPE',
                purpose: 'TRIP_AUTH_CAPTURE',
                status: 'AUTHORIZED',
                amountCents: input.cardAuth.authorizedAmountCents,
                currency: 'CAD',
                providerRef: input.cardAuth.stripePaymentIntentId,
                idempotencyKey: input.cardAuth.idempotencyKey,
                createdById: input.user.userId,
              },
            });
          }
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

  private async branchFor(user: AuthUser, requested?: string) {
    const id = user.branchId ?? requested;
    if (!id) throw new BadRequestException('branchId is required');
    const branch = await this.prisma.branch.findUnique({
      where: { id },
      select: { id: true, gstRateBps: true },
    });
    if (!branch) throw new NotFoundException();
    return branch;
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
    if (!PASSENGER_SHARE_LOCATION_STATUSES.includes(booking.status))
      return null;
    const position = await this.fleet.sharedPosition(booking.driverId);
    if (!position) return null;
    const stops = [...booking.stops].sort(
      (left, right) => left.sequence - right.sequence,
    );
    const target =
      booking.status === 'TRIP_STARTED' ? stops[stops.length - 1] : stops[0];
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
  const pickup = [...row.stops].sort(
    (left, right) => left.sequence - right.sequence,
  )[0];
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
