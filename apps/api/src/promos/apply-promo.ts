export type PromoInput = {
  type: 'PERCENT' | 'FIXED';
  valueBps?: number | null;
  valueCents?: number | null;
  maxDiscountCents?: number | null;
};

/** Pure discount math. Quote endpoint is the only caller before booking. */
export function applyPromo(subtotalCents: number, promo: PromoInput) {
  let discount =
    promo.type === 'PERCENT'
      ? Math.round((subtotalCents * (promo.valueBps ?? 0)) / 10000)
      : (promo.valueCents ?? 0);
  if (promo.maxDiscountCents != null) {
    discount = Math.min(discount, promo.maxDiscountCents);
  }
  discount = Math.max(0, Math.min(discount, subtotalCents));
  return { discountCents: discount, netSubtotalCents: subtotalCents - discount };
}
