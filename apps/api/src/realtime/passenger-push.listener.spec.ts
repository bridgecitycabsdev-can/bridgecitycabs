import { describe, expect, it, vi } from 'vitest';
import { PassengerPushListener } from './passenger-push.listener.js';

const bookingId = '22222222-2222-4222-8222-222222222222';

function listener(connected: boolean, userId: string | null = 'user-1') {
  const prisma = {
    booking: {
      findUnique: vi.fn(async () => ({
        passenger: userId ? { userId } : null,
      })),
    },
  };
  const sockets = { hasConnection: vi.fn(async () => connected) };
  const passengers = { emitBooking: vi.fn(), emitTrip: vi.fn() };
  const push = { sendToUser: vi.fn(async () => undefined) };
  const bookings = {
    broadcastSnapshot: vi.fn(async () => ({ id: bookingId, status: 'DRIVER_ARRIVED' })),
  };
  const alerts = new PassengerPushListener(
    prisma as never,
    sockets as never,
    passengers as never,
    push as never,
    bookings as never,
  );
  return { alerts, sockets, passengers, push, prisma, bookings };
}

describe('PassengerPushListener', () => {
  it('pushes when the passenger app is not connected', async () => {
    const { alerts, push, passengers } = listener(false);

    await alerts.onStatus({ bookingId, to: 'DRIVER_ARRIVED' });

    expect(passengers.emitBooking).not.toHaveBeenCalled();
    expect(push.sendToUser).toHaveBeenCalledWith('user-1', {
      title: 'Driver arrived',
      body: 'Your driver is here',
      data: { bookingId, type: 'driver_arrived' },
      highPriority: true,
      timeSensitive: false,
    });
  });

  it('uses the socket when the passenger is connected', async () => {
    const { alerts, push, passengers } = listener(true);

    await alerts.onStatus({ bookingId, to: 'NO_DRIVER_FOUND' });

    expect(push.sendToUser).not.toHaveBeenCalled();
    expect(passengers.emitBooking).toHaveBeenCalledWith('user-1', {
      id: bookingId,
      status: 'DRIVER_ARRIVED',
    });
  });

  it('pushes no-driver-found only when the passenger is disconnected, with no address or name', async () => {
    const { alerts, push } = listener(false);

    await alerts.onStatus({ bookingId, to: 'NO_DRIVER_FOUND' });

    expect(push.sendToUser).toHaveBeenCalledTimes(1);
    const message = push.sendToUser.mock.calls[0]?.[1] as { title: string; body: string; data: unknown };
    expect(message).toEqual({
      title: 'No driver found',
      body: 'We could not find a driver',
      data: { bookingId, type: 'no_driver_found' },
      highPriority: true,
      timeSensitive: false,
    });
    expect(JSON.stringify(message)).not.toMatch(/address|passengerName|phone|City Hall/i);
  });

  it('stays quiet for other statuses and for bookings with no account', async () => {
    const searching = listener(false);
    await searching.alerts.onStatus({ bookingId, to: 'SEARCHING_DRIVER' });
    expect(searching.push.sendToUser).not.toHaveBeenCalled();
    expect(searching.passengers.emitBooking).not.toHaveBeenCalled();

    const connected = listener(true);
    await connected.alerts.onStatus({ bookingId, to: 'SEARCHING_DRIVER' });
    expect(connected.push.sendToUser).not.toHaveBeenCalled();
    expect(connected.passengers.emitBooking).toHaveBeenCalled();

    const phoneIn = listener(false, null);
    await phoneIn.alerts.onStatus({ bookingId, to: 'DRIVER_ASSIGNED' });
    expect(phoneIn.push.sendToUser).not.toHaveBeenCalled();
    expect(phoneIn.passengers.emitBooking).not.toHaveBeenCalled();
  });
});
