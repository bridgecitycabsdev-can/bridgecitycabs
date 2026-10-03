import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
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
import { BookingStatus, CancelReason, Prisma } from '@prisma/client';
import { ApiCode } from '../common/api-code.js';
import { ApiException } from '../common/api-exception.js';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import { normalizePage, paginate } from '../common/pagination.js';
import { normalizePhone } from '../common/phone.js';
import { calcFare } from '../fares/calc-fare.js';
import {
  DISTANCE_SERVICE,
  type DistanceService,
  type GeoPoint,
} from '../fares/distance.service.js';
import { FaresService } from '../fares/fares.service.js';
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
import { BOOKING_TABS, type BookingTab } from './booking-tabs.js';
import { assertEditable, editableFields } from './booking-edit.js';
import type { AssignBookingDto } from './dto/assign-booking.dto.js';
import type { DispatchModeDto } from './dto/dispatch-mode.dto.js';
import type { BookingQuery } from './dto/booking-query.dto.js';
import type { BookingStatusDto } from './dto/booking-status.dto.js';
import type { CancelBookingDto } from './dto/cancel-booking.dto.js';
import type { CreateBookingDto } from './dto/create-booking.dto.js';
import type { ReleaseBookingDto } from './dto/release-booking.dto.js';
import type { UnassignBookingDto } from './dto/unassign-booking.dto.js';
import type { UpdateBookingDto } from './dto/update-booking.dto.js';
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
  offers: {
    where: { status: 'OFFERED' as const },
    orderBy: { offeredAt: 'desc' as const },
    take: 1,
  },
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
    private readonly fares: FaresService,
    @Inject(OFFER_EXPIRY_SCHEDULER)
    private readonly expiry: OfferExpiryScheduler,
    @Inject(DISPATCH_QUEUE) private readonly dispatch: DispatchQueue,
  ) {}

  async create(dto: CreateBookingDto, user: AuthUser) {
    this.assertRole(user, CREATE_ROLES);
    const branch = await this.resolveBranch(user, dto.branchId);
    const phone = normalizePhone(dto.passengerPhone);
    const passenger = await this.prisma.passenger.findFirst({
      where: { phone },
    });
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
    const priced = dto.quoteToken
      ? await this.quotedPrice(dto, branch.id, user)
      : await this.recomputedPrice(
          branch.id,
          dto,
          pickup,
          dropoff,
          via,
          branch.gstRateBps,
        );
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
      meters: priced.meters,
      seconds: priced.seconds,
      subtotalCents: priced.subtotalCents,
      taxCents: priced.taxCents,
      actor,
    });

    await this.events.emitAsync(
      'booking.created',
      this.queuePayload(inserted.booking),
    );
    if (inserted.opened) {
      await this.events.emitAsync('booking.status_changed', inserted.opened);
    }
    return inserted.booking;
  }

  async findAll(user: AuthUser, query: BookingQuery) {
    const { page, pageSize, skip, take } = normalizePage(query);
    const scope = this.scope(user, query.branchId);
    if (!scope) return paginate([], 0, { page, pageSize });

    const where: Prisma.BookingWhereInput = { ...scope };
    if (query.source) where.source = query.source;
    if (query.paymentStatus) where.paymentStatus = query.paymentStatus;
    if (query.paymentMethod) where.paymentMethod = query.paymentMethod;
    if (query.driverId) where.driverId = query.driverId;
    if (query.zone) where.zone = query.zone;
    const name = query.q?.trim();
    if (name) where.passengerName = { contains: name, mode: 'insensitive' };
    if (query.phone) where.passengerPhone = normalizePhone(query.phone);
    const trackingId = query.trackingId?.trim().toUpperCase();
    if (trackingId) where.trackingId = trackingId;

    const and: Prisma.BookingWhereInput[] = [];
    const range = this.serviceWindow(query.from, query.to);
    if (range) {
      and.push({
        OR: [{ scheduledAt: range }, { scheduledAt: null, createdAt: range }],
      });
    }
    if (!(await this.applyTab(where, and, query))) {
      return paginate([], 0, { page, pageSize });
    }
    if (and.length) where.AND = and;

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
    return this.present(await this.loadDetail(id, user));
  }

  async lookup(trackingId: string, user: AuthUser) {
    const scope = this.scope(user);
    if (!scope) throw new NotFoundException();
    const booking = await this.prisma.booking.findFirst({
      where: { trackingId: trackingId.trim().toUpperCase(), ...scope },
      include: detailInclude,
    });
    if (!booking) throw new NotFoundException();
    return this.present(booking);
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
            await this.state.transition(
              booking.id,
              'SEARCHING_DRIVER',
              { type: 'SYSTEM' },
              {
                tx,
                reason: 'Offer cancelled',
              },
            ),
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
        throw new ConflictException(
          'This booking can no longer change dispatch mode',
        );
      }
      if (dto.mode === 'MANUAL') {
        withdrawn.push(...(await this.withdrawOpenOffers(tx, booking)));
        if (booking.status === 'MATCHED') {
          published.push(
            await this.state.transition(
              booking.id,
              'SEARCHING_DRIVER',
              { type: 'SYSTEM' },
              {
                tx,
                reason: 'Dispatch set to manual',
              },
            ),
          );
        }
      }
      if (booking.assignMode !== dto.mode) {
        await tx.booking.update({
          where: { id: booking.id },
          data: { assignMode: dto.mode },
        });
      }
      resumeSearch =
        dto.mode === 'AUTO' && booking.status === 'SEARCHING_DRIVER';
    });

    await this.finishWithdrawn(withdrawn);
    for (const event of published) {
      await this.events.emitAsync('booking.status_changed', event);
    }
    if (dto.mode === 'MANUAL') {
      await this.dispatch.removeAttempts(id);
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

  async update(id: string, dto: UpdateBookingDto, user: AuthUser) {
    const existing = await this.loadDetail(id, user);
    if (existing.version !== dto.version) {
      throw new ApiException(
        HttpStatus.CONFLICT,
        ApiCode.VERSION_CONFLICT,
        'Version conflict',
      );
    }
    const requested = requestedFields(dto);
    assertEditable(existing.status, requested);

    const next = this.nextValues(existing, dto);
    if (next.scheduledAt instanceof Date) {
      assertScheduledAt(
        next.scheduledAt,
        new Date(),
        this.leadMinutes(),
        this.maxAdvanceDays(),
      );
    }
    if (
      next.fixedFareCents != null &&
      next.fixedFareCents > this.readInt('FIXED_FARE_MAX_CENTS', 50_000)
    ) {
      throw new ApiException(
        HttpStatus.BAD_REQUEST,
        ApiCode.VALIDATION,
        'Validation failed',
        { fixedFareCents: 'Fixed fare is above the maximum' },
      );
    }
    const quoteChanged =
      next.vehicleTypeId !== existing.vehicleTypeId ||
      next.zone !== existing.zone ||
      !sameStops(existing.stops, next.stops);
    const priced = quoteChanged
      ? await this.requote(existing, next, user)
      : null;
    const patch = changedPatch(existing, next, priced);
    if (!patch) return this.present(existing);

    const notesChanged =
      patch.before !== null &&
      typeof patch.before === 'object' &&
      !Array.isArray(patch.before) &&
      Object.prototype.hasOwnProperty.call(patch.before, 'notes');
    await this.prisma.$transaction(async (tx) => {
      const saved = await tx.booking.updateMany({
        where: { id: existing.id, version: dto.version },
        data: { ...patch.data, version: { increment: 1 } },
      });
      if (saved.count !== 1) {
        throw new ApiException(
          HttpStatus.CONFLICT,
          ApiCode.VERSION_CONFLICT,
          'Version conflict',
        );
      }
      if (patch.stops) {
        await tx.bookingStop.deleteMany({ where: { bookingId: existing.id } });
        await tx.bookingStop.createMany({
          data: patch.stops.map((stop, index) => ({
            bookingId: existing.id,
            sequence: index + 1,
            type: stopType(index, patch.stops!.length),
            address: stop.address,
            lat: stop.lat,
            lng: stop.lng,
            placeId: stop.placeId,
          })),
        });
      }
      await tx.auditLog.create({
        data: {
          actorUserId: user.userId,
          actorType: 'STAFF',
          entity: 'booking',
          entityId: existing.id,
          action: 'booking.updated',
          before: patch.before,
          after: patch.after,
        },
      });
      if (patch.fixedFare) {
        await tx.auditLog.create({
          data: {
            actorUserId: user.userId,
            actorType: 'STAFF',
            entity: 'booking',
            entityId: existing.id,
            action: 'booking.fixed_fare_set',
            before: { fixedFareCents: patch.fixedFare.before },
            after: { fixedFareCents: patch.fixedFare.after },
          },
        });
      }
    });

    await this.events.emitAsync('booking.edited', {
      id: existing.id,
      branchId: existing.branchId,
      driverId: notesChanged ? existing.driverId : null,
      notesChanged,
    });
    return this.findOne(id, user);
  }

  async retrySearch(id: string, user: AuthUser) {
    const booking = await this.loadDetail(id, user);
    if (booking.status !== 'NO_DRIVER_FOUND') {
      throw new ConflictException('Only a booking with no driver can be retried');
    }
    await this.fleet.clearOfferedDrivers(booking.id);
    await this.state.transition(
      booking.id,
      'SEARCHING_DRIVER',
      { type: 'STAFF', userId: user.userId },
      {
        reason: 'Staff retried',
        patch: { searchStartedAt: new Date() },
      },
    );
    const fresh = await this.prisma.booking.findUnique({
      where: { id },
      select: { version: true, status: true, assignMode: true },
    });
    if (fresh?.assignMode === 'AUTO' && fresh.status === 'SEARCHING_DRIVER') {
      await this.dispatch.enqueueAttempt(id, fresh.version);
    }
    return this.findOne(id, user);
  }

  async release(user: AuthUser, id: string, dto: ReleaseBookingDto) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
      select: { id: true },
    });
    if (!driver) throw new NotFoundException();
    const result = await this.prisma.$transaction(async (tx) => {
      const booking = await tx.booking.findUnique({ where: { id } });
      if (!booking || booking.driverId !== driver.id) throw new NotFoundException();
      await this.closeAssignment(tx, booking.id, 'DRIVER_CANCELLED');
      return this.state.transition(
        booking.id,
        'SEARCHING_DRIVER',
        { type: 'DRIVER', userId: user.userId },
        { tx, reason: dto.reason.trim() },
      );
    });
    // Keep this driver out of the next auto-offer round for the same booking.
    await this.fleet.rememberOfferedDriver(result.bookingId, driver.id);
    await this.events.emitAsync('booking.status_changed', result);
    return { id: result.bookingId, status: result.to };
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
              assignMode: input.dto.assignMode ?? 'AUTO',
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
              ? await this.state.transition(
                  created.id,
                  'SEARCHING_DRIVER',
                  input.actor,
                  {
                    tx,
                  },
                )
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
    const pickup = [...booking.stops].sort(
      (left, right) => left.sequence - right.sequence,
    )[0];
    return {
      id: booking.id,
      branchId: booking.branchId,
      trackingId: booking.trackingId,
      status: booking.status,
      passengerName: booking.passengerName,
      scheduledAt: booking.scheduledAt?.toISOString() ?? null,
      quotedFareCents: booking.quotedFareCents,
      vehicleType: {
        id: booking.vehicleType.id,
        name: booking.vehicleType.name,
      },
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
    endReason: 'REASSIGNED' | 'BOOKING_CANCELLED' | 'DRIVER_CANCELLED',
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

  /** A valid token is the price that was shown. Dispatch may omit it and recompute. */
  private async quotedPrice(
    dto: CreateBookingDto,
    branchId: string,
    user: AuthUser,
  ) {
    const accepted = this.fares.acceptQuote(dto.quoteToken ?? '', {
      branchId,
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
        await this.fares.quotes(
          { stops: dto.stops, zone: dto.zone, branchId },
          user,
        ),
      );
    }
    return {
      meters: accepted.distanceM,
      seconds: accepted.durationS,
      subtotalCents: accepted.subtotalCents,
      taxCents: accepted.taxCents,
    };
  }

  private async recomputedPrice(
    branchId: string,
    dto: CreateBookingDto,
    pickup: GeoPoint,
    dropoff: GeoPoint,
    via: GeoPoint[],
    gstRateBps: number,
  ) {
    const rule = await this.prisma.fareRule.findUnique({
      where: {
        branchId_vehicleTypeId_zone: {
          branchId,
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
    const trip = await this.distance.estimate(pickup, dropoff, via);
    const fare = calcFare(rule, trip.meters, trip.seconds, gstRateBps);
    return {
      meters: trip.meters,
      seconds: trip.seconds,
      subtotalCents: fare.subtotalCents,
      taxCents: fare.taxCents,
    };
  }

  private assertStops(stops: CreateBookingDto['stops']) {
    const pickup = stops[0];
    const dropoff = stops[stops.length - 1];
    if (pickup.lat === dropoff.lat && pickup.lng === dropoff.lng) {
      throw new BadRequestException('Pickup and drop-off must differ');
    }
  }

  private async loadDetail(id: string, user: AuthUser) {
    const scope = this.scope(user);
    if (!scope) throw new NotFoundException();
    const booking = await this.prisma.booking.findFirst({
      where: { id, ...scope },
      include: detailInclude,
    });
    if (!booking) throw new NotFoundException();
    return booking;
  }

  private async present(
    booking: Prisma.BookingGetPayload<{ include: typeof detailInclude }>,
  ) {
    const assignment =
      booking.assignments.find((row) => row.endedAt == null) ??
      booking.assignments[0] ??
      null;
    const userIds = [booking.createdById, assignment?.assignedById].filter(
      (id): id is string => Boolean(id),
    );
    const people = userIds.length
      ? await this.prisma.user.findMany({
          where: { id: { in: userIds } },
          select: { id: true, displayName: true },
        })
      : [];
    const nameOf = (id: string | null | undefined) =>
      people.find((person) => person.id === id)?.displayName?.trim() || null;
    const offer = booking.offers[0] ?? null;
    return {
      ...booking,
      createdBy:
        booking.source === 'PASSENGER_APP'
          ? 'Passenger app'
          : (nameOf(booking.createdById) ?? 'Staff'),
      assignedBy: assignment
        ? assignment.method === 'AUTO'
          ? 'Auto'
          : (nameOf(assignment.assignedById) ?? 'Staff')
        : null,
      driverName: booking.driver
        ? `${booking.driver.firstName} ${booking.driver.lastName}`.trim()
        : null,
      driverUnit: booking.vehicle?.unitNumber ?? null,
      openOffer: offer
        ? {
            id: offer.id,
            driverId: offer.driverId,
            vehicleId: offer.vehicleId,
            expiresAt: offer.expiresAt,
            distanceToPickupM: offer.distanceToPickupM,
          }
        : null,
      editableFields: editableFields(booking.status),
    };
  }

  private nextValues(
    booking: Prisma.BookingGetPayload<{ include: typeof detailInclude }>,
    dto: UpdateBookingDto,
  ) {
    const stops = [...booking.stops]
      .sort((left, right) => left.sequence - right.sequence)
      .map(stopSnapshot);
    return {
      passengerName:
        dto.passengerName === undefined
          ? booking.passengerName
          : dto.passengerName.trim(),
      passengerPhone:
        dto.passengerPhone === undefined
          ? booking.passengerPhone
          : normalizePhone(dto.passengerPhone),
      vehicleTypeId: dto.vehicleTypeId ?? booking.vehicleTypeId,
      zone: dto.zone ?? booking.zone,
      vanOnly: dto.vanOnly ?? booking.vanOnly,
      ladyDriverOnly: dto.ladyDriverOnly ?? booking.ladyDriverOnly,
      scheduledAt:
        dto.scheduledAt === undefined
          ? booking.scheduledAt
          : new Date(dto.scheduledAt),
      paymentMethod: dto.paymentMethod ?? booking.paymentMethod,
      notes:
        dto.notes === undefined ? booking.notes : dto.notes.trim() || null,
      fixedFareCents:
        dto.fixedFareCents === undefined
          ? booking.fixedFareCents
          : dto.fixedFareCents,
      stops: dto.stops
        ? dto.stops.map((stop) => ({
            address: stop.address.trim(),
            lat: stop.lat,
            lng: stop.lng,
            placeId: stop.placeId ?? null,
          }))
        : stops,
    };
  }

  private async requote(
    booking: Prisma.BookingGetPayload<{ include: typeof detailInclude }>,
    next: ReturnType<BookingsService['nextValues']>,
    user: AuthUser,
  ) {
    const pickup = next.stops[0];
    const dropoff = next.stops[next.stops.length - 1];
    if (
      !pickup ||
      !dropoff ||
      (pickup.lat === dropoff.lat && pickup.lng === dropoff.lng)
    ) {
      throw new BadRequestException('Pickup and drop-off must differ');
    }
    const quote = await this.fares.quotes(
      {
        branchId: booking.branchId,
        zone: next.zone,
        stops: next.stops.map((stop) => ({ lat: stop.lat, lng: stop.lng })),
      },
      user,
    );
    const option = quote.options.find(
      (row) => row.vehicleTypeId === next.vehicleTypeId,
    );
    if (!option) {
      throw new NotFoundException(
        'No active fare rule for this vehicle type and zone',
      );
    }
    return {
      distanceMeters: quote.distanceM,
      durationSeconds: quote.durationS,
      quotedFareCents: option.subtotalCents,
      quotedTaxCents: option.taxCents,
    };
  }

  private applyTab(
    where: Prisma.BookingWhereInput,
    and: Prisma.BookingWhereInput[],
    query: BookingQuery,
  ) {
    if (!query.tab) {
      if (query.status) where.status = query.status;
      return true;
    }
    if (query.tab === 'timeout') {
      const cutoff = new Date(
        Date.now() - this.readInt('MANUAL_WAIT_ALERT_MINUTES', 5) * 60_000,
      );
      const waiting: Prisma.BookingWhereInput = {
        status: 'SEARCHING_DRIVER',
        assignMode: 'MANUAL',
        OR: [
          { searchStartedAt: { lt: cutoff } },
          { searchStartedAt: null, createdAt: { lt: cutoff } },
        ],
      };
      if (query.status === 'NO_DRIVER_FOUND') {
        where.status = 'NO_DRIVER_FOUND';
        return true;
      }
      if (query.status === 'SEARCHING_DRIVER') {
        and.push(waiting);
        return true;
      }
      if (query.status) return false;
      and.push({ OR: [{ status: 'NO_DRIVER_FOUND' }, waiting] });
      return true;
    }
    const tab: readonly BookingStatus[] = BOOKING_TABS[query.tab as BookingTab];
    if (query.status && !tab.includes(query.status)) return false;
    if (query.status) where.status = query.status;
    else where.status = { in: [...tab] };
    return true;
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
      const branch = await this.prisma.branch.findUnique({
        where: { id: requested },
      });
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

  private serviceWindow(
    from?: string,
    to?: string,
  ): Prisma.DateTimeFilter | undefined {
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

const EDIT_KEYS = [
  'passengerName',
  'passengerPhone',
  'scheduledAt',
  'vanOnly',
  'ladyDriverOnly',
  'vehicleTypeId',
  'zone',
  'stops',
  'fixedFareCents',
  'paymentMethod',
  'notes',
] as const;

function requestedFields(dto: UpdateBookingDto) {
  return EDIT_KEYS.filter((key) => dto[key] !== undefined);
}

function stopSnapshot(stop: {
  address: string;
  lat: number;
  lng: number;
  placeId?: string | null;
}) {
  return {
    address: stop.address,
    lat: stop.lat,
    lng: stop.lng,
    placeId: stop.placeId ?? null,
  };
}

function sameStops(
  current: {
    sequence: number;
    address: string;
    lat: number;
    lng: number;
    placeId: string | null;
  }[],
  next: {
    address: string;
    lat: number;
    lng: number;
    placeId: string | null;
  }[],
) {
  const left = [...current]
    .sort((a, b) => a.sequence - b.sequence)
    .map(stopSnapshot);
  return JSON.stringify(left) === JSON.stringify(next);
}

function changedPatch(
  booking: {
    passengerName: string;
    passengerPhone: string;
    vehicleTypeId: string;
    zone: string;
    vanOnly: boolean;
    ladyDriverOnly: boolean;
    scheduledAt: Date | null;
    paymentMethod: string;
    notes: string | null;
    fixedFareCents: number | null;
    stops: {
      sequence: number;
      address: string;
      lat: number;
      lng: number;
      placeId: string | null;
    }[];
    distanceMeters: number;
    durationSeconds: number;
    quotedFareCents: number;
    quotedTaxCents: number;
  },
  next: ReturnType<BookingsService['nextValues']>,
  priced: {
    distanceMeters: number;
    durationSeconds: number;
    quotedFareCents: number;
    quotedTaxCents: number;
  } | null,
) {
  const before: Record<string, unknown> = {};
  const after: Record<string, unknown> = {};
  const data: Prisma.BookingUncheckedUpdateManyInput = {};

  const text: [keyof typeof data, unknown, unknown][] = [
    ['passengerName', booking.passengerName, next.passengerName],
    ['passengerPhone', booking.passengerPhone, next.passengerPhone],
    ['vehicleTypeId', booking.vehicleTypeId, next.vehicleTypeId],
    ['zone', booking.zone, next.zone],
    ['vanOnly', booking.vanOnly, next.vanOnly],
    ['ladyDriverOnly', booking.ladyDriverOnly, next.ladyDriverOnly],
    ['paymentMethod', booking.paymentMethod, next.paymentMethod],
    ['notes', booking.notes, next.notes],
    ['fixedFareCents', booking.fixedFareCents, next.fixedFareCents],
  ];
  for (const [key, was, now] of text) {
    if (was === now) continue;
    data[key] = now as never;
    before[key] = was;
    after[key] = now;
  }
  const wasAt = booking.scheduledAt?.getTime() ?? null;
  const nowAt = next.scheduledAt?.getTime() ?? null;
  if (wasAt !== nowAt) {
    data.scheduledAt = next.scheduledAt;
    before.scheduledAt = booking.scheduledAt?.toISOString() ?? null;
    after.scheduledAt = next.scheduledAt?.toISOString() ?? null;
  }
  let stops: ReturnType<BookingsService['nextValues']>['stops'] | undefined;
  if (!sameStops(booking.stops, next.stops)) {
    stops = next.stops;
    before.stops = [...booking.stops]
      .sort((left, right) => left.sequence - right.sequence)
      .map(stopSnapshot);
    after.stops = next.stops;
  }
  if (priced) {
    const money: [keyof typeof data, number, number][] = [
      ['distanceMeters', booking.distanceMeters, priced.distanceMeters],
      ['durationSeconds', booking.durationSeconds, priced.durationSeconds],
      ['quotedFareCents', booking.quotedFareCents, priced.quotedFareCents],
      ['quotedTaxCents', booking.quotedTaxCents, priced.quotedTaxCents],
    ];
    for (const [key, was, now] of money) {
      if (was === now) continue;
      data[key] = now as never;
      before[key] = was;
      after[key] = now;
    }
  }
  if (Object.keys(before).length === 0) return null;
  const fixedFare =
    before.fixedFareCents !== undefined
      ? {
          before: before.fixedFareCents as number | null,
          after: after.fixedFareCents as number | null,
        }
      : null;
  return {
    data,
    stops,
    before: before as Prisma.InputJsonValue,
    after: after as Prisma.InputJsonValue,
    fixedFare,
  };
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
    if (
      target.includes('driverId') ||
      target.includes('one_active_booking_per_driver')
    ) {
      throw new ConflictException('Driver is busy');
    }
    throw new ConflictException('Booking already has an open assignment');
  }
  throw error;
}
