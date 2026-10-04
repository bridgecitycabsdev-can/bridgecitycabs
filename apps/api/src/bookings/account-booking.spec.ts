import { ConflictException, ForbiddenException } from '@nestjs/common';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { ApiCode } from '../common/api-code.js';

const ids = vi.hoisted(() => ({
  newTrackingId: vi.fn(() => 'BC-ACCT0001'),
}));

vi.mock('./tracking-id.js', () => ({
  newTrackingId: ids.newTrackingId,
}));

import { BookingsService } from './bookings.service.js';

const user = {
  userId: 'user-1',
  role: 'branch_admin',
  branchId: 'branch-1',
};

const dto = {
  passengerName: 'Corp Rider',
  passengerPhone: '+14035550100',
  vehicleTypeId: '11111111-1111-4111-8111-111111111111',
  zone: 'INSIDE_TOWN' as const,
  paymentMethod: 'ACCOUNT' as const,
  corporateAccountId: 'ca-1',
  stops: [
    { address: '100 1 Ave S', lat: 49.69, lng: -112.84 },
    { address: '200 5 Ave S', lat: 49.7, lng: -112.84 },
  ],
};

describe('BookingsService ACCOUNT create', () => {
  const saved = {
    id: 'booking-1',
    trackingId: 'BC-ACCT0001',
    status: 'SEARCHING_DRIVER',
    branchId: 'branch-1',
    paymentMethod: 'ACCOUNT',
    corporateAccountId: 'ca-1',
    passengerName: 'Corp Rider',
    scheduledAt: null,
    quotedFareCents: 919,
    vehicleType: { id: dto.vehicleTypeId, name: 'SUV' },
    stops: [{ sequence: 1, address: '100 1 Ave S' }],
  };

  function build(credit = vi.fn(async () => ({ currentCents: 0 }))) {
    const tx = {
      booking: {
        create: vi.fn(async ({ data }) => ({ id: 'booking-1', ...data })),
        findUniqueOrThrow: vi.fn(async () => saved),
      },
      bookingStatusHistory: { create: vi.fn(async () => ({})) },
      auditLog: { create: vi.fn(async () => ({})) },
    };
    const prisma = {
      passenger: { findFirst: vi.fn(async () => null) },
      vehicleType: {
        findUnique: vi.fn(async () => ({
          id: dto.vehicleTypeId,
          active: true,
        })),
      },
      fareRule: {
        findUnique: vi.fn(async () => ({
          active: true,
          baseFareCents: 595,
          perKmCents: 249,
          perMinuteCents: 0,
          minFareCents: 0,
        })),
      },
      branch: {
        findUnique: vi.fn(async () => ({ id: 'branch-1', gstRateBps: 500 })),
      },
      corporateAccount: {
        findFirst: vi.fn(async () => ({
          id: 'ca-1',
          branchId: 'branch-1',
          active: true,
          creditLimitCents: 10_000,
        })),
      },
      corporateAccountContact: {
        findFirst: vi.fn(async () => ({
          id: 'cc-1',
          accountId: 'ca-1',
          active: true,
        })),
      },
      rolePermission: {
        findFirst: vi.fn(async () => ({ roleId: 'r1' })),
      },
      $transaction: vi.fn(async (run: (client: typeof tx) => unknown) =>
        run(tx),
      ),
    };
    const state = {
      transition: vi.fn(async () => ({
        bookingId: 'booking-1',
        from: 'CREATED',
        to: 'SEARCHING_DRIVER',
      })),
    };
    const service = new BookingsService(
      prisma as never,
      state as never,
      {} as never,
      { get: () => undefined } as never,
      { emitAsync: vi.fn(async () => []) } as never,
      { estimate: vi.fn(async () => ({ meters: 1300, seconds: 117 })) } as never,
      { acceptQuote: vi.fn(() => null), quotes: vi.fn() } as never,
      {} as never,
      {} as never,
      { post: vi.fn() } as never,
      { get: vi.fn() } as never,
      { releaseAuthorized: vi.fn() } as never,
      { checkCreditLimit: credit } as never,
      { releaseIfAny: vi.fn(), redeem: vi.fn() } as never,
    );
    return { service, prisma, tx, credit };
  }

  beforeEach(() => {
    ids.newTrackingId.mockReturnValue('BC-ACCT0001');
  });

  it('requires corporateAccountId and checks credit before insert', async () => {
    const { service, credit, tx } = build();
    await service.create(dto, user);
    expect(credit).toHaveBeenCalledWith('ca-1', expect.any(Number));
    expect(tx.booking.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          paymentMethod: 'ACCOUNT',
          corporateAccountId: 'ca-1',
        }),
      }),
    );
  });

  it('rejects a contact that does not belong to the account', async () => {
    const { service, prisma } = build();
    prisma.corporateAccountContact.findFirst.mockResolvedValueOnce(null);
    await expect(
      service.create({ ...dto, corporateContactId: 'cc-other' }, user),
    ).rejects.toThrow(/corporateContactId must belong/);
  });

  it('allows credit override with permission and audits it', async () => {
    const credit = vi.fn(async () => {
      throw new ConflictException({
        code: ApiCode.CREDIT_LIMIT_EXCEEDED,
        currentCents: 9_000,
        limitCents: 10_000,
        requestedCents: 2_000,
      });
    });
    const { service, tx } = build(credit);
    await service.create(
      {
        ...dto,
        overrideCreditLimit: true,
        overrideReason: 'Manager approved standing PO',
      },
      user,
    );
    expect(tx.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        action: 'booking.credit_limit_override',
        after: expect.objectContaining({
          corporateAccountId: 'ca-1',
          reason: 'Manager approved standing PO',
          approvedById: 'user-1',
        }),
      }),
    });
  });

  it('forbids override without the permission', async () => {
    const credit = vi.fn(async () => {
      throw new ConflictException({
        code: ApiCode.CREDIT_LIMIT_EXCEEDED,
        currentCents: 9_000,
        limitCents: 10_000,
        requestedCents: 2_000,
      });
    });
    const { service, prisma } = build(credit);
    prisma.rolePermission.findFirst.mockResolvedValueOnce(null);
    await expect(
      service.create(
        {
          ...dto,
          overrideCreditLimit: true,
          overrideReason: 'please',
        },
        user,
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });
});

