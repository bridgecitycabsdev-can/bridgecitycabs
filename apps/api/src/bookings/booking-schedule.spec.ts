import { BadRequestException } from '@nestjs/common';
import { describe, expect, it } from 'vitest';
import { assertScheduledAt } from './booking-schedule.js';

const now = new Date('2026-09-30T12:00:00.000Z');

describe('assertScheduledAt', () => {
  it('accepts a pickup inside the configured window', () => {
    expect(() =>
      assertScheduledAt(new Date('2026-09-30T12:15:00.000Z'), now, 15, 30),
    ).not.toThrow();
    expect(() =>
      assertScheduledAt(new Date('2026-10-30T12:00:00.000Z'), now, 15, 30),
    ).not.toThrow();
  });

  it('rejects a pickup sooner than the lead time or past the horizon', () => {
    expect(() =>
      assertScheduledAt(new Date('2026-09-30T12:14:59.000Z'), now, 15, 30),
    ).toThrow(BadRequestException);
    expect(() =>
      assertScheduledAt(new Date('2026-10-30T12:00:00.001Z'), now, 15, 30),
    ).toThrow(/30 days/);
  });
});
