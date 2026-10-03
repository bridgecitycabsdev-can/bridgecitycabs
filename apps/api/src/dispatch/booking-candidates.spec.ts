import { describe, expect, it } from 'vitest';
import { describeNearby } from './matching.service.js';

const hit = { driverId: 'driver-1', distanceM: 400 };

describe('nearby driver eligibility', () => {
  it('marks a matching fresh driver eligible, and names each miss', () => {
    const fresh = describeNearby(
      hit,
      ['AVAILABLE', 'SUV', '1', String(Date.now()), 'Ada', '111', 'veh-1'],
      rule(),
    );
    expect(fresh).toMatchObject({ eligible: true, reasons: [], name: 'Ada', unit: '111' });

    const missed = describeNearby(
      hit,
      ['AVAILABLE', 'Sedan', '0', '1', 'Bea', '12', 'veh-2'],
      rule({ vanOnly: true, ladyDriverOnly: true, nowMs: 100_000, maxAgeSeconds: 30 }),
    );
    expect(missed?.eligible).toBe(false);
    expect(missed?.reasons).toEqual([
      'STALE_LOCATION',
      'VEHICLE_TYPE_MISMATCH',
      'NOT_VAN',
      'NOT_LADY_ELIGIBLE',
    ]);
  });

  it('skips a driver who is not available', () => {
    expect(
      describeNearby(hit, ['OFFERED', 'SUV', '1', String(Date.now()), 'Ada', '111', 'veh-1'], rule()),
    ).toBeNull();
  });
});

function rule(overrides: Record<string, unknown> = {}) {
  return {
    bookingVehicleType: 'SUV',
    vanOnly: false,
    ladyDriverOnly: false,
    nowMs: Date.now(),
    maxAgeSeconds: 30,
    ...overrides,
  };
}
