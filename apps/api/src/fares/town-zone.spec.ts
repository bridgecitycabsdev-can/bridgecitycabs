import { describe, expect, it } from 'vitest';
import { deriveZone } from './town-zone.js';

const centre = { lat: 0, lng: 0 };
const kmNorth = (km: number) => ({
  lat: ((km * 1000) / 6_371_000) * (180 / Math.PI),
  lng: 0,
});

describe('deriveZone', () => {
  it('is inside town only when every stop is within the radius', () => {
    expect(deriveZone(centre, 15, [centre, kmNorth(10)])).toBe('INSIDE_TOWN');
    expect(deriveZone(centre, 15, [centre, kmNorth(20)])).toBe('OUT_OF_TOWN');
    expect(deriveZone(null, 15, [centre, kmNorth(1)])).toBeNull();
  });
});
