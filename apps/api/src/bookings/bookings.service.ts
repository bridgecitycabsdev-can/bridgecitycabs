import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Inject,
  Injectable,
  InternalServerErrorException,
  Logger,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { BookingStatus, CancelReason, Prisma } from '@prisma/client';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import { normalizePage, paginate } from '../common/pagination.js';
import { normalizePhone } from '../common/phone.js';
import { calcFare } from '../fares/calc-fare.js';
import {
  DISTANCE_SERVICE,
  type DistanceService,
} from '../fares/distance.service.js';
import { OFFER_RESOLVED } from '../dispatch/offer-events.js';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { DISPATCH_QUEUE, type DispatchQueue } from '../jobs/dispatch-queue.js';
import {
  OFFER_EXPIRY_SCHEDULER,
  type OfferExpiryScheduler,
} from '../jobs/offer-expiry.scheduler.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { assertScheduledAt } from './booking-schedule.js';
import {
  BookingStateService,
  type BookingTransitionResult,
} from './booking-state.service.js';
import { BOOKING_TABS } from './booking-tabs.js';
import type { AssignBookingDto } from './dto/assign-booking.dto.js';
import type { DispatchModeDto } from './dto/dispatch-mode.dto.js';
import type { BookingQuery } from './dto/booking-query.dto.js';
import type { BookingStatusDto } from './dto/booking-status.dto.js';
import type { CancelBookingDto } from './dto/cancel-booking.dto.js';
import type { CreateBookingDto } from './dto/create-booking.dto.js';
import type { UnassignBookingDto } from './dto/unassign-booking.dto.js';
import { newTrackingId } from './tracking-id.js';

const CREATE_ROLES = [
  'dispatcher',
  'customer_care',
  'branch_admin',
  'super_admin',
] as const;
const ASSIGN_ROLES = ['dispatcher', 'branch_admin', 'super_admin'] as const;
const STATUS_ROLES = ['branch_admin', 'super_admin'] as const;

const listInclude = {
  vehicleType: { select: { id: true, name: true } },
  driver: { select: { id: true, firstName: true, lastName: true } },
  stops: { orderBy: { sequence: 'asc' as const } },
} satisfies Prisma.BookingInclude;

const detailInclude = {
  ...listInclude,
  vehicle: { select: { id: true, plateNumber: true, unitNumber: true } },
  passenger: {
    select: { id: true, firstName: true, lastName: true, phone: true },
  },
  history: { orderBy: { createdAt: 'asc' as const } },
  assignments: { orderBy: { assignedAt: 'desc' as const } },
} satisfies Prisma.BookingInclude;

const SORT_FIELDS = new Set(['createdAt', 'scheduledAt', 'status']);

const MODE_LOCKED: readonly BookingStatus[] = [
  'TRIP_STARTED',
  'TRIP_COMPLETED',
  'PAYMENT_PENDING',
  'PAYMENT_COMPLETED',
  'CLOSED',
  'CANCELLED',
];

type WithdrawnOffer = {
  offerId: string;
  driverId: string;
  bookingId: string;
  branchId: string;
};

@Injectable()
export class BookingsService {
  private readonly logger = new Logger(BookingsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly state: BookingStateService,
    private readonly fleet: FleetStateService,
    private readonly config: ConfigService,
    private readonly events: EventEmitter2,
    @Inject(DISTANCE_SERVICE) private readonly distance: DistanceService,
    @Inject(OFFER_EXPIRY_SCHEDULER) private readonly expiry: OfferExpiryScheduler,
    @Inject(DISPATCH_QUEUE) private readonly dispatch: DispatchQueue,
  ) {}

