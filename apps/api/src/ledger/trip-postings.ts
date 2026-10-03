export type TripPostingAccount =
  | 'DRIVER_BALANCE'
  | 'COMPANY_REVENUE'
  | 'GST_PAYABLE'
  | 'PAYMENT_CLEARING';

export type TripPostingLine = { acct: TripPostingAccount; amt: number };

/**
 * Posting rules: signed cents, debit positive. Zero-amount lines are dropped.
 *
 * Driver balance for reporting is `-SUM(entries)` on DRIVER_BALANCE: positive
 * means the company owes the driver; negative means the driver owes the company.
 */
export function tripPostings(i: {
  method: 'CASH' | 'CARD';
  subtotal: number;
  tax: number;
  commission: number;
  driverEarning: number;
}): TripPostingLine[] {
  const lines: TripPostingLine[] =
    i.method === 'CASH'
      ? [
          // Driver holds the cash, owes company its share.
          { acct: 'DRIVER_BALANCE', amt: +(i.commission + i.tax) },
          { acct: 'COMPANY_REVENUE', amt: -i.commission },
          { acct: 'GST_PAYABLE', amt: -i.tax },
        ]
      : [
          // Company received the money.
          { acct: 'PAYMENT_CLEARING', amt: +(i.subtotal + i.tax) },
          { acct: 'DRIVER_BALANCE', amt: -i.driverEarning },
          { acct: 'COMPANY_REVENUE', amt: -i.commission },
          { acct: 'GST_PAYABLE', amt: -i.tax },
        ];
  return lines.filter((l) => l.amt !== 0);
}

/** Driver ledger balance: positive = company owes driver; negative = driver owes company. */
export function driverBalanceFromEntries(
  entryAmountsOnDriverBalance: readonly number[],
) {
  return -entryAmountsOnDriverBalance.reduce((sum, amt) => sum + amt, 0);
}
