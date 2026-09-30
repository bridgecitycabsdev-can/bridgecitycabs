import type { FareRule } from '@prisma/client';

type FareAmounts = Pick<
  FareRule,
  'baseFareCents' | 'perKmCents' | 'perMinuteCents' | 'minFareCents'
>;

export function calcFare(
  rule: FareAmounts,
  distanceMeters: number,
  durationSeconds: number,
  gstBps: number,
) {
  const km = distanceMeters / 1000;
  const raw =
    rule.baseFareCents +
    Math.round(km * rule.perKmCents) +
    Math.round((durationSeconds / 60) * rule.perMinuteCents);
  const subtotal = Math.max(rule.minFareCents, raw);
  const tax = Math.round((subtotal * gstBps) / 10000);
  return { subtotalCents: subtotal, taxCents: tax, totalCents: subtotal + tax };
}
