/** Finalize the fare from what was quoted or fixed. Integer cents only. */
export function finalizeFare(i: {
  quotedSubtotalCents: number;
  fixedFareCents?: number | null;
  gstBps: number;
  fixedIncludesGst: boolean;
}) {
  let subtotal = i.quotedSubtotalCents;
  let tax = Math.round((subtotal * i.gstBps) / 10000);
  if (i.fixedFareCents != null) {
    if (i.fixedIncludesGst) {
      subtotal = Math.round((i.fixedFareCents * 10000) / (10000 + i.gstBps));
      tax = i.fixedFareCents - subtotal;
    } else {
      subtotal = i.fixedFareCents;
      tax = Math.round((subtotal * i.gstBps) / 10000);
    }
  }
  return { subtotalCents: subtotal, taxCents: tax, totalCents: subtotal + tax };
}

/** Split pre-GST subtotal into commission and driver earning. All cents are assigned. */
export function splitFare(subtotalCents: number, commissionBps: number) {
  const commissionCents = Math.round((subtotalCents * commissionBps) / 10000);
  return { commissionCents, driverEarningCents: subtotalCents - commissionCents };
}
