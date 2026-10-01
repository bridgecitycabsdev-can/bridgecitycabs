import { Injectable, Logger } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import {
  SOCKET_EVENTS,
  offerCreatedSchema,
  offerEndedSchema,
  offerNewSchema,
  offerResolvedSchema,
  type OfferCreated,
  type OfferEnded,
  type OfferNew,
} from '@bridgecabs/shared-types';
import { driverOfferSnapshot } from '../fleet/fleet-presence.js';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  OFFER_OPENED,
  OFFER_RESOLVED,
  type OfferOpenedEvent,
  type OfferResolvedEvent,
} from '../dispatch/offer-events.js';
import { OfferAckWaiter } from './offer-ack.waiter.js';
import { DriverPublisher } from './driver-publisher.js';
import { FleetBroadcaster } from './fleet-broadcaster.js';

@Injectable()
export class OfferSocketListener {
  private readonly logger = new Logger(OfferSocketListener.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly drivers: DriverPublisher,
    private readonly dispatch: FleetBroadcaster,
    private readonly acks: OfferAckWaiter,
  ) {}

  @OnEvent(OFFER_OPENED)
  async onOpened(event: OfferOpenedEvent) {
    try {
      const row = await this.prisma.bookingOffer.findUnique({
        where: { id: event.offerId },
        select: {
          id: true,
          expiresAt: true,
          distanceToPickupM: true,
          driver: { select: { userId: true, firstName: true, lastName: true } },
          booking: {
            select: {
              distanceMeters: true,
              quotedFareCents: true,
              notes: true,
              passengerName: true,
              passenger: { select: { firstName: true } },
              stops: {
                orderBy: { sequence: 'asc' },
                select: { type: true, address: true, lat: true, lng: true },
              },
            },
          },
        },
      });
      if (!row) return;

      const created = offerCreatedSchema.parse({
        bookingId: event.bookingId,
        offerId: event.offerId,
        driverId: event.driverId,
        driverName: `${row.driver.firstName} ${row.driver.lastName}`.trim(),
        expiresAt: row.expiresAt.toISOString(),
      } satisfies OfferCreated);
      this.dispatch.emitOfferCreated(event.branchId, created);
      this.acks.arm({
        driverId: event.driverId,
        userId: row.driver.userId,
        push: {
          type: 'offer',
          offerId: event.offerId,
          expiresAt: row.expiresAt.toISOString(),
        },
      });

      const card = driverOfferSnapshot(
        row,
        {
          ...row.booking,
          passengerFirstName: row.booking.passenger?.firstName,
        },
        new Date(),
      );
      if (card) {
        const payload = offerNewSchema.parse({
          offerId: card.id,
          bookingId: event.bookingId,
          expiresAt: card.expiresAt,
          serverNow: card.serverNow,
          pickup: card.pickup,
          dropoff: card.dropoff,
          distanceToPickupM: card.distanceToPickupM,
          tripDistanceM: card.tripDistanceM,
          quotedFareCents: card.quotedFareCents,
          passengerFirstName: card.passengerFirstName,
          notes: card.notes,
        } satisfies OfferNew);
        this.drivers.emitOffer(SOCKET_EVENTS.offerNew, event.driverId, payload);
      }
    } catch (error) {
      this.logger.error(
        `Offer ${event.offerId} did not reach the driver: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }

  @OnEvent(OFFER_RESOLVED)
  onResolved(event: OfferResolvedEvent) {
    this.acks.disarm(event.offerId);
    try {
      const resolved = offerResolvedSchema.parse({
        bookingId: event.bookingId,
        offerId: event.offerId,
        driverId: event.driverId,
        outcome: event.outcome,
      });
      this.dispatch.emitOfferResolved(event.branchId, resolved);
      if (event.outcome !== 'EXPIRED' && event.outcome !== 'CANCELLED') return;
      const ended = offerEndedSchema.parse({
        offerId: event.offerId,
        bookingId: event.bookingId,
      } satisfies OfferEnded);
      const name = event.outcome === 'EXPIRED' ? SOCKET_EVENTS.offerExpired : SOCKET_EVENTS.offerCancelled;
      this.drivers.emitOffer(name, event.driverId, ended);
    } catch (error) {
      this.logger.error(
        `Offer ${event.offerId} resolution did not reach dispatch: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }
}
