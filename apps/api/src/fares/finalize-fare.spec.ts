import { describe, expect, it } from 'vitest';
import { finalizeFare, splitFare } from './finalize-fare.js';

describe('finalizeFare', () => {
  it('taxes the quoted subtotal when there is no fixed fare', () => {
    expect(
      finalizeFare({
        quotedSubtotalCents: 2000,
        gstBps: 500,
        fixedIncludesGst: false,
      }),
    ).toEqual({ subtotalCents: 2000, taxCents: 100, totalCents: 2100 });
  });

  it('treats a tax-exclusive fixed fare as the subtotal', () => {
    const fare = finalizeFare({
      quotedSubtotalCents: 2000,
      fixedFareCents: 3000,
      gstBps: 500,
      fixedIncludesGst: false,
    });
    expect(fare).toEqual({
      subtotalCents: 3000,
      taxCents: 150,
      totalCents: 3150,
    });
    expect(fare.subtotalCents + fare.taxCents).toBe(fare.totalCents);
  });

  it('backs GST out of a tax-inclusive fixed fare and keeps the total exact', () => {
    const fare = finalizeFare({
      quotedSubtotalCents: 2000,
      fixedFareCents: 2100,
      gstBps: 500,
      fixedIncludesGst: true,
    });
    expect(fare.totalCents).toBe(2100);
    expect(fare.subtotalCents + fare.taxCents).toBe(2100);
    expect(fare).toEqual({
      subtotalCents: 2000,
      taxCents: 100,
      totalCents: 2100,
    });
  });

  it('keeps subtotal + tax equal to the fixed amount in inclusive mode', () => {
    for (const gstBps of [0, 500, 1300]) {
      for (let fixed = 0; fixed <= 10_000; fixed += 37) {
        const fare = finalizeFare({
          quotedSubtotalCents: 1,
          fixedFareCents: fixed,
          gstBps,
          fixedIncludesGst: true,
        });
        expect(fare.totalCents).toBe(fixed);
        expect(fare.subtotalCents + fare.taxCents).toBe(fixed);
        expect(Number.isInteger(fare.subtotalCents)).toBe(true);
        expect(Number.isInteger(fare.taxCents)).toBe(true);
      }
    }
  });

  it('works the $25.10 example at 5% GST without a fixed fare', () => {
    expect(
      finalizeFare({
        quotedSubtotalCents: 2510,
        gstBps: 500,
        fixedIncludesGst: false,
      }),
    ).toEqual({ subtotalCents: 2510, taxCents: 126, totalCents: 2636 });
  });

  it('ignores null fixedFareCents the same as omitted', () => {
    expect(
      finalizeFare({
        quotedSubtotalCents: 999,
        fixedFareCents: null,
        gstBps: 500,
        fixedIncludesGst: true,
      }),
    ).toEqual({ subtotalCents: 999, taxCents: 50, totalCents: 1049 });
  });
});

describe('splitFare', () => {
  it('gives the whole subtotal to the driver when commission is zero', () => {
    expect(splitFare(2500, 0)).toEqual({
      commissionCents: 0,
      driverEarningCents: 2500,
    });
  });

  it('assigns every cent between commission and driver earning', () => {
    for (const bps of [0, 1, 500, 2500, 10000]) {
      for (let subtotal = 0; subtotal <= 5_000; subtotal += 17) {
        const split = splitFare(subtotal, bps);
        expect(split.commissionCents + split.driverEarningCents).toBe(subtotal);
        expect(Number.isInteger(split.commissionCents)).toBe(true);
        expect(Number.isInteger(split.driverEarningCents)).toBe(true);
      }
    }
  });

  it('splits the $25.10 subtotal at 15% commission without remainder', () => {
    expect(splitFare(2510, 1500)).toEqual({
      commissionCents: 377,
      driverEarningCents: 2133,
    });
  });
});