  async create(dto: CreateBookingDto, user: AuthUser) {
    this.assertRole(user, CREATE_ROLES);
    const branch = await this.resolveBranch(user, dto.branchId);
    const phone = normalizePhone(dto.passengerPhone);
    const passenger = await this.prisma.passenger.findFirst({ where: { phone } });
    if (passenger?.blocked) {
      throw new UnprocessableEntityException('Passenger is blocked');
    }

    const vehicleType = await this.prisma.vehicleType.findUnique({
      where: { id: dto.vehicleTypeId },
    });
    if (!vehicleType) throw new NotFoundException();
    if (!vehicleType.active) {
      throw new UnprocessableEntityException('Vehicle type is not active');
    }

    // Zone is supplied by the client. A city-boundary polygon comes later.
    const rule = await this.prisma.fareRule.findUnique({
      where: {
        branchId_vehicleTypeId_zone: {
          branchId: branch.id,
          vehicleTypeId: dto.vehicleTypeId,
          zone: dto.zone,
        },
      },
    });
    if (!rule?.active) {
      throw new NotFoundException(
        'No active fare rule for this vehicle type and zone',
      );
    }

    this.assertStops(dto.stops);
    const scheduledAt = dto.scheduledAt ? new Date(dto.scheduledAt) : null;
    if (scheduledAt) {
      assertScheduledAt(
        scheduledAt,
        new Date(),
        this.leadMinutes(),
        this.maxAdvanceDays(),
      );
    }

    const pickup = dto.stops[0];
    const dropoff = dto.stops[dto.stops.length - 1];
    const via = dto.stops.slice(1, -1);
    const trip = await this.distance.estimate(pickup, dropoff, via);
    const fare = calcFare(rule, trip.meters, trip.seconds, branch.gstRateBps);
    const initial: BookingStatus = scheduledAt ? 'SCHEDULED' : 'CREATED';
    const actor = { type: 'STAFF' as const, userId: user.userId };
    const openedAt = new Date(Date.now() - 1);

    const inserted = await this.insertBooking({
      dto,
      user,
      branchId: branch.id,
      phone,
      passengerId: passenger?.id ?? null,
      scheduledAt,
      initial,
      openedAt,
      meters: trip.meters,
      seconds: trip.seconds,
      subtotalCents: fare.subtotalCents,
      taxCents: fare.taxCents,
      actor,
    });

    await this.events.emitAsync('booking.created', this.queuePayload(inserted.booking));
    if (inserted.opened) {
      await this.events.emitAsync('booking.status_changed', inserted.opened);
    }
    return inserted.booking;
  }

  async findAll(user: AuthUser, query: BookingQuery) {
    const { page, pageSize, skip, take } = normalizePage(query);
    const scope = this.scope(user, query.branchId);
    if (!scope) return paginate([], 0, { page, pageSize });

    const tab: readonly BookingStatus[] | undefined = query.tab
      ? BOOKING_TABS[query.tab]
      : undefined;
    if (tab && query.status && !tab.includes(query.status)) {
      return paginate([], 0, { page, pageSize });
    }

    const where: Prisma.BookingWhereInput = { ...scope };
    if (query.source) where.source = query.source;
    if (query.paymentStatus) where.paymentStatus = query.paymentStatus;
    if (query.paymentMethod) where.paymentMethod = query.paymentMethod;
    if (query.driverId) where.driverId = query.driverId;
    if (tab && query.status) where.status = query.status;
    else if (tab) where.status = { in: [...tab] };
    else if (query.status) where.status = query.status;
    const range = this.serviceWindow(query.from, query.to);
    if (range) {
      where.AND = [
        {
          OR: [
            { scheduledAt: range },
            { scheduledAt: null, createdAt: range },
          ],
        },
      ];
    }

    const [total, data] = await this.prisma.$transaction([
      this.prisma.booking.count({ where }),
      this.prisma.booking.findMany({
        where,
        skip,
        take,
        orderBy: this.orderBy(query.sort),
        include: listInclude,
      }),
    ]);
    return paginate(data, total, { page, pageSize });
  }

  async findOne(id: string, user: AuthUser) {
    const scope = this.scope(user);
    if (!scope) throw new NotFoundException();
    const booking = await this.prisma.booking.findFirst({
      where: { id, ...scope },
      include: detailInclude,
    });
    if (!booking) throw new NotFoundException();
    return booking;
  }

  async lookup(trackingId: string, user: AuthUser) {
    const scope = this.scope(user);
    if (!scope) throw new NotFoundException();
    const booking = await this.prisma.booking.findFirst({
      where: { trackingId: trackingId.trim().toUpperCase(), ...scope },
      include: detailInclude,
    });
    if (!booking) throw new NotFoundException();
    return booking;
  }

