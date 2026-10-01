import { ConflictException, Inject, Injectable, Logger, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EventEmitter2 } from '@nestjs/event-emitter';
import type { BookingStatus } from '@prisma/client';
import { BookingStateService } from '../bookings/booking-state.service.js';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { DISPATCH_QUEUE, type DispatchQueue, leadMinutes } from '../jobs/dispatch-queue.js';
import { DISPATCH_RETRY_MS } from '../jobs/job-names.js';
import { MatchingService, offersInThisSearch } from './matching.service.js';
import { OFFER_RESOLVED } from './offer-events.js';

type StatusEvent = {
  bookingId: string;
  to: BookingStatus;
};

type CreatedEvent = {
  id: string;
  status: string;
  scheduledAt: string | null;
};

@Injectable()
export class DispatchJobsService {
  private readonly logger = new Logger(DispatchJobsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly state: BookingStateService,
    private readonly fleet: FleetStateService,
    private readonly matching: MatchingService,
    private readonly events: EventEmitter2,
    @Inject(DISPATCH_QUEUE) private readonly queue: DispatchQueue,
  ) {}

  async onStatus(event: StatusEvent) {
    if (event.to !== 'SEARCHING_DRIVER') return;
    const booking = await this.prisma.booking.findUnique({
      where: { id: event.bookingId },
      select: { assignMode: true, status: true, version: true },
    });
    if (!booking || booking.assignMode !== 'AUTO' || booking.status !== 'SEARCHING_DRIVER') {
      return;
    }
    await this.queue.enqueueAttempt(event.bookingId, booking.version);
  }

  async onCreated(event: CreatedEvent) {
    if (event.status !== 'SCHEDULED' || !event.scheduledAt) return;
    const scheduledAt = new Date(event.scheduledAt);
    if (Number.isNaN(scheduledAt.getTime())) return;
    await this.queue.scheduleRelease(event.id, scheduledAt);
  }

