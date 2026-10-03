import { Injectable, Logger } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import type { BookingStatus } from '@prisma/client';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { DriverPublisher } from './driver-publisher.js';
import { FleetBroadcaster } from './fleet-broadcaster.js';

type BookingStatusEvent = {
  bookingId: string;
  branchId?: string;
  from: BookingStatus;
  to: BookingStatus;
  prevDriverId?: string | null;
  driverId?: string | null;
};

type BookingCreatedEvent = {
  id: string;
  branchId: string;
  trackingId: string;
  status: string;
  passengerName: string;
  scheduledAt: string | null;
  quotedFareCents: number;
  vehicleType: { id: string; name: string };
  pickupAddress: string;
};

@Injectable()
export class BookingFleetSync {
  private readonly logger = new Logger(BookingFleetSync.name);

  constructor(
    private readonly fleet: FleetStateService,
    private readonly drivers: DriverPublisher,
    private readonly broadcaster: FleetBroadcaster,
  ) {}

  @OnEvent('booking.created')
  onCreated(event: BookingCreatedEvent) {
    try {
      this.broadcaster.emitCreated(event.branchId, event);
    } catch (error) {
      this.logger.error(
        `Booking ${event.id} did not reach dispatch: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }

  @OnEvent('booking.status_changed')
  async onStatus(event: BookingStatusEvent) {
    try {
      const result = await this.fleet.syncFromBooking(event);
      if (!result) return;
      this.broadcaster.emitBooking(result.branchId, {
        bookingId: event.bookingId,
        from: event.from,
        to: event.to,
        prevDriverId: event.prevDriverId ?? null,
        driverId: event.driverId ?? null,
      });
      if (!result.driver) return;
      this.drivers.emitState(result.driver.driverId, result.driver.snapshot);
      this.broadcaster.mark(result.driver.branchId, result.driver.driverId);
    } catch (error) {
      this.logger.error(
        `Booking ${event.bookingId} did not reach the fleet: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }

  @OnEvent('booking.edited')
  async onEdited(event: {
    id: string;
    branchId: string;
    driverId: string | null;
    notesChanged: boolean;
  }) {
    try {
      this.broadcaster.emitEdited(event.branchId, {
        id: event.id,
        branchId: event.branchId,
      });
      if (!event.notesChanged || !event.driverId) return;
      const result = await this.fleet.republishSnapshot(event.driverId);
      if (!result) return;
      this.drivers.emitState(result.driverId, result.snapshot);
    } catch (error) {
      this.logger.error(
        `Booking ${event.id} edit did not reach the driver: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }
}
