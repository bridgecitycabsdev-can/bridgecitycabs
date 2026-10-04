import 'reflect-metadata';
import {
  ConflictException,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import type { ConfigService } from '@nestjs/config';
import { describe, expect, it, vi } from 'vitest';
import { ApiException } from '../common/api-exception.js';
import { IDEMPOTENT_KEY } from '../idempotency/idempotency.decorator.js';
import { PassengerBookingsController } from './passenger-bookings.controller.js';
import { PassengerBookingsService } from './passenger-bookings.service.js';

const bookingId = '22222222-2222-4222-8222-222222222222';
const vehicleTypeId = '33333333-3333-4333-8333-333333333333';
const user = { userId: 'user-1', role: 'passenger', branchId: 'branch-1' };

const passenger = {
  id: 'passenger-1',
  userId: 'user-1',
  firstName: 'Leila',
  lastName: 'Khan',
  phone: '+14035550100',
  blocked: false,
};

const stops = [
  { address: 'City Hall', lat: 49.69, lng: -112.84 },
  { address: 'Airport', lat: 49.63, lng: -112.8 },
];

const createDto = {
  vehicleTypeId,
  zone: 'INSIDE_TOWN' as const,
  quoteToken: 'signed',
  stops,
};

function bookingRow(overrides: Record<string, unknown> = {}) {
  return {
    id: bookingId,
    trackingId: 'BC-7K3MQ9XT',
    branchId: 'branch-1',
    status: 'SEARCHING_DRIVER',
    scheduledAt: null,
    quotedFareCents: 1500,
    quotedTaxCents: 75,
    notes: null,
    passengerName: 'Leila Khan',
    passengerPhone: '+14035550100',
    driverId: null,
    vehicleType: { id: vehicleTypeId, name: 'Sedan' },
    stops: [
      {
        sequence: 1,
        type: 'PICKUP',
        address: 'City Hall',
        lat: 49.69,
        lng: -112.84,
      },
      {
        sequence: 2,
        type: 'DROPOFF',
        address: 'Airport',
        lat: 49.63,
        lng: -112.8,
      },
    ],
    driver: null,
    vehicle: null,
    ...overrides,
  };
}

function harness() {
  const booking = {
    findFirst: vi.fn(async (): Promise<Record<string, unknown> | null> => null),
    findUnique: vi.fn(),
    findUniqueOrThrow: vi.fn(async () => bookingRow()),
    create: vi.fn(async ({ data }: { data: { id?: string } }) => ({
      id: data.id ?? bookingId,
    })),
  };
  const tx = {
    booking,
    payment: { create: vi.fn(async () => ({ id: 'pay-1' })) },
    bookingStatusHistory: { create: vi.fn(async () => undefined) },
    bookingAssignment: { updateMany: vi.fn(async () => ({ count: 0 })) },
  };
  const prisma = {
    passenger: { findUnique: vi.fn(async () => ({ ...passenger })) },
    passengerPaymentMethod: {
      findFirst: vi.fn(async () => ({
        id: 'ppm-1',
        passengerId: 'passenger-1',
        stripePmId: 'pm_1',
      })),
    },
    stripeCustomer: {
      findUnique: vi.fn(async () => ({
        passengerId: 'passenger-1',
        stripeCustomerId: 'cus_1',
      })),
    },
    vehicleType: {
      findUnique: vi.fn(async () => ({ id: vehicleTypeId, active: true })),
    },
    branch: {
      findUnique: vi.fn(async () => ({ id: 'branch-1', gstRateBps: 500 })),
    },
    booking,
    $transaction: vi.fn(async (fn: (client: typeof tx) => Promise<unknown>) =>
      fn(tx),
    ),
  };
  const paymentProviders = {
    get: vi.fn(() => ({
      authorize: vi.fn(async () => ({
        providerRef: 'pi_1',
        status: 'AUTHORIZED' as const,
      })),
      cancel: vi.fn(async () => undefined),
    })),
  };
  const cardHolds = {
    releaseAuthorized: vi.fn(async () => undefined),
  };
  const state = {
    transition: vi.fn(async (): Promise<Record<string, unknown>> => ({
      bookingId,
      from: 'CREATED',
      to: 'SEARCHING_DRIVER',
    })),
  };
  const fares = {
    quote: vi.fn(),
    acceptQuote: vi.fn(() => ({
      distanceM: 1000,
      durationS: 120,
      subtotalCents: 1500,
      taxCents: 75,
      totalCents: 1575,
    })),
    quotes: vi.fn(async () => ({ distanceM: 900, options: [] })),
  };
  const fleet = {
    clearOfferedDrivers: vi.fn(async () => undefined),
    sharedPosition: vi.fn(async () => ({
      lat: 49.7,
      lng: -112.83,
      heading: 12,
      ts: 10,
    })),
  };
  const events = { emitAsync: vi.fn(async () => []) };
  const distance = {
    estimate: vi.fn(async () => ({ meters: 800, seconds: 90 })),
  };
  const config = {
    get: vi.fn((key: string) =>
      key === 'AUTH_BUFFER_BPS' ? '2000' : undefined,
    ),
  } as unknown as ConfigService;
  const promos = {
    redeem: vi.fn(async () => undefined),
    releaseIfAny: vi.fn(async () => undefined),
  };
  const service = new PassengerBookingsService(
    prisma as never,
    state as never,
    fares as never,
    fleet as never,
    config,
    events as never,
    distance as never,
    paymentProviders as never,
    cardHolds as never,
    promos as never,
  );
  return {
    service,
    prisma,
    tx,
    state,
    fares,
    fleet,
    events,
    distance,
    paymentProviders,
    cardHolds,
  };
}

describe('PassengerBookingsService', () => {
  it('creates an automatic passenger-app booking and opens the search', async () => {
    const { service, tx, state, events, fares, distance } = harness();

    const view = await service.create(createDto, user);

    expect(tx.booking.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          source: 'PASSENGER_APP',
          assignMode: 'AUTO',
          passengerId: 'passenger-1',
          passengerPhone: '+14035550100',
          quotedFareCents: 1500,
          quotedTaxCents: 75,
          gstRateBps: 500,
          distanceMeters: 1000,
        }),
      }),
    );
    expect(fares.acceptQuote).toHaveBeenCalled();
    expect(fares.quote).not.toHaveBeenCalled();
    expect(distance.estimate).not.toHaveBeenCalled();
    expect(tx.bookingStatusHistory.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          actorType: 'PASSENGER',
          actorUserId: 'user-1',
        }),
      }),
    );
    expect(state.transition).toHaveBeenCalledWith(
      bookingId,
      'SEARCHING_DRIVER',
      { type: 'SYSTEM' },
      { tx },
    );
    expect(events.emitAsync).toHaveBeenCalledWith(
      'booking.status_changed',
      expect.objectContaining({ to: 'SEARCHING_DRIVER' }),
    );
    expect(view.status).toBe('SEARCHING_DRIVER');
    expect(view.driver).toBeNull();
    expect(JSON.stringify(view)).not.toMatch(/phone/i);
  });

  it('refuses a blocked passenger and a second active booking', async () => {
    const blocked = harness();
    blocked.prisma.passenger.findUnique.mockResolvedValue({
      ...passenger,
      blocked: true,
    });
    await expect(
      blocked.service.create(createDto, user),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
    expect(blocked.fares.acceptQuote).not.toHaveBeenCalled();

    const busy = harness();
    busy.prisma.booking.findFirst.mockResolvedValue({ id: 'already' });
    await expect(busy.service.create(createDto, user)).rejects.toThrow(
      'You already have an active booking',
    );
    expect(busy.tx.booking.create).not.toHaveBeenCalled();
  });

  it('returns only this passenger booking, and hides the driver until they are assigned', async () => {
    const { service, prisma } = harness();
    prisma.booking.findFirst.mockResolvedValue(
      bookingRow({
        status: 'MATCHED',
        driverId: 'driver-1',
        driver: { firstName: 'Sam', ratingAvg: 4.8 },
      }),
    );

    const matched = await service.get(user, bookingId);
    expect(prisma.booking.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { id: bookingId, passengerId: 'passenger-1' },
      }),
    );
    expect(matched.driver).toBeNull();
    expect(JSON.stringify(matched)).not.toMatch(/phone/i);

    prisma.booking.findFirst.mockResolvedValue(null);
    await expect(service.get(user, bookingId)).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('shows the assigned driver and a straight-line ETA, without a phone number', async () => {
    const { service, prisma, distance } = harness();
    prisma.booking.findFirst.mockResolvedValue(
      bookingRow({
        status: 'DRIVER_ASSIGNED',
        driverId: 'driver-1',
        driver: { firstName: 'Sam', ratingAvg: 4.8 },
        vehicle: {
          plateNumber: 'LTH111',
          unitNumber: '111',
          color: 'White',
          model: { name: 'Camry', make: { name: 'Toyota' } },
        },
      }),
    );

    const view = await service.get(user, bookingId);

    expect(distance.estimate).toHaveBeenCalled();
    expect(view.etaSeconds).toBe(90);
    expect(view.driver).toEqual({
      firstName: 'Sam',
      rating: 4.8,
      vehicle: {
        make: 'Toyota',
        model: 'Camry',
        colour: 'White',
        plate: 'LTH111',
        unitNumber: '111',
      },
    });
    expect(JSON.stringify(view)).not.toMatch(/phone/i);
  });

  it('cancels before the trip starts and refuses once the trip has started', async () => {
    const { service, prisma, state, events, cardHolds } = harness();
    prisma.booking.findFirst.mockResolvedValue({
      id: bookingId,
      status: 'MATCHED',
    });
    state.transition.mockResolvedValue({
      bookingId,
      from: 'MATCHED',
      to: 'CANCELLED',
    });

    await service.cancel(user, bookingId, {});

    expect(state.transition).toHaveBeenCalledWith(
      bookingId,
      'CANCELLED',
      { type: 'PASSENGER', userId: 'user-1' },
      expect.objectContaining({
        patch: expect.objectContaining({
          cancelledBy: 'PASSENGER',
          cancelReason: 'PASSENGER_REQUEST',
        }),
      }),
    );
    expect(events.emitAsync).toHaveBeenCalledWith(
      'booking.status_changed',
      expect.objectContaining({ to: 'CANCELLED' }),
    );
    expect(cardHolds.releaseAuthorized).toHaveBeenCalledWith(bookingId);

    const started = harness();
    started.prisma.booking.findFirst.mockResolvedValue({
      id: bookingId,
      status: 'TRIP_STARTED',
    });
    await expect(
      started.service.cancel(user, bookingId, {}),
    ).rejects.toBeInstanceOf(ConflictException);
    expect(started.state.transition).not.toHaveBeenCalled();
    expect(started.cardHolds.releaseAuthorized).not.toHaveBeenCalled();
  });

  it('retries a search from NO_DRIVER_FOUND and starts the window over', async () => {
    const { service, prisma, fleet, state } = harness();
    prisma.booking.findFirst.mockResolvedValue({
      id: bookingId,
      status: 'NO_DRIVER_FOUND',
    });

    await service.retry(user, bookingId);

    expect(fleet.clearOfferedDrivers).toHaveBeenCalledWith(bookingId);
    expect(state.transition).toHaveBeenCalledWith(
      bookingId,
      'SEARCHING_DRIVER',
      { type: 'PASSENGER', userId: 'user-1' },
      expect.objectContaining({
        patch: { searchStartedAt: expect.any(Date) },
      }),
    );

    const searching = harness();
    searching.prisma.booking.findFirst.mockResolvedValue({
      id: bookingId,
      status: 'SEARCHING_DRIVER',
    });
    await expect(
      searching.service.retry(user, bookingId),
    ).rejects.toBeInstanceOf(ConflictException);
    expect(searching.fleet.clearOfferedDrivers).not.toHaveBeenCalled();
  });

  it('authorizes a card hold before creating the booking and Payment row', async () => {
    const { service, tx, paymentProviders } = harness();
    const authorize = vi.fn(async () => ({
      providerRef: 'pi_auth',
      status: 'AUTHORIZED' as const,
    }));
    paymentProviders.get.mockReturnValue({
      authorize,
      cancel: vi.fn(async () => undefined),
    });

    await service.create(
      {
        ...createDto,
        paymentMethod: 'CARD',
        paymentMethodId: 'ppm-1',
      },
      user,
    );

    // quote total 1575 × 1.20 = 1890
    expect(authorize).toHaveBeenCalledWith(
      expect.objectContaining({
        amountCents: 1890,
        customerId: 'cus_1',
        paymentMethodId: 'pm_1',
      }),
    );
    expect(tx.booking.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          paymentMethod: 'CARD',
          paymentMethodId: 'ppm-1',
          stripePaymentIntentId: 'pi_auth',
          authorizedAmountCents: 1890,
          authBufferBps: 2000,
        }),
      }),
    );
    expect(tx.payment.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          method: 'CARD',
          provider: 'STRIPE',
          purpose: 'TRIP_AUTH_CAPTURE',
          status: 'AUTHORIZED',
          amountCents: 1890,
          providerRef: 'pi_auth',
        }),
      }),
    );
  });

  it('surfaces CARD_REQUIRES_ACTION so the client can prompt 3DS', async () => {
    const action = harness();
    action.paymentProviders.get.mockReturnValue({
      authorize: vi.fn(async () => ({
        providerRef: 'pi_3ds',
        status: 'REQUIRES_ACTION',
      })),
      cancel: vi.fn(async () => undefined),
    });
    await expect(
      action.service.create(
        { ...createDto, paymentMethod: 'CARD', paymentMethodId: 'ppm-1' },
        user,
      ),
    ).rejects.toMatchObject({
      response: { code: 'CARD_REQUIRES_ACTION' },
    });
    expect(action.tx.booking.create).not.toHaveBeenCalled();
    expect(action.tx.payment.create).not.toHaveBeenCalled();
  });

  it('does not create a booking when authorize declines the card', async () => {
    const declined = harness();
    declined.paymentProviders.get.mockReturnValue({
      authorize: vi.fn(async () => ({
        providerRef: 'pi_fail',
        status: 'FAILED',
      })),
      cancel: vi.fn(async () => undefined),
    });
    await expect(
      declined.service.create(
        { ...createDto, paymentMethod: 'CARD', paymentMethodId: 'ppm-1' },
        user,
      ),
    ).rejects.toMatchObject({ response: { code: 'CARD_DECLINED' } });
    expect(declined.tx.booking.create).not.toHaveBeenCalled();
    expect(declined.tx.payment.create).not.toHaveBeenCalled();
  });
});

describe('PassengerBookingsController', () => {
  it('requires an idempotency key on create', () => {
    expect(
      Reflect.getMetadata(
        IDEMPOTENT_KEY,
        PassengerBookingsController.prototype.create,
      ),
    ).toBe(true);
  });
});
