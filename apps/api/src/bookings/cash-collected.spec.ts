import {
  BadRequestException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { BookingsService } from './bookings.service.js';

const bookingId = '22222222-2222-4222-8222-222222222222';
const driverUser = { userId: 'driver-user', role: 'driver', branchId: 'branch-1' };
const staffUser = {
  userId: 'staff-1',
  role: 'branch_admin',
  branchId: 'branch-1',
};

function booking(overrides: Record<string, unknown> = {}) {
  return {
    id: bookingId,
    status: 'PAYMENT_PENDING',
    paymentStatus: 'UNPAID',
    paymentMethod: 'CASH',
    driverId: 'driver-1',
    branchId: 'branch-1',
    gstRateBps: 500,
    commissionBps: 1000,
    finalSubtotalCents: 2000,
    finalTaxCents: 100,
    finalFareCents: 2100,
    commissionCents: 200,
    driverEarningCents: 1800,
    ...overrides,
  };
}

function harness(current = booking()) {
  const payment = {
    id: 'pay-1',
    status: 'CAPTURED',
    amountCents: 2100,
    capturedAt: new Date('2026-10-03T12:00:00.000Z'),
  };
  const tx = {
    $queryRaw: vi.fn(async () => [{ '?column?': 1 }]),
    booking: {
      findUnique: vi.fn(async () => current),
      findUniqueOrThrow: vi.fn(async () => ({ ...current, status: 'CLOSED', paymentStatus: 'PAID' })),
      findFirst: vi.fn(async () => current),
      update: vi.fn(async () => current),
      updateMany: vi.fn(async () => ({ count: 1 })),
    },
    payment: {
      findFirst: vi.fn(async () =>
        current.status === 'CLOSED' ? payment : null,
      ),
      create: vi.fn(async () => payment),
    },
    auditLog: { create: vi.fn(async () => ({ id: 'audit-1' })) },
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
        to: 'PAYMENT_COMPLETED',
      })
      .mockResolvedValueOnce({
        bookingId,
        to: 'CLOSED',
      }),
  };
  const events = { emitAsync: vi.fn(async () => []) };
  const ledger = { post: vi.fn(async () => ({ id: 'txn-1' })) };
  const paymentProviders = {
    get: vi.fn(() => ({
      name: 'CASH',
      authorize: vi.fn(async () => ({
        providerRef: 'cash_b1',
        status: 'CAPTURED' as const,
      })),
    })),
  };
  const fleet = { republishSnapshot: vi.fn(async () => null) };
  const service = new BookingsService(
    prisma as never,
    state as never,
    fleet as never,
    {
      get: (key: string) =>
        key === 'FIXED_FARE_MAX_CENTS' ? '50000' : undefined,
    } as never,
    events as never,
    {} as never,
    {} as never,
    {} as never,
    {} as never,
    ledger as never,
    paymentProviders as never,
    { releaseAuthorized: vi.fn(async () => undefined) } as never,
  { checkCreditLimit: vi.fn(), getAccountReceivableBalance: vi.fn() } as never,
    { releaseIfAny: vi.fn(), redeem: vi.fn() } as never,
  );
  return {
    service,
    tx,
    state,
    events,
    ledger,
    paymentProviders,
    prisma,
    payment,
    fleet,
  };
}

