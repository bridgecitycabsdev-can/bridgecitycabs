import type { AccountType } from '@prisma/client';
import {
  companyRevenueKey,
  driverBalanceKey,
  gstPayableKey,
  paymentClearingKey,
} from './account-keys.js';
import type { LedgerPostLine } from './ledger.service.js';
import { tripPostings } from './trip-postings.js';

export function cardTripLedgerLines(i: {
  branchId: string;
  driverId: string;
  subtotalCents: number;
  taxCents: number;
  commissionCents: number;
  driverEarningCents: number;
}): LedgerPostLine[] {
  return tripPostings({
    method: 'CARD',
    subtotal: i.subtotalCents,
    tax: i.taxCents,
    commission: i.commissionCents,
    driverEarning: i.driverEarningCents,
  }).map((line) => ({
    accountKey: accountKeyFor(line.acct, i.branchId, i.driverId),
    type: line.acct as AccountType,
    ownerId: line.acct === 'DRIVER_BALANCE' ? i.driverId : undefined,
    amountCents: line.amt,
  }));
}

function accountKeyFor(acct: string, branchId: string, driverId: string) {
  switch (acct) {
    case 'DRIVER_BALANCE':
      return driverBalanceKey(driverId);
    case 'COMPANY_REVENUE':
      return companyRevenueKey(branchId);
    case 'GST_PAYABLE':
      return gstPayableKey(branchId);
    case 'PAYMENT_CLEARING':
      return paymentClearingKey(branchId);
    default:
      return `${acct}:${branchId}`;
  }
}
