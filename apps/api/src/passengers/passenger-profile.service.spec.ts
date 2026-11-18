import { ConflictException, NotFoundException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { PassengerProfileService } from './passenger-profile.service.js';

const user = { userId: 'user-1', role: 'passenger', branchId: null };

const passenger = {
  id: 'passenger-1',
  userId: 'user-1',
  firstName: 'Leila',
  lastName: 'Khan',
  phone: '+14035550199',
  email: 'leila@example.com',
  blocked: false,
  ratingAvg: 4.8,
  createdAt: new Date('2024-03-01T00:00:00.000Z'),
};

function service(overrides: {
  passenger?: typeof passenger | null;
  openTrip?: { id: string } | null;
} = {}) {
  const found = overrides.passenger === undefined ? passenger : overrides.passenger;
  const prisma = {
    passenger: {
      findUnique: vi.fn(async () => found),
      update: vi.fn(async () => passenger),
    },
    booking: {
      count: vi.fn(async () => 3),
      findFirst: vi.fn(async () => overrides.openTrip ?? null),
    },
    passengerPaymentMethod: {
      findFirst: vi.fn(async () => ({ brand: 'visa', last4: '4242' })),
    },
    user: { update: vi.fn(async () => ({})) },
    refreshToken: { updateMany: vi.fn(async () => ({ count: 1 })) },
    $transaction: vi.fn(async (arg: unknown) => {
      if (typeof arg === 'function') return arg(prisma);
      return Promise.all(arg as Promise<unknown>[]);
    }),
  };
  const auth = {
    requestOtp: vi.fn(async () => ({})),
    confirmOtp: vi.fn(async () => undefined),
  };
  return {
    profile: new PassengerProfileService(prisma as never, auth as never),
    prisma,
    auth,
  };
}

describe('PassengerProfileService', () => {
  it('returns the signed-in passenger', async () => {
    const { profile } = service();
    await expect(profile.get(user)).resolves.toMatchObject({
      id: 'passenger-1',
      fullName: 'Leila Khan',
      phone: '+14035550199',
      totalRides: 3,
      defaultPaymentMethod: 'visa •••• 4242',
      memberSince: '2024',
    });
  });

  it('hides a blocked passenger', async () => {
    const { profile } = service({ passenger: null });
    await expect(profile.get(user)).rejects.toBeInstanceOf(NotFoundException);
  });

  it('refuses deletion while a trip is open', async () => {
    const { profile, auth } = service({ openTrip: { id: 'booking-1' } });
    await expect(
      profile.delete(user, { reason: 'Prices', otp: '000000' }),
    ).rejects.toBeInstanceOf(ConflictException);
    expect(auth.confirmOtp).not.toHaveBeenCalled();
  });

  it('confirms the code, then closes the account', async () => {
    const { profile, auth, prisma } = service();
    await expect(
      profile.delete(user, { reason: 'Prices', feedback: 'Too high', otp: '000000' }),
    ).resolves.toEqual({ deleted: true });
    expect(auth.confirmOtp).toHaveBeenCalledWith('+14035550199', '000000');
    expect(prisma.user.update).toHaveBeenCalledWith({
      where: { id: 'user-1' },
      data: { isActive: false },
    });
  });
});
