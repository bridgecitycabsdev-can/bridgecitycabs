import { describe, expect, it } from 'vitest';
import {
  leaseDeductionCronPattern,
  previousBranchWeek,
  startOfBranchWeek,
  weeklyCloseCronPattern,
} from './lease-week.js';

describe('startOfBranchWeek', () => {
  it('returns Monday 00:00 America/Edmonton for a mid-week instant', () => {
    // Wednesday 2026-10-07 15:00 UTC → Monday local
    const week = startOfBranchWeek(
      'America/Edmonton',
      new Date('2026-10-07T15:00:00.000Z'),
    );
    expect(week.toISOString()).toBe('2026-10-05T06:00:00.000Z');
  });

  it('stays on the same Monday when already Monday local morning', () => {
    const week = startOfBranchWeek(
      'America/Edmonton',
      new Date('2026-10-05T12:00:00.000Z'),
    );
    expect(week.toISOString()).toBe('2026-10-05T06:00:00.000Z');
  });
});

describe('leaseDeductionCronPattern', () => {
  it('defaults to Monday local midnight', () => {
    expect(leaseDeductionCronPattern(undefined)).toBe('0 0 * * 1');
    expect(leaseDeductionCronPattern('MON')).toBe('0 0 * * 1');
  });

  it('maps weekdays', () => {
    expect(leaseDeductionCronPattern('FRI')).toBe('0 0 * * 5');
    expect(leaseDeductionCronPattern('sun')).toBe('0 0 * * 0');
  });
});

describe('weeklyCloseCronPattern', () => {
  it('is the day after lease deduction', () => {
    expect(weeklyCloseCronPattern('MON')).toBe('0 0 * * 2');
    expect(weeklyCloseCronPattern('SUN')).toBe('0 0 * * 1');
  });
});

describe('previousBranchWeek', () => {
  it('returns [prev Monday, this Monday) in branch TZ', () => {
    const now = new Date('2026-10-01T12:00:00.000Z');
    const { weekStart, weekEnd } = previousBranchWeek('America/Edmonton', now);
    expect(weekEnd.getTime()).toBe(
      startOfBranchWeek('America/Edmonton', now).getTime(),
    );
    expect(weekStart.getTime()).toBeLessThan(weekEnd.getTime());
    expect(weekEnd.getTime() - weekStart.getTime()).toBe(
      7 * 24 * 60 * 60 * 1000,
    );
  });
});
