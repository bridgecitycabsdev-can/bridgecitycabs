import { BookingStatus } from '@prisma/client';
import { describe, expect, it } from 'vitest';
import { BOOKING_TABS } from './booking-tabs.js';

describe('BOOKING_TABS', () => {
  it('keeps manual-mode jobs and no-driver-found on the unassigned tab', () => {
    expect(BOOKING_TABS.unassigned).toEqual([
      'SCHEDULED',
      'CREATED',
      'SEARCHING_DRIVER',
      'NO_DRIVER_FOUND',
    ]);
    expect(BOOKING_TABS.assigned).toContain('MATCHED');
  });

  it('puts every status in exactly one tab', () => {
    const seen = Object.values(BOOKING_TABS).flat();
    expect(new Set(seen).size).toBe(seen.length);
    expect(new Set(seen)).toEqual(new Set(Object.values(BookingStatus)));
  });
});