  async assign(id: string, dto: AssignBookingDto, user: AuthUser) {
    this.assertRole(user, ASSIGN_ROLES);
    const actor = { type: 'STAFF' as const, userId: user.userId };
    const withdrawn: WithdrawnOffer[] = [];
    const events = await this.prisma
      .$transaction(async (tx) => {
        withdrawn.length = 0;
        const booking = await this.requireBooking(tx, id, user);
        const published: BookingTransitionResult[] = [];
        withdrawn.push(...(await this.withdrawOpenOffers(tx, booking)));
        let status = booking.status;
        if (status === 'MATCHED') {
          published.push(
            await this.state.transition(booking.id, 'SEARCHING_DRIVER', { type: 'SYSTEM' }, {
              tx,
              reason: 'Offer cancelled',
            }),
          );
          status = 'SEARCHING_DRIVER';
        }
        const open = await tx.bookingAssignment.findFirst({
          where: { bookingId: booking.id, endedAt: null },
        });
        if (open?.driverId === dto.driverId && status === 'DRIVER_ASSIGNED') {
          await this.requireAssignableDriver(tx, dto, booking);
          return published;
        }
        if (open) {
          await tx.bookingAssignment.update({
            where: { id: open.id },
            data: { endedAt: new Date(), endReason: 'REASSIGNED' },
          });
        }
        if (status !== 'SEARCHING_DRIVER') {
          published.push(
            await this.state.transition(booking.id, 'SEARCHING_DRIVER', actor, {
              tx,
            }),
          );
        }
        const driver = await this.requireAssignableDriver(tx, dto, booking);
        await this.fleet.assertAvailableForAssign(driver.id, booking.id);
        published.push(
          await this.state.transition(booking.id, 'DRIVER_ASSIGNED', actor, {
            tx,
            patch: {
              driverId: driver.id,
              vehicleId: driver.vehicleId,
              assignedAt: new Date(),
            },
          }),
        );
        await tx.bookingAssignment.create({
          data: {
            bookingId: booking.id,
            driverId: driver.id,
            vehicleId: driver.vehicleId,
            method: 'MANUAL',
            assignedById: user.userId,
          },
        });
        return published;
      })
      .catch(rethrowAssignmentConflict);

    await this.finishWithdrawn(withdrawn);
    for (const event of events) {
      await this.events.emitAsync('booking.status_changed', event);
    }
    return this.findOne(id, user);
  }

  async setDispatchMode(id: string, dto: DispatchModeDto, user: AuthUser) {
    this.assertRole(user, ASSIGN_ROLES);
    const withdrawn: WithdrawnOffer[] = [];
    const published: BookingTransitionResult[] = [];
    let resumeSearch = false;
    await this.prisma.$transaction(async (tx) => {
      withdrawn.length = 0;
      published.length = 0;
      const booking = await this.requireBooking(tx, id, user);
      if (MODE_LOCKED.includes(booking.status)) {
        throw new ConflictException('This booking can no longer change dispatch mode');
      }
      if (dto.mode === 'MANUAL') {
        withdrawn.push(...(await this.withdrawOpenOffers(tx, booking)));
        if (booking.status === 'MATCHED') {
          published.push(
            await this.state.transition(booking.id, 'SEARCHING_DRIVER', { type: 'SYSTEM' }, {
              tx,
              reason: 'Dispatch set to manual',
            }),
          );
        }
      }
      if (booking.assignMode !== dto.mode) {
        await tx.booking.update({
          where: { id: booking.id },
          data: { assignMode: dto.mode },
        });
      }
      resumeSearch = dto.mode === 'AUTO' && booking.status === 'SEARCHING_DRIVER';
    });

    await this.finishWithdrawn(withdrawn);
    for (const event of published) {
      await this.events.emitAsync('booking.status_changed', event);
    }
    if (resumeSearch) {
      const fresh = await this.prisma.booking.findUnique({
        where: { id },
        select: { version: true, status: true, assignMode: true },
      });
      if (fresh?.assignMode === 'AUTO' && fresh.status === 'SEARCHING_DRIVER') {
        await this.dispatch.enqueueAttempt(id, fresh.version);
      }
    }
    return this.findOne(id, user);
  }

