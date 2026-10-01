import type { ConfigService } from '@nestjs/config';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { OfferAckWaiter } from './offer-ack.waiter.js';
import { OfferSocketListener } from './offer-socket.listener.js';

const offerId = '55555555-5555-4555-8555-555555555555';
const bookingId = '22222222-2222-4222-8222-222222222222';
const driverId = '11111111-1111-4111-8111-111111111111';
const branchId = '33333333-3333-4333-8333-333333333333';
const at = '2026-10-01T10:00:00.000Z';

describe('OfferAckWaiter', () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  function waiter(wait = '2000') {
    const sendOffer = vi.fn(async () => undefined);
    const config = { get: (key: string) => (key === 'PUSH_ACK_WAIT_MS' ? wait : undefined) };
    const acks = new OfferAckWaiter(config as ConfigService, { sendOffer } as never);
    const push = {
      type: 'offer' as const,
      offerId,
      expiresAt: at,
    };
    return { acks, sendOffer, push };
  }

  it('sends the push only when the driver does not ack', async () => {
    vi.useFakeTimers();
    const quiet = waiter();
    quiet.acks.arm({ driverId, userId: 'user-1', push: quiet.push });
    await vi.advanceTimersByTimeAsync(1_999);
    expect(quiet.sendOffer).not.toHaveBeenCalled();
    await vi.advanceTimersByTimeAsync(1);
    expect(quiet.sendOffer).toHaveBeenCalledWith('user-1', quiet.push);

    const heard = waiter();
    heard.acks.arm({ driverId, userId: 'user-1', push: heard.push });
    expect(heard.acks.receive(driverId, offerId)).toBe(true);
    await vi.advanceTimersByTimeAsync(2_000);
    expect(heard.sendOffer).not.toHaveBeenCalled();
  });

  it('ignores an ack from another driver and skips the push after the offer ends', async () => {
    vi.useFakeTimers();
    const { acks, sendOffer, push } = waiter('50');
    acks.arm({ driverId, userId: 'user-1', push });
    expect(acks.receive('someone-else', offerId)).toBe(false);
    acks.disarm(offerId);
    await vi.advanceTimersByTimeAsync(50);
    expect(sendOffer).not.toHaveBeenCalled();
  });
});

describe('OfferSocketListener', () => {
  const expiresAt = new Date(at);

  function listener() {
    const drivers = { emitOffer: vi.fn() };
    const dispatch = { emitOfferCreated: vi.fn(), emitOfferResolved: vi.fn() };
    const acks = { arm: vi.fn(), disarm: vi.fn() };
    const prisma = {
      bookingOffer: {
        findUnique: vi.fn(async () => ({
          id: offerId,
          expiresAt,
          distanceToPickupM: 400,
          driver: { userId: 'user-1', firstName: 'Sam', lastName: 'Gill' },
          booking: {
            distanceMeters: 8000,
            quotedFareCents: 2500,
            notes: null,
            passengerName: 'Leila Kaur',
            passenger: { firstName: 'Leila' },
            stops: [
              { type: 'PICKUP', address: 'City Hall', lat: 49.69, lng: -112.84 },
              { type: 'DROPOFF', address: 'Airport', lat: 49.63, lng: -112.8 },
            ],
          },
        })),
      },
    };
    const sockets = new OfferSocketListener(
      prisma as never,
      drivers as never,
      dispatch as never,
      acks as never,
    );
    return { sockets, drivers, dispatch, acks };
  }

  const opened = { offerId, bookingId, driverId, branchId, expiresAt: at };

  it('tells the driver and dispatch, then waits for an ack', async () => {
    const { sockets, drivers, dispatch, acks } = listener();

    await sockets.onOpened(opened);

    expect(drivers.emitOffer).toHaveBeenCalledWith(
      'offer:new',
      driverId,
      expect.objectContaining({
        offerId,
        bookingId,
        passengerFirstName: 'Leila',
        pickup: expect.objectContaining({ address: 'City Hall' }),
      }),
    );
    expect(dispatch.emitOfferCreated).toHaveBeenCalledWith(
      branchId,
      expect.objectContaining({
        offerId,
        bookingId,
        driverId,
        driverName: 'Sam Gill',
        expiresAt: at,
      }),
    );
    expect(acks.arm).toHaveBeenCalledWith({
      driverId,
      userId: 'user-1',
      push: { type: 'offer', offerId, expiresAt: at },
    });
  });

  it('ends an expired or cancelled offer and only tells dispatch when the driver answered', () => {
    const { sockets, drivers, dispatch, acks } = listener();

    sockets.onResolved({ ...opened, outcome: 'EXPIRED' });
    sockets.onResolved({ ...opened, outcome: 'CANCELLED' });
    sockets.onResolved({ ...opened, outcome: 'ACCEPTED' });

    expect(acks.disarm).toHaveBeenCalledTimes(3);
    expect(drivers.emitOffer).toHaveBeenNthCalledWith(1, 'offer:expired', driverId, {
      offerId,
      bookingId,
    });
    expect(drivers.emitOffer).toHaveBeenNthCalledWith(2, 'offer:cancelled', driverId, {
      offerId,
      bookingId,
    });
    expect(drivers.emitOffer).toHaveBeenCalledTimes(2);
    expect(dispatch.emitOfferResolved).toHaveBeenCalledWith(
      branchId,
      expect.objectContaining({ outcome: 'ACCEPTED' }),
    );
  });
});
