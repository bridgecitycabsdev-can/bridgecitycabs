import { describe, expect, it } from 'vitest';
import { calcFare } from './calc-fare.js';

const suvInsideTown = {
  baseFareCents: 595,
  perKmCents: 249,
  perMinuteCents: 0,
  minFareCents: 0,
};

describe('calcFare', () => {
  it('adds GST on top of a tax-exclusive base and per-km rate', () => {
    const fare = calcFare(suvInsideTown, 10_000, 0, 500);
    expect(fare).toEqual({
      subtotalCents: 595 + 2490,
      taxCents: 154,
      totalCents: 3085 + 154,
    });
  });

  it('applies the minimum before tax', () => {
    const fare = calcFare(
      {
        baseFareCents: 100,
        perKmCents: 0,
        perMinuteCents: 0,
        minFareCents: 500,
      },
      0,
      0,
      500,
    );
    expect(fare).toEqual({
      subtotalCents: 500,
      taxCents: 25,
      totalCents: 525,
    });
  });

  it('rounds the per-minute component on its own', () => {
    const fare = calcFare(
      { baseFareCents: 0, perKmCents: 0, perMinuteCents: 33, minFareCents: 0 },
      0,
      90,
      0,
    );
    expect(fare).toEqual({
      subtotalCents: 50,
      taxCents: 0,
      totalCents: 50,
    });
  });

  it('leaves a zero per-minute rate out of the legacy base-plus-km example', () => {
    const withTime = calcFare(suvInsideTown, 0, 600, 500);
    const withoutTime = calcFare(suvInsideTown, 0, 0, 500);
    expect(withTime).toEqual(withoutTime);
    expect(withTime.subtotalCents).toBe(595);
    expect(withTime.taxCents).toBe(30);
  });

  it('rounds distance, duration, and GST, and returns only integers', () => {
    const rule = {
      baseFareCents: 100,
      perKmCents: 249,
      perMinuteCents: 100,
      minFareCents: 500,
    };
    const cases = [
      { meters: 0, seconds: 0, subtotalCents: 500, taxCents: 25 },
      { meters: 1_500, seconds: 0, subtotalCents: 500, taxCents: 25 },
      { meters: 2_000, seconds: 125, subtotalCents: 806, taxCents: 40 },
      { meters: 10_000, seconds: 900, subtotalCents: 4_090, taxCents: 205 },
    ];

    for (const entry of cases) {
      const fare = calcFare(rule, entry.meters, entry.seconds, 500);
      expect(fare.subtotalCents).toBe(entry.subtotalCents);
      expect(fare.taxCents).toBe(entry.taxCents);
      expect(fare.totalCents).toBe(entry.subtotalCents + entry.taxCents);
      expect(Number.isInteger(fare.subtotalCents)).toBe(true);
      expect(Number.isInteger(fare.taxCents)).toBe(true);
      expect(Number.isInteger(fare.totalCents)).toBe(true);
    }

    expect(
      calcFare(
        {
          baseFareCents: 10,
          perKmCents: 0,
          perMinuteCents: 0,
          minFareCents: 0,
        },
        0,
        0,
        500,
      ).taxCents,
    ).toBe(1);
    expect(
      calcFare(
        { baseFareCents: 9, perKmCents: 0, perMinuteCents: 0, minFareCents: 0 },
        0,
        0,
        500,
      ).taxCents,
    ).toBe(0);
  });
});
