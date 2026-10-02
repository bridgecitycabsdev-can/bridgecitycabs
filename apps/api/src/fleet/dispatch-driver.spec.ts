import { describe, expect, it } from 'vitest';
import { toDispatchDriver } from './dispatch-driver.js';

describe('toDispatchDriver', () => {
  it('renames unit to unitNumber and keeps the map fields', () => {
    expect(
      toDispatchDriver({
        id: '11111111-1111-4111-8111-111111111111',
        v: 4,
        status: 'AVAILABLE',
        lat: 49.6935,
        lng: -112.8418,
        heading: 90,
        speedMps: 0,
        accuracyM: 8,
        ts: 1_700_000_000_000,
        name: 'Priya Nair',
        unit: '11',
        vehicleType: 'SUV',
        bookingId: null,
        stale: false,
      }),
    ).toEqual({
      id: '11111111-1111-4111-8111-111111111111',
      name: 'Priya Nair',
      unitNumber: '11',
      vehicleType: 'SUV',
      status: 'AVAILABLE',
      lat: 49.6935,
      lng: -112.8418,
      ts: 1_700_000_000_000,
      stale: false,
    });
  });
});
