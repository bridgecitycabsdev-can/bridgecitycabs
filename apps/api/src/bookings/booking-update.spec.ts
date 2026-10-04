import { ConflictException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { ApiException } from '../common/api-exception.js';
import { BookingsService } from './bookings.service.js';

const bookingId = '22222222-2222-4222-8222-222222222222';
const user = { userId: 'user-1', role: 'dispatcher', branchId: 'branch-1' };
const driverUser = { userId: 'driver-user', role: 'driver', branchId: 'branch-1' };

function row(overrides: Record<string, unknown> = {}) {
  return {
    id: bookingId,
    version: 2,
    status: 'SEARCHING_DRIVER',
    source: 'DISPATCH',
    branchId: 'branch-1',
    assignMode: 'AUTO',
    passengerName: 'Amira',
    passengerPhone: '+14035550100',
    vehicleTypeId: 'veh-type',
    zone: 'INSIDE_TOWN',
    vanOnly: false,
    ladyDriverOnly: false,
    scheduledAt: null,
    paymentMethod: 'CASH',
    notes: 'Gate code 12',
    fixedFareCents: null,
    distanceMeters: 1000,
    durationSeconds: 120,
    quotedFareCents: 1500,
    quotedTaxCents: 75,
    driverId: 'driver-1',
    createdById: 'user-1',
    driver: { id: 'driver-1', firstName: 'Ada', lastName: 'Khan' },
    vehicle: { id: 'veh-1', plateNumber: 'ABC', unitNumber: '111' },
    assignments: [],
    offers: [],
    history: [],
    passenger: null,
    vehicleType: { id: 'veh-type', name: 'SUV' },
    stops: [
      { sequence: 1, address: 'A', lat: 1, lng: 2, placeId: null },
      { sequence: 2, address: 'B', lat: 3, lng: 4, placeId: null },
    ],
    ...overrides,
  };
}

function harness(current = row()) {
  const tx = {
    booking: {
      findUnique: vi.fn(async () => current),
      updateMany: vi.fn(async () => ({ count: 1 })),
    },
    bookingStop: {
      deleteMany: vi.fn(async () => ({ count: 2 })),
      createMany: vi.fn(async () => ({ count: 2 })),
    },
    bookingAssignment: { updateMany: vi.fn(async () => ({ count: 1 })) },
    auditLog: { create: vi.fn(async () => ({ id: 'audit-1' })) },
  };
  const prisma = {
    booking: {
      findFirst: vi.fn(async () => current),
      findUnique: vi.fn(async () => current),
    },
    driver: { findUnique: vi.fn(async () => ({ id: 'driver-1' })) },
    user: {
      findMany: vi.fn(async () => [{ id: 'user-1', displayName: 'Priya' }]),
    },
    $transaction: vi.fn(async (fn: (client: typeof tx) => Promise<unknown>) => fn(tx)),
  };
  const state = {
    transition: vi.fn(async () => ({
      bookingId,
      branchId: 'branch-1',
      from: 'DRIVER_ASSIGNED',
      to: 'SEARCHING_DRIVER',
      prevDriverId: 'driver-1',
      driverId: null,
    })),
  };
  const events = { emitAsync: vi.fn(async () => []) };
  const quotes = vi.fn(async () => ({
    distanceM: 8100,
    durationS: 1020,
    source: 'ROUTES',
    zone: 'OUT_OF_TOWN',
    options: [
      {
        vehicleTypeId: 'sedan',
        name: 'Sedan',
        subtotalCents: 2510,
        taxCents: 126,
        totalCents: 2636,
      },
    ],
  }));
  const dispatch = {
    enqueueAttempt: vi.fn(async () => undefined),
    removeAttempts: vi.fn(async () => undefined),
  };
  const fleet = {
    clearOfferedDrivers: vi.fn(async () => undefined),
    rememberOfferedDriver: vi.fn(async () => undefined),
  };
  const service = new BookingsService(
    prisma as never,
    state as never,
    fleet as never,
    { get: () => undefined } as never,
    events as never,
    { estimate: vi.fn() } as never,
    { quotes } as never,
    { cancel: vi.fn() } as never,
    dispatch as never,
    { post: vi.fn() } as never,
    { get: vi.fn() } as never,
    { releaseAuthorized: vi.fn(async () => undefined) } as never,
  { checkCreditLimit: vi.fn(), getAccountReceivableBalance: vi.fn() } as never,
  );
  return { service, prisma, tx, state, events, quotes, dispatch, fleet };
}

describe('booking edits', () => {
  it('rejects a stale version', async () => {
    const { service, tx } = harness();
    await expect(service.update(bookingId, { version: 1, notes: 'later' }, user)).rejects.toBeInstanceOf(
      ApiException,
    );
    expect(tx.booking.updateMany).not.toHaveBeenCalled();
  });

  it('writes an audit row and tells the driver when notes change', async () => {
    const { service, tx, events } = harness();
    const view = await service.update(bookingId, { version: 2, notes: 'new gate' }, user);

    expect(tx.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        action: 'booking.updated',
        entity: 'booking',
        before: { notes: 'Gate code 12' },
        after: { notes: 'new gate' },
      }),
    });
    expect(events.emitAsync).toHaveBeenCalledWith(
      'booking.edited',
      expect.objectContaining({ id: bookingId, notesChanged: true, driverId: 'driver-1' }),
    );
    expect(view.driverName).toBe('Ada Khan');
    expect(view.driverUnit).toBe('111');
    expect(view.createdBy).toBe('Priya');
    expect(view.editableFields).toContain('notes');
  });

  it('caps a fixed fare and records that it was set', async () => {
    const { service, tx } = harness();
    await expect(
      service.update(bookingId, { version: 2, fixedFareCents: 60_000 }, user),
    ).rejects.toBeInstanceOf(ApiException);

    await service.update(bookingId, { version: 2, fixedFareCents: 2000 }, user);
    expect(tx.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({ action: 'booking.fixed_fare_set' }),
    });
  });

  it('refuses passenger changes while an offer is open', async () => {
    const { service } = harness(row({ status: 'MATCHED' }));
    await expect(
      service.update(bookingId, { version: 2, passengerName: 'Someone' }, user),
    ).rejects.toThrow(ConflictException);
  });

  it('re-quotes when the zone changes', async () => {
    const { service, quotes, tx } = harness();
    await service.update(bookingId, { version: 2, zone: 'OUT_OF_TOWN', vehicleTypeId: 'sedan' }, user);
    expect(quotes).toHaveBeenCalledOnce();
    expect(tx.booking.updateMany).toHaveBeenCalledWith({
      where: { id: bookingId, version: 2 },
      data: expect.objectContaining({
        zone: 'OUT_OF_TOWN',
        quotedFareCents: 2510,
        quotedTaxCents: 126,
        distanceMeters: 8100,
      }),
    });
  });
});

