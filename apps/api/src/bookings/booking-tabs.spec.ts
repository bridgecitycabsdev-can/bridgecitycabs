import { BookingStatus } from '@prisma/client';
import { describe, expect, it } from 'vitest';
import { BOOKING_TABS } from './booking-tabs.js';

describe('BOOKING_TABS', () => {
  it('puts every status in exactly one tab', () => {
    const seen = Object.values(BOOKING_TABS).flat();
    expect(new Set(seen).size).toBe(seen.length);
    expect(new Set(seen)).toEqual(new Set(Object.values(BookingStatus)));
  });
});
