import { Inject, Injectable, Logger } from '@nestjs/common';
import { EventEmitter2, OnEvent } from '@nestjs/event-emitter';
import type { BookingStatus } from '@prisma/client';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import {
  OFFER_EXPIRY_SCHEDULER,
  type OfferExpiryScheduler,
} from '../jobs/offer-expiry.scheduler.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { OFFER_RESOLVED } from './offer-events.js';

type StatusEvent = {
  bookingId: string;
  to: BookingStatus;
};

/**
 * An offer left behind when the booking moves on is cancelled.
 * Passenger or staff cancel during MATCHED arrives here as CANCELLED: the open
 * offer is marked CANCELLED, the driver is released, and offer.resolved tells
 * the driver socket to send offer:cancelled.
 * Accept, decline, and expiry already closed the row, so they find nothing here.
 */
@Injectable()
export class OfferCloseListener {
  private readonly logger = new Logger(OfferCloseListener.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly fleet: FleetStateService,
    private readonly events: EventEmitter2,
    @Inject(OFFER_EXPIRY_SCHEDULER) private readonly expiry: OfferExpiryScheduler,
  ) {}

  @OnEvent('booking.status_changed')
  async onStatus(event: StatusEvent) {
    if (event.to === 'MATCHED') return;
    const open = await this.prisma.bookingOffer.findMany({
      where: { bookingId: event.bookingId, status: 'OFFERED' },
      select: {
        id: true,
        driverId: true,
        bookingId: true,
        booking: { select: { branchId: true } },
      },
    });
    for (const offer of open) {
      try {
        await this.cancel(offer);
      } catch (error) {
        this.logger.warn(
          `Offer ${offer.id} was not cancelled: ${
            error instanceof Error ? error.message : 'unknown error'
          }`,
        );
      }
    }
  }

  private async cancel(offer: {
    id: string;
    driverId: string;
    bookingId: string;
    booking: { branchId: string };
  }) {
    const updated = await this.prisma.bookingOffer.updateMany({
      where: { id: offer.id, status: 'OFFERED' },
      data: { status: 'CANCELLED', respondedAt: new Date() },
    });
    if (updated.count !== 1) return;
    try {
      await this.fleet.releaseOffer({
        branchId: offer.booking.branchId,
        driverId: offer.driverId,
        bookingId: offer.bookingId,
      });
    } catch (error) {
      this.logger.warn(
        `Could not release ${offer.driverId} after cancelling ${offer.id}: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
    try {
      await this.expiry.cancel(offer.id);
    } catch (error) {
      this.logger.warn(
        `Could not remove expiry for ${offer.id}: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
    await this.events.emitAsync(OFFER_RESOLVED, {
      offerId: offer.id,
      bookingId: offer.bookingId,
      driverId: offer.driverId,
      branchId: offer.booking.branchId,
      outcome: 'CANCELLED',
    });
  }
}