describe('BookingsService ACCOUNT complete', () => {
  const bookingId = '22222222-2222-4222-8222-222222222222';
  const driverUser = {
    userId: 'driver-user',
    role: 'driver',
    branchId: 'branch-1',
  };

  it('posts TRIP_ACCOUNT, marks PAID, and closes in one flow', async () => {
    const post = vi.fn(async () => ({ id: 'txn-1' }));
    const tx = {
      booking: {
        findUnique: vi.fn(async () => ({
          id: bookingId,
          status: 'TRIP_STARTED',
          driverId: 'driver-1',
          branchId: 'branch-1',
          paymentMethod: 'ACCOUNT',
          paymentStatus: 'UNPAID',
          corporateAccountId: 'ca-1',
          quotedFareCents: 2000,
          fixedFareCents: null,
          gstRateBps: 500,
          branch: { commissionBps: 1000 },
        })),
        update: vi.fn(async () => ({})),
      },
      payment: { create: vi.fn(async () => ({ id: 'pay-1' })) },
    };
    const state = {
      transition: vi
        .fn()
        .mockResolvedValueOnce({ to: 'TRIP_COMPLETED' })
        .mockResolvedValueOnce({ to: 'PAYMENT_PENDING' })
        .mockResolvedValueOnce({ to: 'PAYMENT_COMPLETED' })
        .mockResolvedValueOnce({ to: 'CLOSED' }),
    };
    const events = { emitAsync: vi.fn(async () => []) };
    const service = new BookingsService(
      {
        driver: { findUnique: vi.fn(async () => ({ id: 'driver-1' })) },
        $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      } as never,
      state as never,
      {} as never,
      { get: () => 'false' } as never,
      events as never,
      {} as never,
      {} as never,
      {} as never,
      {} as never,
      { post } as never,
      { get: vi.fn() } as never,
      { releaseAuthorized: vi.fn() } as never,
      { checkCreditLimit: vi.fn() } as never,
      { releaseIfAny: vi.fn(), redeem: vi.fn() } as never,
    );

    await expect(service.complete(driverUser, bookingId)).resolves.toMatchObject(
      {
        status: 'CLOSED',
        paymentMethod: 'ACCOUNT',
        paymentStatus: 'PAID',
        finalFareCents: 2100,
      },
    );

    expect(post).toHaveBeenCalledWith(
      tx,
      expect.objectContaining({
        kind: 'TRIP_ACCOUNT',
        sourceType: 'BOOKING',
        sourceId: bookingId,
        lines: expect.arrayContaining([
          expect.objectContaining({
            accountKey: 'ACCOUNTS_RECEIVABLE:ca-1',
            type: 'ACCOUNTS_RECEIVABLE',
            amountCents: 2100,
          }),
        ]),
      }),
    );
    expect(tx.booking.update).toHaveBeenCalledWith({
      where: { id: bookingId },
      data: { paymentStatus: 'PAID' },
    });
    expect(state.transition.mock.calls.map((c) => c[1])).toEqual([
      'TRIP_COMPLETED',
      'PAYMENT_PENDING',
      'PAYMENT_COMPLETED',
      'CLOSED',
    ]);
    expect(events.emitAsync).toHaveBeenCalledTimes(4);
  });
});
