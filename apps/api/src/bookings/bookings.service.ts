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
import { finalizeFare, splitFare } from '../fares/finalize-fare.js';
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
import { CorporateCreditService } from '../corporate/corporate-credit.service.js';
import { accountTripLedgerLines } from '../ledger/account-ledger-lines.js';
import { cashTripLedgerLines } from '../ledger/cash-ledger-lines.js';
import { LedgerService } from '../ledger/ledger.service.js';
import { CardHoldService } from '../payments/card-hold.service.js';
import { PaymentProvidersService } from '../payments/payment-providers.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { PromosService } from '../promos/promos.service.js';
import { assertScheduledAt } from './booking-schedule.js';
import {
  BookingStateService,
  type BookingTransitionResult,
} from './booking-state.service.js';
import { BOOKING_TABS, type BookingTab } from './booking-tabs.js';
import { assertEditable, editableFields } from './booking-edit.js';
import type { AdjustFareDto } from './dto/adjust-fare.dto.js';
import type { AssignBookingDto } from './dto/assign-booking.dto.js';
import type { DispatchModeDto } from './dto/dispatch-mode.dto.js';
import type { BookingQuery } from './dto/booking-query.dto.js';
import type { BookingStatusDto } from './dto/booking-status.dto.js';
import type { CancelBookingDto } from './dto/cancel-booking.dto.js';
import type { CreateBookingDto } from './dto/create-booking.dto.js';
import type { RefundBookingDto } from './dto/refund-booking.dto.js';
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
const CASH_STAFF_ROLES = [
  'branch_admin',
  'accounts_admin',
  'super_admin',
] as const;
const ADJUST_FARE_ROLES = ['branch_admin', 'accounts_admin'] as const;
const REFUND_ROLES = ['accounts_admin', 'super_admin'] as const;

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
    private readonly ledger: LedgerService,
    private readonly paymentProviders: PaymentProvidersService,
    private readonly cardHolds: CardHoldService,
    private readonly corporateCredit: CorporateCreditService,
    private readonly promos: PromosService,
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
    const accountBooking = await this.prepareAccountBooking(
      user,
      dto,
      branch.id,
      priced.subtotalCents + priced.taxCents,
    );
    const initial: BookingStatus = scheduledAt ? 'SCHEDULED' : 'CREATED';
    const actor = { type: 'STAFF' as const, userId: user.userId };
    const openedAt = new Date(Date.now() - 1);

    const inserted = await this.insertBooking({
      dto,
      user,
      branchId: branch.id,
      gstRateBps: branch.gstRateBps,
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
      accountBooking,
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

  /**
   * Finalizes fare cents and moves TRIP_STARTED → TRIP_COMPLETED → PAYMENT_PENDING.
   * The Day 5 fleet bridge frees the driver on TRIP_COMPLETED so they can take
   * another job while payment is still pending. For CARD, capture is requested
   * here; the Stripe webhook posts TRIP_CARD and closes the booking. For ACCOUNT,
   * AR is posted in this same transaction and the booking closes immediately.
   */
  async complete(user: AuthUser, id: string) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
      select: { id: true },
    });
    if (!driver) throw new NotFoundException();

    const { completed, pending, paid, closed, response, cardCapture } =
      await this.prisma.$transaction(async (tx) => {
        const booking = await tx.booking.findUnique({
          where: { id },
          include: { branch: { select: { commissionBps: true } } },
        });
        if (!booking || booking.driverId !== driver.id) {
          throw new NotFoundException();
        }
        if (booking.status !== 'TRIP_STARTED') {
          throw new ConflictException(
            `Illegal transition ${booking.status} → TRIP_COMPLETED`,
          );
        }

        const fare = finalizeFare({
          quotedSubtotalCents: booking.quotedFareCents,
          fixedFareCents: booking.fixedFareCents,
          gstBps: booking.gstRateBps,
          fixedIncludesGst: this.fixedFareIncludesGst(),
        });
        const commissionBps = booking.branch.commissionBps;
        const split = splitFare(fare.subtotalCents, commissionBps);
        const completedAt = new Date();
        const patch = {
          completedAt,
          finalSubtotalCents: fare.subtotalCents,
          finalTaxCents: fare.taxCents,
          finalFareCents: fare.totalCents,
          commissionBps,
          commissionCents: split.commissionCents,
          driverEarningCents: split.driverEarningCents,
        };

        const completed = await this.state.transition(
          booking.id,
          'TRIP_COMPLETED',
          { type: 'DRIVER', userId: user.userId },
          { tx, patch },
        );
        const pending = await this.state.transition(
          booking.id,
          'PAYMENT_PENDING',
          { type: 'SYSTEM' },
          { tx },
        );

        let cardCapture:
          | {
              providerRef: string;
              amountCents: number;
              idempotencyKey: string;
            }
          | undefined;
        let paid: BookingTransitionResult | null = null;
        let closed: BookingTransitionResult | null = null;
        let status = pending.to;

        if (booking.paymentMethod === 'CARD') {
          cardCapture = await this.prepareCardCapture(tx, {
            bookingId: booking.id,
            finalFareCents: fare.totalCents,
          });
        } else if (booking.paymentMethod === 'ACCOUNT') {
          ({ paid, closed, status } = await this.settleAccountTrip(tx, {
            booking,
            fare,
            split,
          }));
        }

        return {
          completed,
          pending,
          paid,
          closed,
          cardCapture,
          response: {
            id: booking.id,
            status,
            paymentMethod: booking.paymentMethod,
            ...(booking.paymentMethod === 'ACCOUNT'
              ? { paymentStatus: 'PAID' as const }
              : {}),
            finalSubtotalCents: fare.subtotalCents,
            finalTaxCents: fare.taxCents,
            finalFareCents: fare.totalCents,
            commissionBps,
            commissionCents: split.commissionCents,
            driverEarningCents: split.driverEarningCents,
          },
        };
      });

    await this.events.emitAsync('booking.status_changed', completed);
    await this.events.emitAsync('booking.status_changed', pending);
    if (paid) await this.events.emitAsync('booking.status_changed', paid);
    if (closed) await this.events.emitAsync('booking.status_changed', closed);

    if (cardCapture) {
      // Webhook confirms capture and posts the ledger — do not close here.
      await this.paymentProviders.get('STRIPE').capture({
        providerRef: cardCapture.providerRef,
        amountCents: cardCapture.amountCents,
        idempotencyKey: cardCapture.idempotencyKey,
      });
    }

    return response;
  }

  /**
   * Caps capture at the authorization hold. Overage stays UNPAID for manual
   * review on the payment_pending tab (no automatic second charge yet).
   */
  private async prepareCardCapture(
    tx: Prisma.TransactionClient,
    input: { bookingId: string; finalFareCents: number },
  ) {
    const payment = await tx.payment.findFirst({
      where: {
        bookingId: input.bookingId,
        provider: 'STRIPE',
        purpose: 'TRIP_AUTH_CAPTURE',
        status: 'AUTHORIZED',
      },
    });
    if (!payment?.providerRef || !payment.idempotencyKey) {
      throw new ConflictException('Authorized card payment not found');
    }

    if (input.finalFareCents > payment.amountCents) {
      await tx.booking.update({
        where: { id: input.bookingId },
        data: { paymentStatus: 'UNPAID' },
      });
      this.logger.warn(
        `Booking ${input.bookingId} final fare exceeds authorization; needs a top-up charge`,
      );
    }

    return {
      providerRef: payment.providerRef,
      amountCents: Math.min(input.finalFareCents, payment.amountCents),
      // Same Payment.idempotencyKey as authorize; Stripe scopes keys per endpoint.
      idempotencyKey: payment.idempotencyKey,
    };
  }

  /**
   * Posts TRIP_ACCOUNT ledger lines, marks PAID, and closes in the same txn.
   * PAID here means the trip is operationally resolved — not that the invoice
   * has been collected.
   */
  private async settleAccountTrip(
    tx: Prisma.TransactionClient,
    input: {
      booking: {
        id: string;
        branchId: string;
        driverId: string | null;
        corporateAccountId: string | null;
      };
      fare: {
        subtotalCents: number;
        taxCents: number;
        totalCents: number;
      };
      split: { commissionCents: number; driverEarningCents: number };
    },
  ) {
    if (!input.booking.corporateAccountId || !input.booking.driverId) {
      throw new ConflictException(
        'Account booking is missing corporate account or driver',
      );
    }

    await tx.payment.create({
      data: {
        bookingId: input.booking.id,
        method: 'ACCOUNT',
        provider: 'INTERNAL',
        purpose: 'TRIP_AUTH_CAPTURE',
        status: 'CAPTURED',
        amountCents: input.fare.totalCents,
        currency: 'CAD',
        idempotencyKey: `account:${input.booking.id}`,
        capturedAt: new Date(),
      },
    });

    await this.ledger.post(tx, {
      kind: 'TRIP_ACCOUNT',
      sourceType: 'BOOKING',
      sourceId: input.booking.id,
      branchId: input.booking.branchId,
      description: 'Corporate account trip settlement',
      lines: accountTripLedgerLines({
        branchId: input.booking.branchId,
        driverId: input.booking.driverId,
        corporateAccountId: input.booking.corporateAccountId,
        subtotalCents: input.fare.subtotalCents,
        taxCents: input.fare.taxCents,
        commissionCents: input.split.commissionCents,
        driverEarningCents: input.split.driverEarningCents,
      }),
    });

    await tx.booking.update({
      where: { id: input.booking.id },
      data: { paymentStatus: 'PAID' },
    });

    const paid = await this.state.transition(
      input.booking.id,
      'PAYMENT_COMPLETED',
      { type: 'SYSTEM' },
      { tx },
    );
    const closed = await this.state.transition(
      input.booking.id,
      'CLOSED',
      { type: 'SYSTEM' },
      { tx },
    );
    return { paid, closed, status: closed.to as BookingStatus };
  }

  private async prepareAccountBooking(
    user: AuthUser,
    dto: CreateBookingDto,
    branchId: string,
    totalCents: number,
  ) {
    if (dto.paymentMethod !== 'ACCOUNT') return undefined;
    if (!dto.corporateAccountId) {
      throw new BadRequestException(
        'corporateAccountId is required for ACCOUNT bookings',
      );
    }

    const account = await this.prisma.corporateAccount.findFirst({
      where: { id: dto.corporateAccountId, branchId },
    });
    if (!account) throw new NotFoundException('Corporate account not found');

    let corporateContactId: string | null = null;
    if (dto.corporateContactId) {
      const contact = await this.prisma.corporateAccountContact.findFirst({
        where: {
          id: dto.corporateContactId,
          accountId: account.id,
          active: true,
        },
      });
      if (!contact) {
        throw new BadRequestException(
          'corporateContactId must belong to the corporate account',
        );
      }
      corporateContactId = contact.id;
    }

    let creditOverride:
      | {
          currentCents: number;
          limitCents: number;
          requestedCents: number;
          reason: string;
        }
      | undefined;
    try {
      await this.corporateCredit.checkCreditLimit(account.id, totalCents);
    } catch (error) {
      if (
        !(error instanceof ConflictException) ||
        !isCreditLimitExceeded(error)
      ) {
        throw error;
      }
      if (!dto.overrideCreditLimit) throw error;
      if (!(await this.hasPermission(user, 'corporate.override_credit_limit'))) {
        throw new ForbiddenException(
          'Missing permission corporate.override_credit_limit',
        );
      }
      const reason = dto.overrideReason?.trim();
      if (!reason) {
        throw new BadRequestException(
          'overrideReason is required when overrideCreditLimit is true',
        );
      }
      const body = error.getResponse() as {
        currentCents: number;
        limitCents: number;
        requestedCents: number;
      };
      creditOverride = {
        currentCents: body.currentCents,
        limitCents: body.limitCents,
        requestedCents: body.requestedCents,
        reason,
      };
    }

    return {
      corporateAccountId: account.id,
      corporateContactId,
      creditOverride,
    };
  }

  private async hasPermission(user: AuthUser, code: string) {
    const row = await this.prisma.rolePermission.findFirst({
      where: {
        role: { name: user.role },
        permission: { code },
      },
      select: { roleId: true },
    });
    return Boolean(row);
  }

  /** Driver confirms cash received. Retries are safe once CLOSED + CAPTURED. */
  async collectCashAsDriver(user: AuthUser, id: string) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
      select: { id: true },
    });
    if (!driver) throw new NotFoundException();
    return this.collectCash({
      bookingId: id,
      actor: { type: 'DRIVER', userId: user.userId },
      assertAccess: (booking) => {
        if (booking.driverId !== driver.id) throw new NotFoundException();
      },
    });
  }

  /** Staff cash confirmation. Writes an audit row with the actor. */
  async collectCashAsStaff(user: AuthUser, id: string) {
    this.assertRole(user, CASH_STAFF_ROLES);
    return this.collectCash({
      bookingId: id,
      actor: { type: 'STAFF', userId: user.userId },
      assertAccess: (booking) => {
        const scope = this.scope(user);
        if (!scope) throw new NotFoundException();
        if (scope.branchId && booking.branchId !== scope.branchId) {
          throw new NotFoundException();
        }
      },
      audit: true,
    });
  }

  /**
   * Recompute tax/commission while still PAYMENT_PENDING. Once paid, fare
   * corrections go through ledger reversal instead.
   */
  async adjustFare(user: AuthUser, id: string, dto: AdjustFareDto) {
    this.assertRole(user, ADJUST_FARE_ROLES);
    const maxCents = this.readInt('FIXED_FARE_MAX_CENTS', 50_000);
    if (dto.subtotalCents > maxCents) {
      throw new BadRequestException(
        `subtotalCents cannot exceed ${maxCents}`,
      );
    }
    const reason = dto.reason.trim();
    if (!reason) throw new BadRequestException('reason is required');

    const updated = await this.prisma.$transaction(async (tx) => {
      const booking = await this.requireBooking(tx, id, user);
      if (booking.status !== 'PAYMENT_PENDING') {
        throw new ConflictException(
          'Fare can only be adjusted while payment is pending',
        );
      }
      if (booking.commissionBps == null) {
        throw new ConflictException('Booking has no commission snapshot');
      }
      const taxCents = Math.round(
        (dto.subtotalCents * booking.gstRateBps) / 10000,
      );
      const split = splitFare(dto.subtotalCents, booking.commissionBps);
      const before = {
        finalSubtotalCents: booking.finalSubtotalCents,
        finalTaxCents: booking.finalTaxCents,
        finalFareCents: booking.finalFareCents,
        commissionCents: booking.commissionCents,
        driverEarningCents: booking.driverEarningCents,
      };
      const after = {
        finalSubtotalCents: dto.subtotalCents,
        finalTaxCents: taxCents,
        finalFareCents: dto.subtotalCents + taxCents,
        commissionCents: split.commissionCents,
        driverEarningCents: split.driverEarningCents,
      };
      const saved = await tx.booking.updateMany({
        where: { id: booking.id, status: 'PAYMENT_PENDING' },
        data: { ...after, version: { increment: 1 } },
      });
      if (saved.count !== 1) {
        throw new ConflictException('Booking changed, retry');
      }
      await tx.auditLog.create({
        data: {
          actorUserId: user.userId,
          actorType: 'STAFF',
          entity: 'booking',
          entityId: booking.id,
          action: 'booking.fare_adjusted',
          before: { ...before, reason: null },
          after: { ...after, reason },
        },
      });
      return {
        id: booking.id,
        status: booking.status,
        driverId: booking.driverId,
        ...after,
      };
    });
    // Amounts live in pendingPayment — bump the driver snapshot so collect refreshes.
    if (updated.driverId) {
      await this.fleet.republishSnapshot(updated.driverId);
    }
    return updated;
  }

  private async collectCash(input: {
    bookingId: string;
    actor: { type: 'DRIVER' | 'STAFF'; userId: string };
    assertAccess: (booking: {
      id: string;
      branchId: string;
      driverId: string | null;
      status: BookingStatus;
      paymentMethod: string;
    }) => void;
    audit?: boolean;
  }) {
    const { paid, closed, response } = await this.prisma.$transaction(
      async (tx) => {
        // Serialize concurrent cash confirms so the unique payment insert never
        // aborts a peer transaction mid-flight (Postgres 25P02).
        await tx.$queryRaw`
          SELECT 1 FROM "Booking" WHERE id = ${input.bookingId} FOR UPDATE
        `;
        const booking = await tx.booking.findUnique({
          where: { id: input.bookingId },
        });
        if (!booking) throw new NotFoundException();
        input.assertAccess(booking);

        const captured = await tx.payment.findFirst({
          where: { bookingId: booking.id, status: 'CAPTURED' },
        });
        // With FOR UPDATE, a concurrent loser always observes CLOSED + CAPTURED.
        if (captured && booking.status === 'CLOSED') {
          return {
            paid: null,
            closed: null,
            response: cashCollectedResponse(booking, captured),
          };
        }

        if (booking.status !== 'PAYMENT_PENDING') {
          throw new ConflictException(
            `Illegal transition ${booking.status} → PAYMENT_COMPLETED`,
          );
        }
        if (booking.paymentMethod !== 'CASH') {
          throw new ConflictException('Booking is not a cash payment');
        }
        if (
          booking.finalFareCents == null ||
          booking.finalSubtotalCents == null ||
          booking.finalTaxCents == null ||
          booking.commissionCents == null ||
          booking.driverEarningCents == null ||
          !booking.driverId
        ) {
          throw new ConflictException('Booking is missing settlement amounts');
        }

        const amountCents = booking.finalFareCents;
        const idempotencyKey = `cash:${booking.id}`;
        // Cash confirms receipt in one step; authorize returns CAPTURED.
        const outcome = await this.paymentProviders.get('CASH').authorize({
          bookingId: booking.id,
          amountCents,
          idempotencyKey,
        });

        const payment =
          captured ??
          (await tx.payment.create({
            data: {
              bookingId: booking.id,
              method: 'CASH',
              provider: 'CASH',
              status: outcome.status,
              amountCents,
              currency: 'CAD',
              providerRef: outcome.providerRef,
              idempotencyKey,
              capturedAt: new Date(),
              createdById: input.actor.userId,
            },
          }));

        await this.ledger.post(tx, {
          kind: 'TRIP_CASH',
          sourceType: 'BOOKING',
          sourceId: booking.id,
          branchId: booking.branchId,
          description: 'Cash trip settlement',
          createdById: input.actor.userId,
          lines: cashTripLedgerLines({
            branchId: booking.branchId,
            driverId: booking.driverId,
            subtotalCents: booking.finalSubtotalCents,
            taxCents: booking.finalTaxCents,
            commissionCents: booking.commissionCents,
            driverEarningCents: booking.driverEarningCents,
          }),
        });

        await tx.booking.update({
          where: { id: booking.id },
          data: { paymentStatus: 'PAID' },
        });

        if (input.audit && !captured) {
          await tx.auditLog.create({
            data: {
              actorUserId: input.actor.userId,
              actorType: 'STAFF',
              entity: 'booking',
              entityId: booking.id,
              action: 'booking.cash_collected',
              before: {
                status: booking.status,
                paymentStatus: booking.paymentStatus,
              },
              after: {
                status: 'CLOSED',
                paymentStatus: 'PAID',
                paymentId: payment.id,
                amountCents,
              },
            },
          });
        }

        const paid = await this.state.transition(
          booking.id,
          'PAYMENT_COMPLETED',
          input.actor,
          { tx },
        );
        const closed = await this.state.transition(
          booking.id,
          'CLOSED',
          { type: 'SYSTEM' },
          { tx },
        );
        const settled = await tx.booking.findUniqueOrThrow({
          where: { id: booking.id },
        });
        return {
          paid,
          closed,
          response: cashCollectedResponse(settled, payment),
        };
      },
    );

    if (paid) await this.events.emitAsync('booking.status_changed', paid);
    if (closed) await this.events.emitAsync('booking.status_changed', closed);
    return response;
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
      await this.promos.releaseIfAny(tx, booking.id);
      return this.state.transition(
        booking.id,
        'CANCELLED',
        { type: 'STAFF', userId: user.userId },
        { tx, ...this.cancellation(dto.reason, dto.note) },
      );
    });
    await this.cardHolds.releaseAuthorized(result.bookingId);
    return this.afterTransition(result, user);
  }

  /**
   * Refunds a captured card payment via Stripe. Ledger REVERSAL is applied by
   * the charge.refunded webhook once Stripe confirms the refund.
   */
  async refund(id: string, dto: RefundBookingDto, user: AuthUser) {
    this.assertRole(user, REFUND_ROLES);
    const reason = dto.reason.trim();
    if (!reason) throw new BadRequestException('reason is required');

    const booking = await this.prisma.booking.findFirst({
      where: { id, ...branchWhere(user) },
    });
    if (!booking) throw new NotFoundException();
    if (booking.paymentMethod !== 'CARD') {
      throw new ConflictException('Booking is not a card payment');
    }

    const payment = await this.prisma.payment.findFirst({
      where: {
        bookingId: booking.id,
        provider: 'STRIPE',
        status: 'CAPTURED',
        purpose: 'TRIP_AUTH_CAPTURE',
      },
      orderBy: { createdAt: 'desc' },
    });
    if (!payment?.providerRef) {
      throw new ConflictException('No captured card payment to refund');
    }
    if (dto.amountCents > payment.amountCents) {
      throw new BadRequestException(
        'amountCents cannot exceed the captured payment',
      );
    }

    const idempotencyKey = `refund:${payment.id}:${dto.amountCents}`;
    await this.paymentProviders.get('STRIPE').refund({
      providerRef: payment.providerRef,
      amountCents: dto.amountCents,
      idempotencyKey,
    });

    await this.prisma.auditLog.create({
      data: {
        actorUserId: user.userId,
        actorType: 'STAFF',
        entity: 'booking',
        entityId: booking.id,
        action: 'booking.refund_requested',
        before: {
          paymentStatus: booking.paymentStatus,
          paymentId: payment.id,
        },
        after: {
          amountCents: dto.amountCents,
          reason,
          providerRef: payment.providerRef,
          idempotencyKey,
        },
      },
    });

    return {
      id: booking.id,
      paymentId: payment.id,
      providerRef: payment.providerRef,
      amountCents: dto.amountCents,
      status: 'REFUND_REQUESTED' as const,
    };
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
          await this.promos.releaseIfAny(tx, booking.id);
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
    if (result.to === 'CANCELLED') {
      await this.cardHolds.releaseAuthorized(result.bookingId);
    }
    return this.afterTransition(result, user);
  }

  private async insertBooking(input: {
    dto: CreateBookingDto;
    user: AuthUser;
    branchId: string;
    gstRateBps: number;
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
    accountBooking?: {
      corporateAccountId: string;
      corporateContactId: string | null;
      creditOverride?: {
        currentCents: number;
        limitCents: number;
        requestedCents: number;
        reason: string;
      };
    };
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
              gstRateBps: input.gstRateBps,
              fixedFareCents: input.dto.fixedFareCents,
              paymentMethod: input.dto.paymentMethod,
              corporateAccountId: input.accountBooking?.corporateAccountId,
              corporateContactId: input.accountBooking?.corporateContactId,
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
          if (input.accountBooking?.creditOverride) {
            const override = input.accountBooking.creditOverride;
            await tx.auditLog.create({
              data: {
                actorUserId: input.user.userId,
                actorType: 'STAFF',
                entity: 'booking',
                entityId: created.id,
                action: 'booking.credit_limit_override',
                after: {
                  corporateAccountId: input.accountBooking.corporateAccountId,
                  currentCents: override.currentCents,
                  limitCents: override.limitCents,
                  requestedCents: override.requestedCents,
                  reason: override.reason,
                  approvedById: input.user.userId,
                },
              },
            });
          }
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

  private fixedFareIncludesGst() {
    const raw = this.config
      .get<string>('FIXED_FARE_INCLUDES_GST')
      ?.trim()
      .toLowerCase();
    return raw === '1' || raw === 'true' || raw === 'yes';
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

function isUniqueConflict(error: unknown) {
  return (
    error instanceof Prisma.PrismaClientKnownRequestError &&
    error.code === 'P2002'
  );
}

function cashCollectedResponse(
  booking: {
    id: string;
    status: BookingStatus;
    paymentStatus: string;
    paymentMethod: string;
    finalSubtotalCents: number | null;
    finalTaxCents: number | null;
    finalFareCents: number | null;
    commissionBps: number | null;
    commissionCents: number | null;
    driverEarningCents: number | null;
  },
  payment: {
    id: string;
    status: string;
    amountCents: number;
    capturedAt: Date | null;
  },
) {
  return {
    id: booking.id,
    status: booking.status,
    paymentStatus: booking.paymentStatus,
    paymentMethod: booking.paymentMethod,
    finalSubtotalCents: booking.finalSubtotalCents,
    finalTaxCents: booking.finalTaxCents,
    finalFareCents: booking.finalFareCents,
    commissionBps: booking.commissionBps,
    commissionCents: booking.commissionCents,
    driverEarningCents: booking.driverEarningCents,
    payment: {
      id: payment.id,
      status: payment.status,
      amountCents: payment.amountCents,
      capturedAt: payment.capturedAt?.toISOString() ?? null,
    },
  };
}

function isCreditLimitExceeded(error: ConflictException) {
  const body = error.getResponse();
  return (
    typeof body === 'object' &&
    body !== null &&
    'code' in body &&
    (body as { code: string }).code === ApiCode.CREDIT_LIMIT_EXCEEDED
  );
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
