import { ConflictException, NotFoundException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { BookingsService } from './bookings.service.js';

const bookingId = '22222222-2222-4222-8222-222222222222';
const driverUser = { userId: 'driver-user', role: 'driver', branchId: 'branch-1' };

function booking(overrides: Record<string, unknown> = {}) {
  return {
    id: bookingId,
    status: 'TRIP_STARTED',
    driverId: 'driver-1',
    branchId: 'branch-1',
    paymentMethod: 'CASH',
    quotedFareCents: 2000,
    quotedTaxCents: 100,
    fixedFareCents: null,
    gstRateBps: 500,
    branch: { commissionBps: 1000 },
    ...overrides,
  };
}

function harness(current = booking()) {
  const tx = {
    booking: { findUnique: vi.fn(async () => current) },
  };
  const prisma = {
    driver: { findUnique: vi.fn(async () => ({ id: 'driver-1' })) },
    $transaction: vi.fn(async (fn: (client: typeof tx) => Promise<unknown>) =>
      fn(tx),
    ),
  };
  const state = {
    transition: vi
      .fn()
      .mockResolvedValueOnce({
        bookingId,
        branchId: 'branch-1',
        from: 'TRIP_STARTED',
        to: 'TRIP_COMPLETED',
        prevDriverId: 'driver-1',
        driverId: 'driver-1',
      })
      .mockResolvedValueOnce({
        bookingId,
        branchId: 'branch-1',
        from: 'TRIP_COMPLETED',
        to: 'PAYMENT_PENDING',
        prevDriverId: 'driver-1',
        driverId: 'driver-1',
      }),
  };
  const events = { emitAsync: vi.fn(async () => []) };
  const config = {
    get: vi.fn((key: string) =>
      key === 'FIXED_FARE_INCLUDES_GST' ? 'false' : undefined,
    ),
  };
  const service = new BookingsService(
    prisma as never,
    state as never,
    { rememberOfferedDriver: vi.fn() } as never,
    config as never,
    events as never,
    { estimate: vi.fn() } as never,
    { acceptQuote: vi.fn(), quotes: vi.fn() } as never,
    { cancel: vi.fn() } as never,
    { enqueueAttempt: vi.fn() } as never,
    { post: vi.fn() } as never,
    { get: vi.fn() } as never,
  );
  return { service, tx, state, events, prisma, config };
}

describe('BookingsService.complete', () => {
  it('finalizes fare, patches settlement fields, and emits both transitions in order', async () => {
    const { service, state, events, tx } = harness();

    await expect(service.complete(driverUser, bookingId)).resolves.toEqual({
      id: bookingId,
      status: 'PAYMENT_PENDING',
      paymentMethod: 'CASH',
      finalSubtotalCents: 2000,
      finalTaxCents: 100,
      finalFareCents: 2100,
      commissionBps: 1000,
      commissionCents: 200,
      driverEarningCents: 1800,
    });

    expect(tx.booking.findUnique).toHaveBeenCalledWith({
      where: { id: bookingId },
      include: { branch: { select: { commissionBps: true } } },
    });
    expect(state.transition).toHaveBeenNthCalledWith(
      1,
      bookingId,
      'TRIP_COMPLETED',
      { type: 'DRIVER', userId: 'driver-user' },
      expect.objectContaining({
        tx,
        patch: expect.objectContaining({
          finalSubtotalCents: 2000,
          finalTaxCents: 100,
          finalFareCents: 2100,
          commissionBps: 1000,
          commissionCents: 200,
          driverEarningCents: 1800,
          completedAt: expect.any(Date),
        }),
      }),
    );
    expect(state.transition).toHaveBeenNthCalledWith(
      2,
      bookingId,
      'PAYMENT_PENDING',
      { type: 'SYSTEM' },
      expect.objectContaining({ tx }),
    );
    expect(events.emitAsync.mock.calls.map((call) => call[1].to)).toEqual([
      'TRIP_COMPLETED',
      'PAYMENT_PENDING',
    ]);
  });

  it('uses a tax-exclusive fixed fare when FIXED_FARE_INCLUDES_GST is false', async () => {
    const { service } = harness(
      booking({ quotedFareCents: 2000, fixedFareCents: 3000 }),
    );

    await expect(service.complete(driverUser, bookingId)).resolves.toMatchObject({
      finalSubtotalCents: 3000,
      finalTaxCents: 150,
      finalFareCents: 3150,
      commissionCents: 300,
      driverEarningCents: 2700,
    });
  });

  it('rejects a stranger driver and a booking that is not on trip', async () => {
    const wrongDriver = harness(booking({ driverId: 'other' }));
    await expect(
      wrongDriver.service.complete(driverUser, bookingId),
    ).rejects.toBeInstanceOf(NotFoundException);

    const wrongStatus = harness(booking({ status: 'DRIVER_ARRIVED' }));
    await expect(
      wrongStatus.service.complete(driverUser, bookingId),
    ).rejects.toBeInstanceOf(ConflictException);
  });
});
