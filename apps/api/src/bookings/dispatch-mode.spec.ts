import { ConflictException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { BookingsService } from './bookings.service.js';

const user = { userId: 'user-1', role: 'dispatcher', branchId: 'branch-1' };
const bookingId = '22222222-2222-4222-8222-222222222222';
const driverId = '11111111-1111-4111-8111-111111111111';
const offerId = '55555555-5555-4555-8555-555555555555';

function harness(status = 'SEARCHING_DRIVER', assignMode = 'AUTO') {
  const booking = {
    id: bookingId,
    branchId: 'branch-1',
    status,
    assignMode,
    version: 3,
    source: 'DISPATCH',
    createdById: null,
    driver: null,
    vehicle: null,
    stops: [],
    assignments: [],
    offers: [],
    vanOnly: false,
    ladyDriverOnly: false,
  };
  const tx = {
    booking: {
      findFirst: vi.fn(async () => ({ ...booking })),
      findUnique: vi.fn(async () => ({
        version: 4,
        status: 'SEARCHING_DRIVER',
        assignMode: 'AUTO',
      })),
      update: vi.fn(async () => ({})),
    },
    bookingOffer: {
      findMany: vi.fn(async () => [] as { id: string; driverId: string }[]),
      updateMany: vi.fn(async () => ({ count: 1 })),
    },
    bookingAssignment: {
      findFirst: vi.fn(async () => null),
      update: vi.fn(async () => ({})),
      updateMany: vi.fn(async () => ({ count: 0 })),
      create: vi.fn(async () => ({})),
    },
    driver: {
      findUnique: vi.fn(async () => ({
        id: driverId,
        branchId: 'branch-1',
        status: 'APPROVED',
        ladyDriverEligible: true,
        assignments: [
          {
            vehicleId: 'veh-1',
            vehicle: { active: true, vehicleType: { name: 'Sedan' } },
          },
        ],
      })),
    },
  };
  const prisma = {
    booking: tx.booking,
    user: { findMany: vi.fn(async () => []) },
    $transaction: vi.fn(async (fn: (client: typeof tx) => Promise<unknown>) => fn(tx)),
  };
  const state = {
    transition: vi.fn(async (_id: string, to: string) => ({
      bookingId,
      from: status,
      to,
    })),
  };
  const fleet = {
    assertAvailableForAssign: vi.fn(async () => undefined),
    releaseOffer: vi.fn(async () => true),
  };
  const events = { emitAsync: vi.fn(async (..._args: unknown[]) => undefined) };
  const expiry = { cancel: vi.fn(async () => undefined) };
  const dispatch = {
    enqueueAttempt: vi.fn(async () => undefined),
    removeAttempts: vi.fn(async () => undefined),
  };
  const service = new BookingsService(
    prisma as never,
    state as never,
    fleet as never,
    { get: () => undefined } as never,
    events as never,
    { estimate: async () => ({ meters: 1, seconds: 1 }) } as never,
    {} as never,
    expiry as never,
    dispatch as never,
  );
  return { service, tx, state, fleet, events, expiry, dispatch, booking };
}

describe('manual assign with an open offer', () => {
  it('cancels the offer, then assigns', async () => {
    const { service, tx, state, fleet, events, expiry } = harness('MATCHED');
    tx.bookingOffer.findMany.mockResolvedValue([{ id: offerId, driverId: 'offered-driver' }]);

    await service.assign(bookingId, { driverId }, user);

    expect(tx.bookingOffer.updateMany).toHaveBeenCalledWith({
      where: { id: offerId, status: 'OFFERED' },
      data: { status: 'CANCELLED', respondedAt: expect.any(Date) },
    });
    expect(state.transition).toHaveBeenNthCalledWith(
      1,
      bookingId,
      'SEARCHING_DRIVER',
      { type: 'SYSTEM' },
      expect.objectContaining({ reason: 'Offer cancelled' }),
    );
    expect(state.transition).toHaveBeenNthCalledWith(
      2,
      bookingId,
      'DRIVER_ASSIGNED',
      { type: 'STAFF', userId: 'user-1' },
      expect.objectContaining({
        patch: expect.objectContaining({ driverId }),
      }),
    );
    expect(fleet.assertAvailableForAssign).toHaveBeenCalledWith(driverId, bookingId);
    expect(fleet.releaseOffer).toHaveBeenCalledWith({
      branchId: 'branch-1',
      driverId: 'offered-driver',
      bookingId,
    });
    expect(expiry.cancel).toHaveBeenCalledWith(offerId);
    expect(events.emitAsync.mock.calls.map((call) => call[0])).toEqual([
      'offer.resolved',
      'booking.status_changed',
      'booking.status_changed',
    ]);
    expect(events.emitAsync).toHaveBeenCalledWith(
      'offer.resolved',
      expect.objectContaining({ offerId, outcome: 'CANCELLED' }),
    );
  });

  it('assigns a searching booking without touching an offer', async () => {
    const { service, tx, events } = harness('SEARCHING_DRIVER');

    await service.assign(bookingId, { driverId }, user);

    expect(tx.bookingOffer.updateMany).not.toHaveBeenCalled();
    expect(events.emitAsync.mock.calls.map((call) => call[0])).toEqual(['booking.status_changed']);
  });
});

describe('dispatch mode', () => {
  it('stops an open auto offer and leaves the booking searching on manual', async () => {
    const { service, tx, state, events, dispatch } = harness('MATCHED');
    tx.bookingOffer.findMany.mockResolvedValue([{ id: offerId, driverId: 'offered-driver' }]);

    await service.setDispatchMode(bookingId, { mode: 'MANUAL' }, user);

    expect(tx.booking.update).toHaveBeenCalledWith({
      where: { id: bookingId },
      data: { assignMode: 'MANUAL' },
    });
    expect(state.transition).toHaveBeenCalledWith(
      bookingId,
      'SEARCHING_DRIVER',
      { type: 'SYSTEM' },
      expect.objectContaining({ reason: 'Dispatch set to manual' }),
    );
    expect(events.emitAsync).toHaveBeenCalledWith(
      'offer.resolved',
      expect.objectContaining({ outcome: 'CANCELLED' }),
    );
    expect(dispatch.enqueueAttempt).not.toHaveBeenCalled();
    expect(dispatch.removeAttempts).toHaveBeenCalledWith(bookingId);
  });

  it('switches a searching booking to manual without a new status', async () => {
    const { service, tx, state, dispatch } = harness('SEARCHING_DRIVER');

    await service.setDispatchMode(bookingId, { mode: 'MANUAL' }, user);

    expect(state.transition).not.toHaveBeenCalled();
    expect(tx.booking.update).toHaveBeenCalledWith({
      where: { id: bookingId },
      data: { assignMode: 'MANUAL' },
    });
    expect(dispatch.enqueueAttempt).not.toHaveBeenCalled();
    expect(dispatch.removeAttempts).toHaveBeenCalledWith(bookingId);
  });

  it('resumes auto search when the booking is already searching', async () => {
    const { service, dispatch, tx } = harness('SEARCHING_DRIVER', 'MANUAL');

    await service.setDispatchMode(bookingId, { mode: 'AUTO' }, user);

    expect(tx.booking.update).toHaveBeenCalledWith({
      where: { id: bookingId },
      data: { assignMode: 'AUTO' },
    });
    expect(dispatch.enqueueAttempt).toHaveBeenCalledWith(bookingId, 4);
    expect(dispatch.removeAttempts).not.toHaveBeenCalled();
  });

  it('refuses a mode change after the trip has started', async () => {
    const { service, tx } = harness('TRIP_STARTED');

    await expect(
      service.setDispatchMode(bookingId, { mode: 'MANUAL' }, user),
    ).rejects.toBeInstanceOf(ConflictException);
    expect(tx.booking.update).not.toHaveBeenCalled();
  });
});

describe('cancel during MATCHED', () => {
  it('emits booking.status_changed so the offer listener can cancel and notify', async () => {
    const { service, state, events } = harness('MATCHED');

    await service.cancel(bookingId, { reason: 'PASSENGER_REQUEST' }, user);

    expect(state.transition).toHaveBeenCalledWith(
      bookingId,
      'CANCELLED',
      { type: 'STAFF', userId: 'user-1' },
      expect.objectContaining({ tx: expect.anything() }),
    );
    expect(events.emitAsync).toHaveBeenCalledWith(
      'booking.status_changed',
      expect.objectContaining({ to: 'CANCELLED' }),
    );
  });
});