  async runAttempt(bookingId: string, n: number) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { status: true, assignMode: true, searchStartedAt: true },
    });
    if (!booking || booking.assignMode !== 'AUTO' || booking.status !== 'SEARCHING_DRIVER') {
      return;
    }
    if (await this.searchFinished(bookingId, booking.searchStartedAt)) {
      await this.giveUp(bookingId);
      return;
    }
    const offer = await this.matching.offerNext(bookingId);
    if (offer) return;
    const fresh = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { status: true, searchStartedAt: true },
    });
    if (!fresh || fresh.status !== 'SEARCHING_DRIVER') return;
    if (await this.searchFinished(bookingId, fresh.searchStartedAt)) {
      await this.giveUp(bookingId);
      return;
    }
    await this.queue.enqueueAttempt(bookingId, n + 1, DISPATCH_RETRY_MS);
  }

  /**
   * Expire the offer only if it is still unanswered, then search again.
   * A lost update means the driver already accepted, declined, or cancelled.
   */
  async expireOffer(offerId: string) {
    const outcome = await this.prisma.$transaction(async (tx) => {
      const expired = await tx.bookingOffer.updateMany({
        where: { id: offerId, status: 'OFFERED' },
        data: { status: 'EXPIRED', respondedAt: new Date() },
      });
      if (expired.count !== 1) return null;
      const offer = await tx.bookingOffer.findUnique({
        where: { id: offerId },
        select: {
          bookingId: true,
          driverId: true,
          booking: { select: { branchId: true, status: true, driverId: true } },
        },
      });
      if (!offer) return null;
      const stillMatched =
        offer.booking.status === 'MATCHED' && offer.booking.driverId === offer.driverId;
      const transition = stillMatched
        ? await this.state.transition(
            offer.bookingId,
            'SEARCHING_DRIVER',
            { type: 'SYSTEM' },
            { tx, reason: 'Offer expired' },
          )
        : null;
      return { offer, transition };
    });
    if (!outcome) return;

    await this.releaseQuietly(
      outcome.offer.booking.branchId,
      outcome.offer.driverId,
      outcome.offer.bookingId,
    );
    await this.emitResolved(offerId, outcome.offer);
    if (!outcome.transition) return;
    try {
      await this.events.emitAsync('booking.status_changed', outcome.transition);
    } catch (error) {
      this.logger.warn(
        `Offer ${offerId} expired before dispatch was told: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
    const booking = await this.prisma.booking.findUnique({
      where: { id: outcome.transition.bookingId },
      select: { version: true, status: true, assignMode: true },
    });
    if (!booking || booking.status !== 'SEARCHING_DRIVER' || booking.assignMode !== 'AUTO') {
      return;
    }
    await this.queue.enqueueAttempt(outcome.transition.bookingId, booking.version);
  }

  async releaseScheduled(bookingId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { status: true, scheduledAt: true },
    });
    if (!booking?.scheduledAt || !this.isDue(booking.scheduledAt)) return;
    if (booking.status === 'SCHEDULED') {
      await this.state.transition(bookingId, 'CREATED', { type: 'SYSTEM' });
    }
    const current = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { status: true },
    });
    if (current?.status !== 'CREATED') return;
    await this.state.transition(bookingId, 'SEARCHING_DRIVER', { type: 'SYSTEM' });
  }

  async sweepScheduled() {
    const dueAt = new Date(Date.now() + leadMinutes(this.config) * 60_000);
    const due = await this.prisma.booking.findMany({
      where: {
        scheduledAt: { lte: dueAt },
        OR: [{ status: 'SCHEDULED' }, { status: 'CREATED' }],
      },
      select: { id: true },
    });
    for (const booking of due) {
      try {
        await this.releaseScheduled(booking.id);
      } catch (error) {
        if (error instanceof ConflictException || error instanceof NotFoundException) continue;
        this.logger.warn(
          `Scheduled release skipped ${booking.id}: ${
            error instanceof Error ? error.message : 'unknown error'
          }`,
        );
      }
    }
  }

  private async emitResolved(
    offerId: string,
    offer: { bookingId: string; driverId: string; booking: { branchId: string } },
  ) {
    try {
      await this.events.emitAsync(OFFER_RESOLVED, {
        offerId,
        bookingId: offer.bookingId,
        driverId: offer.driverId,
        branchId: offer.booking.branchId,
        outcome: 'EXPIRED',
      });
    } catch (error) {
      this.logger.warn(
        `Offer ${offerId} expired before dispatch was told: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }

  private async searchFinished(bookingId: string, searchStartedAt: Date | null) {
    const offers = await this.prisma.bookingOffer.count({
      where: offersInThisSearch(bookingId, searchStartedAt),
    });
    if (offers >= this.readInt('MAX_OFFERS_PER_BOOKING', 6)) return true;
    if (!searchStartedAt) return false;
    const elapsed = (Date.now() - searchStartedAt.getTime()) / 1000;
    return elapsed >= this.readInt('SEARCH_WINDOW_SECONDS', 120);
  }

  private async giveUp(bookingId: string) {
    try {
      await this.state.transition(bookingId, 'NO_DRIVER_FOUND', { type: 'SYSTEM' }, {
        reason: 'No driver found',
      });
    } catch (error) {
      if (error instanceof ConflictException || error instanceof NotFoundException) return;
      throw error;
    }
  }

  private isDue(scheduledAt: Date) {
    const leadMs = leadMinutes(this.config) * 60_000;
    return scheduledAt.getTime() - leadMs <= Date.now() + 2_000;
  }

  private async releaseQuietly(branchId: string, driverId: string, bookingId: string) {
    try {
      await this.fleet.releaseOffer({ branchId, driverId, bookingId });
    } catch (error) {
      this.logger.warn(
        `Could not release ${driverId} after offer expiry: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
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
