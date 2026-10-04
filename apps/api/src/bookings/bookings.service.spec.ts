import { Prisma } from '@prisma/client';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { ApiException } from '../common/api-exception.js';

const ids = vi.hoisted(() => ({
  newTrackingId: vi.fn(),
}));

vi.mock('./tracking-id.js', () => ({
  newTrackingId: ids.newTrackingId,
}));

import { BookingsService } from './bookings.service.js';

const user = {
  userId: 'user-1',
  role: 'dispatcher',
  branchId: 'branch-1',
};

const dto = {
  passengerName: 'Walk-up Rider',
  passengerPhone: '+14035550100',
  vehicleTypeId: '11111111-1111-4111-8111-111111111111',
  zone: 'INSIDE_TOWN' as const,
  stops: [
    { address: '100 1 Ave S', lat: 49.69, lng: -112.84 },
    { address: '200 5 Ave S', lat: 49.7, lng: -112.84 },
  ],
};

describe('BookingsService tracking id', () => {
  const saved = {
    id: 'booking-1',
    trackingId: 'BC-UNIQUE01',
    status: 'SEARCHING_DRIVER' as const,
    branchId: 'branch-1',
    passengerName: 'Walk-up Rider',
    scheduledAt: null,
    quotedFareCents: 919,
    vehicleType: { id: dto.vehicleTypeId, name: 'SUV' },
    stops: [{ sequence: 1, address: '100 1 Ave S' }],
  };

  function build() {
    const tx = {
      booking: {
        create: vi.fn(),
        findUniqueOrThrow: vi.fn(async () => saved),
      },
      bookingStatusHistory: {
        create: vi.fn(async () => ({})),
      },
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
      $transaction: vi.fn(
        async (run: (client: typeof tx) => Promise<unknown>) => run(tx),
      ),
    };
    const state = {
      transition: vi.fn(async () => ({
        bookingId: 'booking-1',
        from: 'CREATED',
        to: 'SEARCHING_DRIVER',
      })),
    };
    const events = { emit: vi.fn(), emitAsync: vi.fn(async () => []) };
    const estimate = vi.fn(async () => ({ meters: 1300, seconds: 117 }));
    const acceptQuote = vi.fn(
      (): {
        distanceM: number;
        durationS: number;
        subtotalCents: number;
        taxCents: number;
        totalCents: number;
      } | null => null,
    );
    const quotes = vi.fn(async () => ({
      distanceM: 8100,
      durationS: 1020,
      source: 'ROUTES',
      zone: 'INSIDE_TOWN',
      options: [],
    }));
    const service = new BookingsService(
      prisma as never,
      state as never,
      { assertAvailableForAssign: vi.fn() } as never,
      { get: () => undefined } as never,
      events as never,
      { estimate } as never,
      { acceptQuote, quotes } as never,
      { cancel: async () => undefined } as never,
      { enqueueAttempt: async () => undefined } as never,
      { post: vi.fn() } as never,
      { get: vi.fn() } as never,
      { releaseAuthorized: vi.fn(async () => undefined) } as never,
    { checkCreditLimit: vi.fn(), getAccountReceivableBalance: vi.fn() } as never,
    );
    return {
      service,
      tx,
      state,
      events,
      prisma,
      estimate,
      acceptQuote,
      quotes,
    };
  }

  let ctx: ReturnType<typeof build>;

  beforeEach(() => {
    ids.newTrackingId.mockReset();
    ctx = build();
  });

  it('retries a forced tracking id collision and stores one booking', async () => {
    ids.newTrackingId
      .mockReturnValueOnce('BC-COLLIDE1')
      .mockReturnValueOnce('BC-UNIQUE01');
    ctx.tx.booking.create
      .mockRejectedValueOnce(unique('trackingId'))
      .mockResolvedValueOnce({ id: 'booking-1' });

    const booking = await ctx.service.create(dto, user);

    expect(booking).toBe(saved);
    expect(ctx.events.emitAsync).toHaveBeenCalledWith('booking.created', {
      id: 'booking-1',
      branchId: 'branch-1',
      trackingId: 'BC-UNIQUE01',
      status: 'SEARCHING_DRIVER',
      passengerName: 'Walk-up Rider',
      scheduledAt: null,
      quotedFareCents: 919,
      vehicleType: { id: dto.vehicleTypeId, name: 'SUV' },
      pickupAddress: '100 1 Ave S',
    });
    expect(ctx.events.emitAsync).toHaveBeenCalledWith(
      'booking.status_changed',
      expect.objectContaining({
        bookingId: 'booking-1',
        to: 'SEARCHING_DRIVER',
      }),
    );
    expect(ids.newTrackingId).toHaveBeenCalledTimes(2);
    expect(ctx.tx.booking.create).toHaveBeenCalledTimes(2);
    expect(ctx.state.transition).toHaveBeenCalledTimes(1);
  });

  it('recomputes a dispatch booking that has no quote token', async () => {
    ids.newTrackingId.mockReturnValue('BC-UNIQUE01');
    ctx.tx.booking.create.mockResolvedValue({ id: 'booking-1' });

    await ctx.service.create(dto, user);

    expect(ctx.estimate).toHaveBeenCalledOnce();
    expect(ctx.acceptQuote).not.toHaveBeenCalled();
  });

  it('charges the signed quote and does not measure the route again', async () => {
    ids.newTrackingId.mockReturnValue('BC-UNIQUE01');
    ctx.tx.booking.create.mockResolvedValue({ id: 'booking-1' });
    ctx.acceptQuote.mockReturnValue({
      distanceM: 8100,
      durationS: 1020,
      subtotalCents: 2510,
      taxCents: 126,
      totalCents: 2636,
    });

    await ctx.service.create({ ...dto, quoteToken: 'signed' }, user);

    expect(ctx.estimate).not.toHaveBeenCalled();
    expect(ctx.prisma.fareRule.findUnique).not.toHaveBeenCalled();
    expect(ctx.tx.booking.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          distanceMeters: 8100,
          durationSeconds: 1020,
          quotedFareCents: 2510,
          quotedTaxCents: 126,
          gstRateBps: 500,
        }),
      }),
    );
  });

  it('returns a fresh quote when the token is expired or mismatched', async () => {
    ctx.acceptQuote.mockReturnValue(null);

    await expect(
      ctx.service.create({ ...dto, quoteToken: 'expired' }, user),
    ).rejects.toBeInstanceOf(ApiException);
    await expect(
      ctx.service.create({ ...dto, quoteToken: 'expired' }, user),
    ).rejects.toMatchObject({
      status: 409,
      response: {
        code: 'QUOTE_EXPIRED',
        quote: expect.objectContaining({ distanceM: 8100 }),
      },
    });
    expect(ctx.tx.booking.create).not.toHaveBeenCalled();
  });

  it('does not retry a unique conflict that is not the tracking id', async () => {
    ids.newTrackingId.mockReturnValue('BC-UNIQUE01');
    ctx.tx.booking.create.mockRejectedValueOnce(unique('phone'));

    await expect(ctx.service.create(dto, user)).rejects.toMatchObject({
      code: 'P2002',
    });
    expect(ctx.tx.booking.create).toHaveBeenCalledTimes(1);
  });
});

function unique(field: string) {
  return new Prisma.PrismaClientKnownRequestError('Unique constraint failed', {
    code: 'P2002',
    clientVersion: '6.19.3',
    meta: { target: [field] },
  });
}
