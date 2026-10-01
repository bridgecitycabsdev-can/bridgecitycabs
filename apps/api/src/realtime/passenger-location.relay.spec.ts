import { describe, expect, it, vi } from 'vitest';
import { PASSENGER_SHARE_LOCATION_STATUSES } from '../passengers/passenger-booking.view.js';
import { PassengerLocationRelay } from './passenger-location.relay.js';

const bookingId = '22222222-2222-4222-8222-222222222222';

function harness() {
  const prisma = {
    booking: {
      findFirst: vi.fn(
        async (): Promise<{ id: string; passenger: { userId: string } } | null> => ({
          id: bookingId,
          passenger: { userId: 'user-1' },
        }),
      ),
    },
  };
  const fleet = {
    sharedPosition: vi.fn(async () => ({
      lat: 49.7,
      lng: -112.83,
      heading: 90,
      ts: 1_700_000_000_000,
    })),
  };
  const passengers = { emitLocation: vi.fn() };
  const config = { get: vi.fn(() => '3000') };
  const relay = new PassengerLocationRelay(
    prisma as never,
    fleet as never,
    passengers as never,
    config as never,
  );
  return { relay, prisma, fleet, passengers };
}

describe('PassengerLocationRelay', () => {
  it('sends the point only for that driver booking, once per interval', async () => {
    const now = vi.spyOn(Date, 'now');
    now.mockReturnValue(10_000);
    const { relay, prisma, passengers } = harness();

    await relay.onPing('driver-1');
    await relay.onPing('driver-1');

    expect(prisma.booking.findFirst).toHaveBeenCalledTimes(1);
    expect(prisma.booking.findFirst).toHaveBeenCalledWith({
      where: {
        driverId: 'driver-1',
        status: { in: PASSENGER_SHARE_LOCATION_STATUSES },
      },
      select: {
        id: true,
        passenger: { select: { userId: true } },
      },
    });
    expect(passengers.emitLocation).toHaveBeenCalledTimes(1);
    expect(passengers.emitLocation).toHaveBeenCalledWith('user-1', {
      bookingId,
      lat: 49.7,
      lng: -112.83,
      heading: 90,
      ts: 1_700_000_000_000,
    });

    now.mockReturnValue(13_000);
    await relay.onPing('driver-1');
    expect(passengers.emitLocation).toHaveBeenCalledTimes(2);
    now.mockRestore();
  });

  it('does not send one driver point to another passenger', async () => {
    const { relay, prisma, passengers } = harness();
    prisma.booking.findFirst.mockImplementation(async (query: { where: { driverId: string } }) => {
      if (query.where.driverId === 'driver-1') {
        return { id: bookingId, passenger: { userId: 'user-1' } };
      }
      if (query.where.driverId === 'driver-2') {
        return { id: 'booking-2', passenger: { userId: 'user-2' } };
      }
      return null;
    });

    await relay.onPing('driver-1');
    await relay.onPing('driver-2');
    await relay.onPing('driver-3');

    expect(passengers.emitLocation.mock.calls.map((call) => call[0])).toEqual(['user-1', 'user-2']);
    expect(passengers.emitLocation).toHaveBeenNthCalledWith(
      1,
      'user-1',
      expect.objectContaining({ bookingId }),
    );
    expect(passengers.emitLocation).toHaveBeenNthCalledWith(
      2,
      'user-2',
      expect.objectContaining({ bookingId: 'booking-2' }),
    );
  });

  it('does not emit when the driver has no passenger trip in that window', async () => {
    const { relay, prisma, passengers } = harness();
    prisma.booking.findFirst.mockResolvedValue(null);

    await relay.onPing('driver-1');

    expect(passengers.emitLocation).not.toHaveBeenCalled();
  });
});
