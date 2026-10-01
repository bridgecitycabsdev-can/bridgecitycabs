import { describe, expect, it, vi } from 'vitest';
import { OfferCloseListener } from './offer-close.listener.js';
import { OfferSocketListener } from '../realtime/offer-socket.listener.js';

describe('OfferCloseListener', () => {
  const offerId = '55555555-5555-4555-8555-555555555555';
  const bookingId = '22222222-2222-4222-8222-222222222222';
  const driverId = '11111111-1111-4111-8111-111111111111';
  const branchId = '33333333-3333-4333-8333-333333333333';

  function listener() {
    const offer = {
      id: offerId,
      driverId,
      bookingId,
      booking: { branchId },
    };
    const prisma = {
      bookingOffer: {
        findMany: vi.fn(async () => [offer]),
        updateMany: vi.fn(async () => ({ count: 1 })),
      },
    };
    const fleet = { releaseOffer: vi.fn(async () => true) };
    const events = { emitAsync: vi.fn(async () => []) };
    const expiry = { cancel: vi.fn(async () => undefined) };
    const close = new OfferCloseListener(
      prisma as never,
      fleet as never,
      events as never,
      expiry as never,
    );
    return { close, prisma, fleet, events, expiry };
  }

  it('leaves the live offer alone when the booking is matched', async () => {
    const { close, prisma } = listener();

    await close.onStatus({ bookingId, to: 'MATCHED' });

    expect(prisma.bookingOffer.findMany).not.toHaveBeenCalled();
  });

  it('cancels an offer the booking left behind', async () => {
    const { close, fleet, expiry, events } = listener();

    await close.onStatus({ bookingId, to: 'CANCELLED' });

    expect(fleet.releaseOffer).toHaveBeenCalledWith({
      branchId,
      driverId,
      bookingId,
    });
    expect(expiry.cancel).toHaveBeenCalledWith(offerId);
    expect(events.emitAsync).toHaveBeenCalledWith('offer.resolved', {
      offerId,
      bookingId,
      driverId,
      branchId,
      outcome: 'CANCELLED',
    });
  });

  it('frees the driver and sends offer:cancelled when a passenger cancels', async () => {
    const { close, fleet, events } = listener();
    const drivers = { emitOffer: vi.fn() };
    const sockets = new OfferSocketListener(
      {} as never,
      drivers as never,
      { emitOfferCreated: vi.fn(), emitOfferResolved: vi.fn() } as never,
      { arm: vi.fn(), disarm: vi.fn() } as never,
    );

    await close.onStatus({ bookingId, to: 'CANCELLED' });
    const resolved = events.emitAsync.mock.calls.find((call) => call[0] === 'offer.resolved')?.[1];
    sockets.onResolved(resolved as never);

    expect(fleet.releaseOffer).toHaveBeenCalledWith({
      branchId,
      driverId,
      bookingId,
    });
    expect(drivers.emitOffer).toHaveBeenCalledWith('offer:cancelled', driverId, {
      offerId,
      bookingId,
    });
  });
});