  async unassign(id: string, dto: UnassignBookingDto, user: AuthUser) {
    this.assertRole(user, ASSIGN_ROLES);
    const result = await this.prisma.$transaction(async (tx) => {
      const booking = await this.requireBooking(tx, id, user);
      await tx.bookingAssignment.updateMany({
        where: { bookingId: booking.id, endedAt: null },
        data: { endedAt: new Date(), endReason: 'REASSIGNED' },
      });
      return this.state.transition(
        booking.id,
        'SEARCHING_DRIVER',
        { type: 'STAFF', userId: user.userId },
        { tx, reason: dto.reason },
      );
    });
    return this.afterTransition(result, user);
  }

  async cancel(id: string, dto: CancelBookingDto, user: AuthUser) {
    const result = await this.prisma.$transaction(async (tx) => {
      const booking = await this.requireBooking(tx, id, user);
      await this.closeAssignment(tx, booking.id, 'BOOKING_CANCELLED');
      return this.state.transition(
        booking.id,
        'CANCELLED',
        { type: 'STAFF', userId: user.userId },
        { tx, ...this.cancellation(dto.reason, dto.note) },
      );
    });
    return this.afterTransition(result, user);
  }

  async setStatus(id: string, dto: BookingStatusDto, user: AuthUser) {
    this.assertRole(user, STATUS_ROLES);
    if (dto.to === 'CANCELLED' && !dto.reason) {
      throw new BadRequestException('A reason is required to cancel');
    }
    const result = await this.prisma
      .$transaction(async (tx) => {
        const booking = await this.requireBooking(tx, id, user);
        if (dto.to === 'SEARCHING_DRIVER') {
          await this.closeAssignment(tx, booking.id, 'REASSIGNED');
        }
        if (dto.to === 'CANCELLED') {
          await this.closeAssignment(tx, booking.id, 'BOOKING_CANCELLED');
        }
        return this.state.transition(
          booking.id,
          dto.to,
          { type: 'STAFF', userId: user.userId },
          {
            tx,
            ...(dto.to === 'CANCELLED'
              ? this.cancellation(dto.reason!, dto.note)
              : { reason: undefined }),
          },
        );
      })
      .catch(rethrowAssignmentConflict);
    return this.afterTransition(result, user);
  }

  private async insertBooking(input: {
    dto: CreateBookingDto;
    user: AuthUser;
    branchId: string;
    phone: string;
    passengerId: string | null;
    scheduledAt: Date | null;
    initial: BookingStatus;
    openedAt: Date;
    meters: number;
    seconds: number;
    subtotalCents: number;
    taxCents: number;
    actor: { type: 'STAFF'; userId: string };
  }) {
    for (let attempt = 0; attempt < 5; attempt += 1) {
      try {
        return await this.prisma.$transaction(async (tx) => {
          const created = await tx.booking.create({
            data: {
              trackingId: newTrackingId(),
              branchId: input.branchId,
              source: 'DISPATCH',
              status: input.initial,
              passengerId: input.passengerId,
              passengerName: input.dto.passengerName.trim(),
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
              fixedFareCents: input.dto.fixedFareCents,
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
              actorType: 'STAFF',
              actorUserId: input.user.userId,
              createdAt: input.openedAt,
            },
          });
          // Scheduled bookings stay SCHEDULED until the release job.
          const opened =
            input.initial === 'CREATED'
              ? await this.state.transition(created.id, 'SEARCHING_DRIVER', input.actor, {
                  tx,
                })
              : null;
          const booking = await tx.booking.findUniqueOrThrow({
            where: { id: created.id },
            include: detailInclude,
          });
          return { booking, opened };
        });
      } catch (error) {
        if (attempt < 4 && isTrackingCollision(error)) continue;
        throw error;
      }
    }
    throw new InternalServerErrorException('Could not allocate a tracking id');
  }

  private queuePayload(booking: {
    id: string;
    branchId: string;
    trackingId: string;
    status: BookingStatus;
    passengerName: string;
    scheduledAt: Date | null;
    quotedFareCents: number;
    vehicleType: { id: string; name: string };
    stops: { sequence: number; address: string }[];
  }) {
    const pickup = [...booking.stops].sort((left, right) => left.sequence - right.sequence)[0];
    return {
      id: booking.id,
      branchId: booking.branchId,
      trackingId: booking.trackingId,
      status: booking.status,
      passengerName: booking.passengerName,
      scheduledAt: booking.scheduledAt?.toISOString() ?? null,
      quotedFareCents: booking.quotedFareCents,
      vehicleType: { id: booking.vehicleType.id, name: booking.vehicleType.name },
      pickupAddress: pickup?.address ?? '',
    };
  }

