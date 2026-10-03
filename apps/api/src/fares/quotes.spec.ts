import { BadRequestException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { FaresService } from './fares.service.js';
import { stopsHash, verifyQuote } from './quote-token.js';

const suv = {
  vehicleTypeId: 'suv-id',
  vehicleType: { id: 'suv-id', name: 'SUV', active: true },
  baseFareCents: 595,
  perKmCents: 249,
  perMinuteCents: 0,
  minFareCents: 0,
  active: true,
};
const sedan = {
  ...suv,
  vehicleTypeId: 'sedan-id',
  vehicleType: { id: 'sedan-id', name: 'Sedan', active: true },
};

const inside = [
  { lat: 0, lng: 0 },
  { lat: 0.01, lng: 0 },
];

function harness(branch?: {
  centerLat: number | null;
  centerLng: number | null;
}) {
  const routed = vi.fn(async () => ({
    meters: 8100,
    seconds: 1020,
    source: 'ROUTES' as const,
  }));
  const straight = vi.fn();
  const prisma = {
    branch: {
      findUnique: vi.fn(async () => ({
        id: 'branch-1',
        gstRateBps: 500,
        centerLat: 0,
        centerLng: 0,
        townRadiusKm: 15,
        ...branch,
      })),
    },
    fareRule: { findMany: vi.fn(async () => [sedan, suv]) },
  };
  const config = {
    get: (key: string) => {
      if (key === 'QUOTE_SECRET') return 'secret';
      if (key === 'QUOTE_TTL_SECONDS') return 600;
      return undefined;
    },
  };
  const fares = new FaresService(
    prisma as never,
    { estimate: straight } as never,
    { estimate: routed } as never,
    config as never,
  );
  return { fares, prisma, routed, straight };
}

const dispatcher = {
  userId: 'user-1',
  role: 'dispatcher',
  branchId: 'branch-1',
};
const passenger = { userId: 'user-2', role: 'passenger', branchId: 'branch-1' };

describe('FaresService quotes', () => {
  it('measures the route once and signs one option per active rule', async () => {
    const { fares, prisma, routed, straight } = harness();
    const quote = await fares.quotes({ stops: inside }, dispatcher);

    expect(routed).toHaveBeenCalledOnce();
    expect(straight).not.toHaveBeenCalled();
    expect(quote).toMatchObject({
      distanceM: 8100,
      durationS: 1020,
      source: 'ROUTES',
      zone: 'INSIDE_TOWN',
    });
    expect(quote.options.map((option) => option.name)).toEqual([
      'Sedan',
      'SUV',
    ]);
    expect(quote.options[0]).toMatchObject({
      etaMinutes: null,
      vehicleTypeId: 'sedan-id',
    });
    expect(quote.options[0]?.quoteToken).toEqual(expect.any(String));
    const accepted = verifyQuote(quote.options[1]?.quoteToken ?? '', 'secret', {
      branchId: 'branch-1',
      vehicleTypeId: 'suv-id',
      zone: 'INSIDE_TOWN',
      stopsHash: stopsHash(inside),
    });
    expect(accepted?.totalCents).toBe(quote.options[1]?.totalCents);
    expect(prisma.fareRule.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          branchId: 'branch-1',
          zone: 'INSIDE_TOWN',
          active: true,
          vehicleType: { active: true },
        },
      }),
    );
  });

  it('lets staff override the zone and ignores a passenger override', async () => {
    const staff = harness();
    const overridden = await staff.fares.quotes(
      { stops: inside, zone: 'OUT_OF_TOWN' },
      dispatcher,
    );
    expect(overridden.zone).toBe('OUT_OF_TOWN');

    const guest = harness();
    const derived = await guest.fares.quotes(
      { stops: inside, zone: 'OUT_OF_TOWN' },
      passenger,
    );
    expect(derived.zone).toBe('INSIDE_TOWN');
  });

  it('refuses a passenger quote when the branch has no centre', async () => {
    const { fares } = harness({ centerLat: null, centerLng: null });
    await expect(
      fares.quotes({ stops: inside }, passenger),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('keeps a single Routes call when the provider falls back to ESTIMATE', async () => {
    const { fares, routed, straight } = harness();
    routed.mockResolvedValueOnce({
      meters: 1300,
      seconds: 117,
      source: 'ESTIMATE' as const,
    });
    const quote = await fares.quotes({ stops: inside }, dispatcher);
    expect(routed).toHaveBeenCalledOnce();
    expect(straight).not.toHaveBeenCalled();
    expect(quote.source).toBe('ESTIMATE');
    expect(quote.distanceM).toBe(1300);
  });
});
