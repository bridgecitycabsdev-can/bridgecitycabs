import { describe, expect, it } from 'vitest';
import { branchDayWindow, shiftSeconds } from './fleet-day.js';

describe('branch day window', () => {
  it('uses the branch timezone, including standard time', () => {
    const summer = branchDayWindow('America/Edmonton', new Date('2026-09-30T15:00:00.000Z'));
    expect(summer.start.toISOString()).toBe('2026-09-30T06:00:00.000Z');
    expect(summer.end.toISOString()).toBe('2026-10-01T06:00:00.000Z');

    const winter = branchDayWindow('America/Edmonton', new Date('2026-01-15T15:00:00.000Z'));
    expect(winter.start.toISOString()).toBe('2026-01-15T07:00:00.000Z');
    expect(winter.end.toISOString()).toBe('2026-01-16T07:00:00.000Z');
  });

  it('counts whole seconds on the open shift', () => {
    const started = new Date('2026-09-30T15:00:00.000Z');
    expect(shiftSeconds(started, new Date('2026-09-30T15:01:01.900Z'))).toBe(61);
  });
});