  private async afterTransition(
    result: { bookingId: string; from: BookingStatus; to: BookingStatus },
    user: AuthUser,
  ) {
    await this.events.emitAsync('booking.status_changed', result);
    return this.findOne(result.bookingId, user);
  }

  private cancellation(reason: CancelReason, note?: string) {
    const cancelNote = note?.trim() || null;
    return {
      reason,
      metadata: cancelNote ? { note: cancelNote } : undefined,
      // Fee rules wait until payments. cancellationFeeCents stays 0.
      patch: {
        cancelledBy: 'STAFF' as const,
        cancelReason: reason,
        cancelNote,
      },
    };
  }

  private closeAssignment(
    tx: Prisma.TransactionClient,
    bookingId: string,
    endReason: 'REASSIGNED' | 'BOOKING_CANCELLED',
  ) {
    return tx.bookingAssignment.updateMany({
      where: { bookingId, endedAt: null },
      data: { endedAt: new Date(), endReason },
    });
  }

  /** Marks every open offer cancelled. Redis release and offer:cancelled happen after commit. */
  private async withdrawOpenOffers(
    tx: Prisma.TransactionClient,
    booking: { id: string; branchId: string },
  ) {
    const open = await tx.bookingOffer.findMany({
      where: { bookingId: booking.id, status: 'OFFERED' },
      select: { id: true, driverId: true },
    });
    const withdrawn: WithdrawnOffer[] = [];
    for (const offer of open) {
      const updated = await tx.bookingOffer.updateMany({
        where: { id: offer.id, status: 'OFFERED' },
        data: { status: 'CANCELLED', respondedAt: new Date() },
      });
      if (updated.count !== 1) continue;
      withdrawn.push({
        offerId: offer.id,
        driverId: offer.driverId,
        bookingId: booking.id,
        branchId: booking.branchId,
      });
    }
    return withdrawn;
  }

  private async finishWithdrawn(offers: WithdrawnOffer[]) {
    for (const offer of offers) {
      try {
        await this.fleet.releaseOffer({
          branchId: offer.branchId,
          driverId: offer.driverId,
          bookingId: offer.bookingId,
        });
      } catch (error) {
        this.logger.warn(
          `Could not release ${offer.driverId} after cancelling ${offer.offerId}: ${
            error instanceof Error ? error.message : 'unknown error'
          }`,
        );
      }
      try {
        await this.expiry.cancel(offer.offerId);
      } catch (error) {
        this.logger.warn(
          `Could not remove expiry for ${offer.offerId}: ${
            error instanceof Error ? error.message : 'unknown error'
          }`,
        );
      }
      await this.events.emitAsync(OFFER_RESOLVED, {
        offerId: offer.offerId,
        bookingId: offer.bookingId,
        driverId: offer.driverId,
        branchId: offer.branchId,
        outcome: 'CANCELLED',
      });
    }
  }

  private async requireAssignableDriver(
    tx: Prisma.TransactionClient,
    dto: AssignBookingDto,
    booking: { branchId: string; vanOnly: boolean; ladyDriverOnly: boolean },
  ) {
    const driver = await tx.driver.findUnique({
      where: { id: dto.driverId },
      include: {
        assignments: {
          where: { endedAt: null },
          include: { vehicle: { include: { vehicleType: true } } },
        },
      },
    });
    if (!driver) throw new NotFoundException();
    if (driver.branchId !== booking.branchId) {
      throw new BadRequestException('Driver must belong to the booking branch');
    }
    if (driver.status !== 'APPROVED') {
      throw new UnprocessableEntityException(
        'Only approved drivers can be assigned',
      );
    }
    const current = driver.assignments[0];
    if (!current?.vehicle.active) {
      throw new UnprocessableEntityException('Driver has no active vehicle');
    }
    if (dto.vehicleId && dto.vehicleId !== current.vehicleId) {
      throw new BadRequestException(
        "Vehicle does not match the driver's current assignment",
      );
    }
    if (
      booking.vanOnly &&
      current.vehicle.vehicleType.name.toLowerCase() !== 'minivan'
    ) {
      throw new UnprocessableEntityException('Booking requires a minivan');
    }
    if (booking.ladyDriverOnly && driver.ladyDriverEligible !== true) {
      throw new UnprocessableEntityException('Booking requires a lady driver');
    }
    return { id: driver.id, vehicleId: current.vehicleId };
  }