describe('driver release', () => {
  it('ends the assignment as DRIVER_CANCELLED and returns the job to search', async () => {
    const current = row({ status: 'DRIVER_ARRIVING' });
    const { service, tx, state, events, fleet } = harness(current);

    await expect(
      service.release(driverUser, bookingId, { reason: 'Passenger not there' }),
    ).resolves.toEqual({ id: bookingId, status: 'SEARCHING_DRIVER' });

    expect(tx.bookingAssignment.updateMany).toHaveBeenCalledWith({
      where: { bookingId, endedAt: null },
      data: expect.objectContaining({ endReason: 'DRIVER_CANCELLED' }),
    });
    expect(state.transition).toHaveBeenCalledWith(
      bookingId,
      'SEARCHING_DRIVER',
      { type: 'DRIVER', userId: 'driver-user' },
      expect.objectContaining({ reason: 'Passenger not there' }),
    );
    expect(fleet.rememberOfferedDriver).toHaveBeenCalledWith(bookingId, 'driver-1');
    expect(events.emitAsync).toHaveBeenCalledWith(
      'booking.status_changed',
      expect.objectContaining({ to: 'SEARCHING_DRIVER' }),
    );
  });
});

describe('retry search', () => {
  it('clears offered drivers and re-enqueues auto dispatch', async () => {
    const current = row({ status: 'NO_DRIVER_FOUND', assignMode: 'AUTO', version: 5 });
    const { service, fleet, dispatch, state, prisma } = harness(current);
    prisma.booking.findUnique = vi.fn(async () => ({
      version: 6,
      status: 'SEARCHING_DRIVER',
      assignMode: 'AUTO',
    }));

    await service.retrySearch(bookingId, user);

    expect(fleet.clearOfferedDrivers).toHaveBeenCalledWith(bookingId);
    expect(state.transition).toHaveBeenCalledWith(
      bookingId,
      'SEARCHING_DRIVER',
      { type: 'STAFF', userId: 'user-1' },
      expect.objectContaining({
        reason: 'Staff retried',
        patch: expect.objectContaining({ searchStartedAt: expect.any(Date) }),
      }),
    );
    expect(dispatch.enqueueAttempt).toHaveBeenCalledWith(bookingId, 6);
  });
});
