import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PASSENGER_SHARE_LOCATION_STATUSES } from '../passengers/passenger-booking.view.js';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { PassengerPublisher } from './passenger-publisher.js';

const DEFAULT_INTERVAL_MS = 3000;

/**
 * Pushes the assigned driver's point to that booking's passenger.
 * There is no client subscribe. A driver id from anyone else is never accepted.
 */
@Injectable()
export class PassengerLocationRelay {
  private readonly logger = new Logger(PassengerLocationRelay.name);
  private readonly lastSent = new Map<string, number>();

  constructor(
    private readonly prisma: PrismaService,
    private readonly fleet: FleetStateService,
    private readonly passengers: PassengerPublisher,
    private readonly config: ConfigService,
  ) {}

  async onPing(driverId: string) {
    const now = Date.now();
    const previous = this.lastSent.get(driverId) ?? 0;
    if (now - previous < this.intervalMs()) return;
    this.lastSent.set(driverId, now);

    try {
      const booking = await this.prisma.booking.findFirst({
        where: {
          driverId,
          status: { in: PASSENGER_SHARE_LOCATION_STATUSES },
        },
        select: {
          id: true,
          passenger: { select: { userId: true } },
        },
      });
      const userId = booking?.passenger?.userId;
      if (!booking || !userId) return;
      const position = await this.fleet.sharedPosition(driverId);
      if (!position) {
        this.lastSent.delete(driverId);
        return;
      }
      this.passengers.emitLocation(userId, {
        bookingId: booking.id,
        lat: position.lat,
        lng: position.lng,
        heading: position.heading,
        ts: position.ts,
      });
    } catch (error) {
      this.lastSent.delete(driverId);
      this.logger.warn(
        `Passenger location was not sent for ${driverId}: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }

  private intervalMs() {
    const raw = this.config.get<string | number>('PASSENGER_LOCATION_INTERVAL_MS');
    if (raw === undefined || raw === '') return DEFAULT_INTERVAL_MS;
    const value = typeof raw === 'number' ? raw : Number(raw);
    if (!Number.isFinite(value) || value < 0) return DEFAULT_INTERVAL_MS;
    return Math.floor(value);
  }
}