  private async requireBooking(
    tx: Prisma.TransactionClient,
    id: string,
    user: AuthUser,
  ) {
    const scope = this.scope(user);
    if (!scope) throw new NotFoundException();
    const booking = await tx.booking.findFirst({ where: { id, ...scope } });
    if (!booking) throw new NotFoundException();
    return booking;
  }

  private assertStops(stops: CreateBookingDto['stops']) {
    const pickup = stops[0];
    const dropoff = stops[stops.length - 1];
    if (pickup.lat === dropoff.lat && pickup.lng === dropoff.lng) {
      throw new BadRequestException('Pickup and drop-off must differ');
    }
  }

  private scope(
    user: AuthUser,
    requestedBranchId?: string,
  ): { branchId?: string } | null {
    if (user.role !== 'super_admin' && !user.branchId) return null;
    return branchWhere(user, requestedBranchId);
  }

  private assertRole(user: AuthUser, roles: readonly string[]) {
    if (!roles.includes(user.role)) throw new ForbiddenException();
  }

  private async resolveBranch(user: AuthUser, requested?: string) {
    if (user.role === 'super_admin') {
      if (!requested) throw new BadRequestException('branchId is required');
      const branch = await this.prisma.branch.findUnique({ where: { id: requested } });
      if (!branch) throw new NotFoundException();
      return branch;
    }
    if (!user.branchId) throw new ForbiddenException();
    const branch = await this.prisma.branch.findUnique({
      where: { id: user.branchId },
    });
    if (!branch) throw new NotFoundException();
    return branch;
  }

  private leadMinutes() {
    return this.readInt('BOOKING_MIN_LEAD_MINUTES', 15);
  }

  private maxAdvanceDays() {
    return this.readInt('BOOKING_MAX_ADVANCE_DAYS', 30);
  }

  private readInt(key: string, fallback: number) {
    const raw = this.config.get<string | number>(key);
    if (raw === undefined || raw === '') return fallback;
    const value = typeof raw === 'number' ? raw : Number(raw);
    if (!Number.isFinite(value) || value < 0) return fallback;
    return Math.floor(value);
  }

  private serviceWindow(from?: string, to?: string): Prisma.DateTimeFilter | undefined {
    if (!from && !to) return undefined;
    const range: Prisma.DateTimeFilter = {};
    if (from) range.gte = parseBoundary(from, false);
    if (to) range.lte = parseBoundary(to, true);
    return range;
  }

  private orderBy(sort?: string): Prisma.BookingOrderByWithRelationInput {
    if (!sort) return { createdAt: 'desc' };
    const [field, direction] = sort.split(':');
    if (
      !field ||
      !SORT_FIELDS.has(field) ||
      (direction !== 'asc' && direction !== 'desc')
    ) {
      throw new BadRequestException(
        'sort must be createdAt, scheduledAt, or status with :asc or :desc',
      );
    }
    return { [field]: direction };
  }
}

function stopType(index: number, count: number) {
  if (index === 0) return 'PICKUP' as const;
  if (index === count - 1) return 'DROPOFF' as const;
  return 'STOP' as const;
}

function parseBoundary(value: string, end: boolean) {
  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return new Date(`${value}T${end ? '23:59:59.999' : '00:00:00.000'}Z`);
  }
  return new Date(value);
}

function isTrackingCollision(error: unknown) {
  if (!(error instanceof Prisma.PrismaClientKnownRequestError)) return false;
  if (error.code !== 'P2002') return false;
  return JSON.stringify(error.meta?.target ?? '').includes('trackingId');
}

function rethrowAssignmentConflict(error: unknown): never {
  if (
    error instanceof Prisma.PrismaClientKnownRequestError &&
    error.code === 'P2002'
  ) {
    const target = `${error.message} ${JSON.stringify(error.meta ?? '')}`;
    if (target.includes('driverId') || target.includes('one_active_booking_per_driver')) {
      throw new ConflictException('Driver is busy');
    }
    throw new ConflictException('Booking already has an open assignment');
  }
  throw error;
}
