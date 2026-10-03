import { describe, expect, it } from 'vitest';
import { PlacesController } from './places.controller.js';

describe('PlacesController throttle', () => {
  it('limits places traffic per user', () => {
    expect(Reflect.getMetadata('THROTTLER:LIMITdefault', PlacesController)).toBe(
      40,
    );
    expect(Reflect.getMetadata('THROTTLER:TTLdefault', PlacesController)).toBe(
      60_000,
    );
  });
});
