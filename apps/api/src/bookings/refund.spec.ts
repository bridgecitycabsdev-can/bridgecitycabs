import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { BookingsService } from './bookings.service.js';

const bookingId = '22222222-2222-4222-8222-222222222222';
const accountsUser = {
  userId: 'acct-1',
  role: 'accounts_admin',
  branchId: 'branch-1',
};
const dispatcher = {
  userId: 'disp-1',
  role: 'dispatcher',
  branchId: 'branch-1',
};

function harness(bookingOverrides: Record<string, unknown> = {}) {
  const refund = vi.fn(async () => undefined);
  const booking = {
    id: bookingId,
    branchId: 'branch-1',
    paymentMethod: 'CARD',
    paymentStatus: 'PAID',
    ...bookingOverrides,
  };
  const prisma = {
    booking: {
      findFirst: vi.fn(async () => booking),
    },
    payment: {
      findFirst: vi.fn(async () => ({
        id: 'pay-1',
        providerRef: 'pi_1',
        amountCents: 2100,
        status: 'CAPTURED',
      })),
    },
    auditLog: { create: vi.fn(async () => ({ id: 'audit-1' })) },
  };
  const service = new BookingsService(
    prisma as never,
    {} as never,
    {} as never,
    { get: () => undefined } as never,
    { emitAsync: vi.fn(async () => []) } as never,
    {} as never,
    {} as never,
    {} as never,
    {} as never,
    { post: vi.fn() } as never,
    { get: () => ({ refund }) } as never,
    { releaseAuthorized: vi.fn(async () => undefined) } as never,
  { checkCreditLimit: vi.fn(), getAccountReceivableBalance: vi.fn() } as never,
    { releaseIfAny: vi.fn(), redeem: vi.fn() } as never,
  );
  return { service, prisma, refund };
}

describe('BookingsService.refund', () => {
  it('requests a Stripe refund and audits without posting the ledger', async () => {
    const { service, refund, prisma } = harness();

    await expect(
      service.refund(
        bookingId,
        { amountCents: 2100, reason: 'Duplicate' },
        accountsUser,
      ),
    ).resolves.toEqual({
      id: bookingId,
      paymentId: 'pay-1',
      providerRef: 'pi_1',
      amountCents: 2100,
      status: 'REFUND_REQUESTED',
    });

    expect(refund).toHaveBeenCalledWith({
      providerRef: 'pi_1',
      amountCents: 2100,
      idempotencyKey: 'refund:pay-1:2100',
    });
    expect(prisma.auditLog.create).toHaveBeenCalled();
  });

  it('rejects dispatchers, cash bookings, and over-refunds', async () => {
    await expect(
      harness().service.refund(
        bookingId,
        { amountCents: 100, reason: 'x' },
        dispatcher,
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);

    await expect(
      harness({ paymentMethod: 'CASH' }).service.refund(
        bookingId,
        { amountCents: 100, reason: 'x' },
        accountsUser,
      ),
    ).rejects.toBeInstanceOf(ConflictException);

    await expect(
      harness().service.refund(
        bookingId,
        { amountCents: 99999, reason: 'x' },
        accountsUser,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('404s when the booking is outside the user branch', async () => {
    const { service, prisma } = harness();
    prisma.booking.findFirst.mockResolvedValueOnce(null);
    await expect(
      service.refund(
        bookingId,
        { amountCents: 100, reason: 'x' },
        accountsUser,
      ),
    ).rejects.toBeInstanceOf(NotFoundException);
  });
});
