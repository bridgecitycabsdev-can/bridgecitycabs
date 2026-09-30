import { Injectable, NotFoundException } from '@nestjs/common';
import { LIVE_BOOKING_STATUSES } from '../bookings/booking-transitions.js';
import type { AuthUser } from '../common/auth-user.js';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class PassengerTripService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly fleet: FleetStateService,
  ) {}

  async driverLocation(user: AuthUser, bookingId: string) {
    const passenger = await this.prisma.passenger.findUnique({
      where: { userId: user.userId },
      select: { id: true },
    });
    if (!passenger) throw new NotFoundException();
    const booking = await this.prisma.booking.findFirst({
      where: {
        id: bookingId,
        passengerId: passenger.id,
        driverId: { not: null },
        status: { in: [...LIVE_BOOKING_STATUSES] },
      },
      select: { driverId: true },
    });
    if (!booking?.driverId) throw new NotFoundException();
    const position = await this.fleet.sharedPosition(booking.driverId);
    if (!position) throw new NotFoundException();
    return position;
  }
}
