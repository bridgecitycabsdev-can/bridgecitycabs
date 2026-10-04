import {
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { PassengerPaymentMethodsService } from './passenger-payment-methods.service.js';

describe('PassengerPaymentMethodsService', () => {
  const passenger = { id: 'pass-1', userId: 'user-1' };
  const user = { userId: 'user-1', roles: ['passenger'] } as never;

  let prisma: {
    passenger: { findUnique: ReturnType<typeof vi.fn> };
    stripeCustomer: {
      findUnique: ReturnType<typeof vi.fn>;
      findUniqueOrThrow: ReturnType<typeof vi.fn>;
      create: ReturnType<typeof vi.fn>;
    };
    passengerPaymentMethod: {
      findMany: ReturnType<typeof vi.fn>;
      findFirst: ReturnType<typeof vi.fn>;
      updateMany: ReturnType<typeof vi.fn>;
      update: ReturnType<typeof vi.fn>;
      delete: ReturnType<typeof vi.fn>;
    };
    $transaction: ReturnType<typeof vi.fn>;
  };
  let stripe: {
    customers: {
      create: ReturnType<typeof vi.fn>;
      update: ReturnType<typeof vi.fn>;
    };
    setupIntents: { create: ReturnType<typeof vi.fn> };
    paymentMethods: { detach: ReturnType<typeof vi.fn> };
  };
  let service: PassengerPaymentMethodsService;

  beforeEach(() => {
    prisma = {
      passenger: { findUnique: vi.fn(async () => passenger) },
      stripeCustomer: {
        findUnique: vi.fn(async () => null),
        findUniqueOrThrow: vi.fn(),
        create: vi.fn(async ({ data }) => ({
          id: 'sc-1',
          passengerId: data.passengerId,
          stripeCustomerId: data.stripeCustomerId,
        })),
      },
      passengerPaymentMethod: {
        findMany: vi.fn(async () => []),
        findFirst: vi.fn(),
        updateMany: vi.fn(),
        update: vi.fn(),
        delete: vi.fn(),
      },
      $transaction: vi.fn(async (fn: (tx: typeof prisma) => unknown) =>
        fn(prisma),
      ),
    };
    stripe = {
      customers: {
        create: vi.fn(async () => ({ id: 'cus_1' })),
        update: vi.fn(async () => ({ id: 'cus_1' })),
      },
      setupIntents: {
        create: vi.fn(async () => ({
          id: 'seti_1',
          client_secret: 'seti_1_secret',
        })),
      },
      paymentMethods: { detach: vi.fn(async () => ({ id: 'pm_1' })) },
    };
    service = new PassengerPaymentMethodsService(
      prisma as never,
      stripe as never,
    );
  });

  it('creates a StripeCustomer and returns a SetupIntent client secret', async () => {
    await expect(service.createSetupIntent(user)).resolves.toEqual({
      clientSecret: 'seti_1_secret',
      customerId: 'cus_1',
    });
    expect(stripe.customers.create).toHaveBeenCalledWith({
      metadata: { passengerId: 'pass-1' },
    });
    expect(prisma.stripeCustomer.create).toHaveBeenCalledWith({
      data: { passengerId: 'pass-1', stripeCustomerId: 'cus_1' },
    });
    expect(stripe.setupIntents.create).toHaveBeenCalledWith({
      customer: 'cus_1',
      usage: 'off_session',
    });
  });

  it('reuses an existing StripeCustomer', async () => {
    prisma.stripeCustomer.findUnique.mockResolvedValueOnce({
      id: 'sc-1',
      passengerId: 'pass-1',
      stripeCustomerId: 'cus_existing',
    });

    await expect(service.createSetupIntent(user)).resolves.toEqual({
      clientSecret: 'seti_1_secret',
      customerId: 'cus_existing',
    });
    expect(stripe.customers.create).not.toHaveBeenCalled();
    expect(stripe.setupIntents.create).toHaveBeenCalledWith({
      customer: 'cus_existing',
      usage: 'off_session',
    });
  });

  it('lists saved cards without Stripe ids', async () => {
    prisma.passengerPaymentMethod.findMany.mockResolvedValueOnce([
      {
        id: 'ppm-1',
        brand: 'visa',
        last4: '4242',
        expMonth: 12,
        expYear: 2030,
        isDefault: true,
        createdAt: new Date('2026-10-04T00:00:00.000Z'),
        stripePmId: 'pm_secret',
      },
    ]);

    await expect(service.list(user)).resolves.toEqual([
      {
        id: 'ppm-1',
        brand: 'visa',
        last4: '4242',
        expMonth: 12,
        expYear: 2030,
        isDefault: true,
        createdAt: '2026-10-04T00:00:00.000Z',
      },
    ]);
  });

  it('sets default and updates Stripe customer invoice settings', async () => {
    prisma.passengerPaymentMethod.findFirst.mockResolvedValueOnce({
      id: 'ppm-2',
      passengerId: 'pass-1',
      stripePmId: 'pm_2',
      brand: 'mastercard',
      last4: '4444',
      expMonth: 1,
      expYear: 2028,
      isDefault: false,
      createdAt: new Date('2026-10-04T00:00:00.000Z'),
    });
    prisma.stripeCustomer.findUnique.mockResolvedValueOnce({
      stripeCustomerId: 'cus_1',
    });

    await expect(service.setDefault(user, 'ppm-2')).resolves.toMatchObject({
      id: 'ppm-2',
      isDefault: true,
    });
    expect(prisma.passengerPaymentMethod.updateMany).toHaveBeenCalled();
    expect(prisma.passengerPaymentMethod.update).toHaveBeenCalledWith({
      where: { id: 'ppm-2' },
      data: { isDefault: true },
    });
    expect(stripe.customers.update).toHaveBeenCalledWith('cus_1', {
      invoice_settings: { default_payment_method: 'pm_2' },
    });
  });

  it('detaches from Stripe and deletes the row', async () => {
    prisma.passengerPaymentMethod.findFirst.mockResolvedValueOnce({
      id: 'ppm-1',
      passengerId: 'pass-1',
      stripePmId: 'pm_1',
      isDefault: false,
    });

    await expect(service.remove(user, 'ppm-1')).resolves.toEqual({ ok: true });
    expect(stripe.paymentMethods.detach).toHaveBeenCalledWith('pm_1');
    expect(prisma.passengerPaymentMethod.delete).toHaveBeenCalledWith({
      where: { id: 'ppm-1' },
    });
  });

  it('throws when Stripe is not configured', async () => {
    const bare = new PassengerPaymentMethodsService(prisma as never, null);
    await expect(bare.createSetupIntent(user)).rejects.toBeInstanceOf(
      ServiceUnavailableException,
    );
  });

  it('throws NotFound when the passenger has no account', async () => {
    prisma.passenger.findUnique.mockResolvedValueOnce(null);
    await expect(service.list(user)).rejects.toBeInstanceOf(NotFoundException);
  });
});
