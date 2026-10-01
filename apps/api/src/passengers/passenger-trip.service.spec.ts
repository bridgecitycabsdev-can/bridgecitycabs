import { NotFoundException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { PASSENGER_SHARE_LOCATION_STATUSES } from './passenger-booking.view.js';
import { PassengerTripService } from './passenger-trip.service.js';

const user = { userId: 'user-1', role: 'passenger' as const, branchId: null };
const bookingId = '22222222-2222-4222-8222-222222222222';

function harness() {
  const prisma = {
    passenger: { findUnique: vi.fn(async () => ({ id: 'passenger-1' })) },
    booking: {
      findFirst: vi.fn(async (): Promise<{ driverId: string } | null> => null),
    },
  };
  const fleet = { sharedPosition: vi.fn(async () => ({ lat: 49.7, lng: -112.83, heading: 1, ts: 5 })) };
  return { service: new PassengerTripService(prisma as never, fleet as never), prisma, fleet };
}

describe('PassengerTripService', () => {
  it('refuses another passenger booking and never reads that driver', async () => {
    const { service, prisma, fleet } = harness();

    await expect(service.driverLocation(user, bookingId)).rejects.toBeInstanceOf(NotFoundException);

    expect(prisma.booking.findFirst).toHaveBeenCalledWith({
      where: {
        id: bookingId,
        passengerId: 'passenger-1',
        driverId: { not: null },
        status: { in: PASSENGER_SHARE_LOCATION_STATUSES },
      },
      select: { driverId: true },
    });
    expect(fleet.sharedPosition).not.toHaveBeenCalled();
  });
});
