import * as fc from 'fast-check';
import { describe, expect, it } from 'vitest';
import { finalizeFare, splitFare } from '../fares/finalize-fare.js';
import {
  driverBalanceFromEntries,
  tripPostings,
} from './trip-postings.js';

function sum(lines: { amt: number }[]) {
  return lines.reduce((s, l) => s + l.amt, 0);
}

describe('tripPostings', () => {
  it('posts a balanced cash trip where the driver holds the cash', () => {
    const lines = tripPostings({
      method: 'CASH',
      subtotal: 2000,
      tax: 100,
      commission: 200,
      driverEarning: 1800,
    });
    expect(sum(lines)).toBe(0);
    expect(lines).toEqual([
      { acct: 'DRIVER_BALANCE', amt: 300 },
      { acct: 'COMPANY_REVENUE', amt: -200 },
      { acct: 'GST_PAYABLE', amt: -100 },
    ]);
    expect(driverBalanceFromEntries([300])).toBe(-300);
  });

  it('posts a balanced card trip where the company clears the fare', () => {
    const lines = tripPostings({
      method: 'CARD',
      subtotal: 2000,
      tax: 100,
      commission: 200,
      driverEarning: 1800,
    });
    expect(sum(lines)).toBe(0);
    expect(lines).toEqual([
      { acct: 'PAYMENT_CLEARING', amt: 2100 },
      { acct: 'DRIVER_BALANCE', amt: -1800 },
      { acct: 'COMPANY_REVENUE', amt: -200 },
      { acct: 'GST_PAYABLE', amt: -100 },
    ]);
    expect(driverBalanceFromEntries([-1800])).toBe(1800);
  });

  it('works the $25.10 subtotal at 5% GST and 15% commission for cash and card', () => {
    const fare = finalizeFare({
      quotedSubtotalCents: 2510,
      gstBps: 500,
      fixedIncludesGst: false,
    });
    expect(fare).toEqual({
      subtotalCents: 2510,
      taxCents: 126,
      totalCents: 2636,
    });
    const split = splitFare(fare.subtotalCents, 1500);
    expect(split).toEqual({
      commissionCents: 377,
      driverEarningCents: 2133,
    });
    expect(split.commissionCents + split.driverEarningCents).toBe(2510);

    const cash = tripPostings({
      method: 'CASH',
      subtotal: fare.subtotalCents,
      tax: fare.taxCents,
      commission: split.commissionCents,
      driverEarning: split.driverEarningCents,
    });
    expect(sum(cash)).toBe(0);
    expect(cash.every((line) => line.amt !== 0)).toBe(true);
    expect(cash).toEqual([
      { acct: 'DRIVER_BALANCE', amt: 503 }, // commission + tax
      { acct: 'COMPANY_REVENUE', amt: -377 },
      { acct: 'GST_PAYABLE', amt: -126 },
    ]);
    expect(
      driverBalanceFromEntries(
        cash.filter((l) => l.acct === 'DRIVER_BALANCE').map((l) => l.amt),
      ),
    ).toBe(-503);

    const card = tripPostings({
      method: 'CARD',
      subtotal: fare.subtotalCents,
      tax: fare.taxCents,
      commission: split.commissionCents,
      driverEarning: split.driverEarningCents,
    });
    expect(sum(card)).toBe(0);
    expect(card.every((line) => line.amt !== 0)).toBe(true);
    expect(card).toEqual([
      { acct: 'PAYMENT_CLEARING', amt: 2636 },
      { acct: 'DRIVER_BALANCE', amt: -2133 },
      { acct: 'COMPANY_REVENUE', amt: -377 },
      { acct: 'GST_PAYABLE', amt: -126 },
    ]);
    expect(
      driverBalanceFromEntries(
        card.filter((l) => l.acct === 'DRIVER_BALANCE').map((l) => l.amt),
      ),
    ).toBe(2133);
  });

  it('drops zero-amount lines', () => {
    expect(
      tripPostings({
        method: 'CASH',
        subtotal: 1000,
        tax: 0,
        commission: 0,
        driverEarning: 1000,
      }),
    ).toEqual([]);
    expect(
      tripPostings({
        method: 'CARD',
        subtotal: 1000,
        tax: 0,
        commission: 0,
        driverEarning: 1000,
      }),
    ).toEqual([
      { acct: 'PAYMENT_CLEARING', amt: 1000 },
      { acct: 'DRIVER_BALANCE', amt: -1000 },
    ]);
  });

  it('property: balanced postings, full split, and no zero lines', () => {
    fc.assert(
      fc.property(
        fc.integer({ min: 0, max: 100_000 }),
        fc.integer({ min: 0, max: 10_000 }),
        fc.constantFrom('CASH' as const, 'CARD' as const),
        (subtotal, commissionBps, method) => {
          const tax = Math.round((subtotal * 500) / 10_000);
          const split = splitFare(subtotal, commissionBps);
          expect(split.commissionCents + split.driverEarningCents).toBe(subtotal);
          const lines = tripPostings({
            method,
            subtotal,
            tax,
            commission: split.commissionCents,
            driverEarning: split.driverEarningCents,
          });
          expect(sum(lines)).toBe(0);
          expect(lines.every((line) => line.amt !== 0)).toBe(true);
          expect(lines.every((line) => Number.isInteger(line.amt))).toBe(true);
        },
      ),
      { numRuns: 200 },
    );
  });

  it('cash-heavy entries make the driver owe the company; card-heavy the reverse', () => {
    const cash = tripPostings({
      method: 'CASH',
      subtotal: 2000,
      tax: 100,
      commission: 200,
      driverEarning: 1800,
    });
    const card = tripPostings({
      method: 'CARD',
      subtotal: 2000,
      tax: 100,
      commission: 200,
      driverEarning: 1800,
    });
    const cashDriver = cash.find((l) => l.acct === 'DRIVER_BALANCE')!.amt;
    const cardDriver = card.find((l) => l.acct === 'DRIVER_BALANCE')!.amt;
    expect(driverBalanceFromEntries([cashDriver])).toBeLessThan(0);
    expect(driverBalanceFromEntries([cardDriver])).toBeGreaterThan(0);
  });
});
