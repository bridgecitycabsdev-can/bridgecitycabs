import { describe, expect, it } from 'vitest';
import { newTrackingId, TRACKING_ALPHABET } from './tracking-id.js';

describe('newTrackingId', () => {
  it('uses BC- plus 8 characters from an unambiguous alphabet', () => {
    expect(TRACKING_ALPHABET).not.toMatch(/[01IOL]/);
    for (let i = 0; i < 50; i += 1) {
      expect(newTrackingId()).toMatch(
        new RegExp(`^BC-[${TRACKING_ALPHABET}]{8}$`),
      );
    }
  });
});
