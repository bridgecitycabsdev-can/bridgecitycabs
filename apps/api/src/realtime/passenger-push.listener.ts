import { Injectable, Logger } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import type { BookingStatus } from '@prisma/client';
import type { PassengerTripType } from '@bridgecabs/shared-types';
import { PassengerBookingsService } from '../passengers/passenger-bookings.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { PushService } from '../push/push.service.js';
import { PassengerPublisher } from './passenger-publisher.js';
import { SocketLimits } from './socket-limits.js';

const TRIP_PUSH: Partial<
  Record<BookingStatus, { type: PassengerTripType; title: string; body: string }>
> = {
  DRIVER_ASSIGNED: {
    type: 'driver_assigned',
    title: 'Driver assigned',
    body: 'A driver is on the way',
  },
  DRIVER_ARRIVED: {
    type: 'driver_arrived',
    title: 'Driver arrived',
    body: 'Your driver is here',
  },
  NO_DRIVER_FOUND: {
    type: 'no_driver_found',
    title: 'No driver found',
    body: 'We could not find a driver',
  },
};

@Injectable()
export class PassengerPushListener {
  private readonly logger = new Logger(PassengerPushListener.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly sockets: SocketLimits,
    private readonly passengers: PassengerPublisher,
    private readonly push: PushService,
    private readonly bookings: PassengerBookingsService,
  ) {}

  @OnEvent('booking.status_changed')
  async onStatus(event: { bookingId: string; to: BookingStatus }) {
    try {
      const booking = await this.prisma.booking.findUnique({
        where: { id: event.bookingId },
        select: { passenger: { select: { userId: true } } },
      });
      const userId = booking?.passenger?.userId;
      if (!userId) return;
      if (await this.sockets.hasConnection(userId)) {
        const snapshot = await this.bookings.broadcastSnapshot(event.bookingId);
        if (snapshot) this.passengers.emitBooking(userId, snapshot);
        return;
      }
      const copy = TRIP_PUSH[event.to];
      if (!copy) return;
      const trip = { bookingId: event.bookingId, type: copy.type };
      await this.push.sendToUser(userId, {
        title: copy.title,
        body: copy.body,
        data: trip,
        highPriority: true,
        timeSensitive: false,
      });
    } catch (error) {
      this.logger.warn(
        `Passenger was not told about ${event.bookingId}: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }
}