describe('BookingsService.collectCashAsDriver', () => {
  it('captures cash, posts the ledger, and closes the booking', async () => {
    const { service, tx, state, events, ledger } = harness();

    await expect(
      service.collectCashAsDriver(driverUser, bookingId),
    ).resolves.toMatchObject({
      id: bookingId,
      status: 'CLOSED',
      paymentStatus: 'PAID',
      payment: { id: 'pay-1', status: 'CAPTURED', amountCents: 2100 },
    });

    expect(tx.payment.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        method: 'CASH',
        provider: 'CASH',
        status: 'CAPTURED',
        amountCents: 2100,
        idempotencyKey: `cash:${bookingId}`,
      }),
    });
    expect(ledger.post).toHaveBeenCalledWith(
      tx,
      expect.objectContaining({
        kind: 'TRIP_CASH',
        sourceType: 'BOOKING',
        sourceId: bookingId,
      }),
    );
    expect(tx.booking.update).toHaveBeenCalledWith({
      where: { id: bookingId },
      data: { paymentStatus: 'PAID' },
    });
    expect(state.transition.mock.calls.map((call) => call[1])).toEqual([
      'PAYMENT_COMPLETED',
      'CLOSED',
    ]);
    expect(events.emitAsync.mock.calls.map((call) => call[1].to)).toEqual([
      'PAYMENT_COMPLETED',
      'CLOSED',
    ]);
  });

  it('returns the prior result when already CLOSED with a captured payment', async () => {
    const closed = booking({ status: 'CLOSED', paymentStatus: 'PAID' });
    const { service, tx, state, ledger } = harness(closed);

    await expect(
      service.collectCashAsDriver(driverUser, bookingId),
    ).resolves.toMatchObject({
      status: 'CLOSED',
      paymentStatus: 'PAID',
      payment: { id: 'pay-1' },
    });
    expect(tx.payment.create).not.toHaveBeenCalled();
    expect(ledger.post).not.toHaveBeenCalled();
    expect(state.transition).not.toHaveBeenCalled();
  });

  it('rejects non-cash and wrong-status bookings', async () => {
    await expect(
      harness(booking({ paymentMethod: 'CARD' })).service.collectCashAsDriver(
        driverUser,
        bookingId,
      ),
    ).rejects.toBeInstanceOf(ConflictException);

    await expect(
      harness(booking({ status: 'TRIP_STARTED' })).service.collectCashAsDriver(
        driverUser,
        bookingId,
      ),
    ).rejects.toBeInstanceOf(ConflictException);

    await expect(
      harness(booking({ driverId: 'other' })).service.collectCashAsDriver(
        driverUser,
        bookingId,
      ),
    ).rejects.toBeInstanceOf(NotFoundException);
  });
});

describe('BookingsService.collectCashAsStaff', () => {
  it('writes an audit row for the staff actor', async () => {
    const { service, tx } = harness();
    await service.collectCashAsStaff(staffUser, bookingId);
    expect(tx.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        action: 'booking.cash_collected',
        actorUserId: 'staff-1',
        actorType: 'STAFF',
      }),
    });
  });
});

describe('BookingsService.adjustFare', () => {
  it('recomputes tax and commission while payment is pending', async () => {
    const { service, tx, fleet } = harness();
    await expect(
      service.adjustFare(staffUser, bookingId, {
        subtotalCents: 3000,
        reason: 'Wrong drop-off',
      }),
    ).resolves.toMatchObject({
      finalSubtotalCents: 3000,
      finalTaxCents: 150,
      finalFareCents: 3150,
      commissionCents: 300,
      driverEarningCents: 2700,
    });
    expect(tx.booking.updateMany).toHaveBeenCalledWith({
      where: { id: bookingId, status: 'PAYMENT_PENDING' },
      data: expect.objectContaining({
        finalSubtotalCents: 3000,
        finalTaxCents: 150,
        finalFareCents: 3150,
      }),
    });
    expect(tx.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        action: 'booking.fare_adjusted',
        after: expect.objectContaining({ reason: 'Wrong drop-off' }),
      }),
    });
    expect(fleet.republishSnapshot).toHaveBeenCalledWith('driver-1');
  });

  it('refuses adjust-fare after payment and above the fixed-fare cap', async () => {
    await expect(
      harness(
        booking({ status: 'CLOSED', paymentStatus: 'PAID' }),
      ).service.adjustFare(staffUser, bookingId, {
        subtotalCents: 3000,
        reason: 'Too late',
      }),
    ).rejects.toBeInstanceOf(ConflictException);

    await expect(
      harness().service.adjustFare(staffUser, bookingId, {
        subtotalCents: 50_001,
        reason: 'Over cap',
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});

describe('BookingsService.collectCash amount source', () => {
  it('always posts the booking finalFareCents (client amount is never read)', async () => {
    const { service, tx } = harness(
      booking({ finalFareCents: 2636, finalSubtotalCents: 2510, finalTaxCents: 126 }),
    );
    await service.collectCashAsDriver(driverUser, bookingId);
    expect(tx.payment.create).toHaveBeenCalledWith({
      data: expect.objectContaining({ amountCents: 2636 }),
    });
  });
});
