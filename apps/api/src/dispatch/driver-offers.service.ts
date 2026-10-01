import {
  GoneException,
  Inject,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import type { Prisma } from '@prisma/client';
import type { AuthUser } from '../common/auth-user.js';
import { BookingStateService } from '../bookings/booking-state.service.js';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { DISPATCH_QUEUE, type DispatchQueue } from '../jobs/dispatch-queue.js';
import {
  OFFER_EXPIRY_SCHEDULER,
  type OfferExpiryScheduler,
} from '../jobs/offer-expiry.scheduler.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { OFFER_RESOLVED } from './offer-events.js';

const offerSelect = {
  bookingId: true,
  driverId: true,
  vehicleId: true,
  booking: { select: { branchId: true, status: true, driverId: true } },
} satisfies Prisma.BookingOfferSelect;

@Injectable()
export class DriverOffersService {
  private readonly logger = new Logger(DriverOffersService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly state: BookingStateService,
    private readonly fleet: FleetStateService,
    private readonly events: EventEmitter2,
    @Inject(DISPATCH_QUEUE) private readonly queue: DispatchQueue,
    @Inject(OFFER_EXPIRY_SCHEDULER) private readonly expiry: OfferExpiryScheduler,
  ) {}

  async accept(user: AuthUser, offerId: string) {
    const driver = await this.driverFor(user);
    const outcome = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.bookingOffer.updateMany({
        where: {
          id: offerId,
          driverId: driver.id,
          status: 'OFFERED',
          expiresAt: { gt: new Date() },
        },
        data: { status: 'ACCEPTED', respondedAt: new Date() },
      });
      if (updated.count !== 1) return null;
      const offer = await tx.bookingOffer.findUnique({
        where: { id: offerId },
        select: offerSelect,
      });
      if (!offer) return null;
      const transition = await this.state.transition(
        offer.bookingId,
        'DRIVER_ASSIGNED',
        { type: 'DRIVER', userId: user.userId },
        { tx, patch: { assignedAt: new Date() } },
      );
      await tx.bookingAssignment.create({
        data: {
          bookingId: offer.bookingId,
          driverId: offer.driverId,
          vehicleId: offer.vehicleId,
          method: 'AUTO',
        },
      });
      return { transition };
    });

    if (!outcome) return this.replayOrGone(driver.id, offerId, user, 'ACCEPTED');

    await this.events.emitAsync('booking.status_changed', outcome.transition);
    await this.emitResolved(offerId, {
      bookingId: outcome.transition.bookingId,
      driverId: driver.id,
      branchId: outcome.transition.branchId,
      outcome: 'ACCEPTED',
    });
    await this.cancelQuietly(offerId);
    return this.fleet.state(user);
  }

  async decline(user: AuthUser, offerId: string, reason?: string) {
    const driver = await this.driverFor(user);
    const declineReason = reason?.trim() || null;
    const outcome = await this.prisma.$transaction(async (tx) => {
      const updated = await tx.bookingOffer.updateMany({
        where: { id: offerId, driverId: driver.id, status: 'OFFERED' },
        data: { status: 'DECLINED', respondedAt: new Date(), declineReason },
      });
      if (updated.count !== 1) return null;
      const offer = await tx.bookingOffer.findUnique({
        where: { id: offerId },
        select: offerSelect,
      });
      if (!offer) return null;
      const stillMatched =
        offer.booking.status === 'MATCHED' && offer.booking.driverId === offer.driverId;
      const transition = stillMatched
        ? await this.state.transition(
            offer.bookingId,
            'SEARCHING_DRIVER',
            { type: 'SYSTEM' },
            { tx, reason: declineReason ?? 'Offer declined' },
          )
        : null;
      return { offer, transition };
    });

    if (!outcome) return this.replayOrGone(driver.id, offerId, user, 'DECLINED');

    await this.releaseQuietly(
      outcome.offer.booking.branchId,
      outcome.offer.driverId,
      outcome.offer.bookingId,
    );
    await this.cancelQuietly(offerId);
    await this.emitResolved(offerId, {
      bookingId: outcome.offer.bookingId,
      driverId: outcome.offer.driverId,
      branchId: outcome.offer.booking.branchId,
      outcome: 'DECLINED',
    });
    if (!outcome.transition) return this.fleet.state(user);

    try {
      await this.events.emitAsync('booking.status_changed', outcome.transition);
    } catch (error) {
      this.logger.warn(
        `Offer ${offerId} declined before dispatch was told: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
    const booking = await this.prisma.booking.findUnique({
      where: { id: outcome.transition.bookingId },
      select: { version: true, status: true, assignMode: true },
    });
    if (booking?.status === 'SEARCHING_DRIVER' && booking.assignMode === 'AUTO') {
      await this.queue.enqueueAttempt(outcome.transition.bookingId, booking.version);
    }
    return this.fleet.state(user);
  }

  private async driverFor(user: AuthUser) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
      select: { id: true },
    });
    if (!driver) throw new NotFoundException();
    return driver;
  }

  /** A repeat of the driver's own answer returns the current snapshot. Any other miss is gone. */
  private async replayOrGone(
    driverId: string,
    offerId: string,
    user: AuthUser,
    status: 'ACCEPTED' | 'DECLINED',
  ) {
    const offer = await this.prisma.bookingOffer.findUnique({
      where: { id: offerId },
      select: { driverId: true, status: true },
    });
    if (offer?.driverId === driverId && offer.status === status) {
      return this.fleet.state(user);
    }
    throw new GoneException('Offer is no longer available');
  }

  private async emitResolved(offerId: string, event: {
    bookingId: string;
    driverId: string;
    branchId: string;
    outcome: 'ACCEPTED' | 'DECLINED';
  }) {
    try {
      await this.events.emitAsync(OFFER_RESOLVED, { offerId, ...event });
    } catch (error) {
      this.logger.warn(
        `Offer ${offerId} was answered before dispatch was told: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }

  private async cancelQuietly(offerId: string) {
    try {
      await this.expiry.cancel(offerId);
    } catch (error) {
      this.logger.warn(
        `Could not remove expiry for ${offerId}: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }

  private async releaseQuietly(branchId: string, driverId: string, bookingId: string) {
    try {
      await this.fleet.releaseOffer({ branchId, driverId, bookingId });
    } catch (error) {
      this.logger.warn(
        `Could not release ${driverId} after a decline: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }
}
