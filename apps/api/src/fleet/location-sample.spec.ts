import { describe, expect, it } from 'vitest';
import { HISTORY_IDLE_SAMPLE_MS, shouldSampleLocation } from './location-sample.js';

describe('location history sampling', () => {
  it('keeps every ping on a trip and one a minute otherwise', () => {
    expect(shouldSampleLocation('ON_TRIP', 1_000, 2_000)).toBe(true);
    expect(shouldSampleLocation('ARRIVED', 1_000, 2_000)).toBe(true);
    expect(shouldSampleLocation('EN_ROUTE_PICKUP', 1_000, 2_000)).toBe(true);
    expect(shouldSampleLocation('AVAILABLE', null, 5_000)).toBe(true);
    expect(shouldSampleLocation('AVAILABLE', 5_000, 5_000 + HISTORY_IDLE_SAMPLE_MS - 1)).toBe(
      false,
    );
    expect(shouldSampleLocation('AWAY', 5_000, 5_000 + HISTORY_IDLE_SAMPLE_MS)).toBe(true);
    expect(shouldSampleLocation('ASSIGNED', 5_000, 6_000)).toBe(false);
  });
});