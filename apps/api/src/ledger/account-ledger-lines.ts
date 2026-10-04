import type { AccountType } from '@prisma/client';
import {
  accountsReceivableKey,
  companyRevenueKey,
  driverBalanceKey,
  gstPayableKey,
} from './account-keys.js';
import type { LedgerPostLine } from './ledger.service.js';
import { accountPostings } from './trip-postings.js';

export function accountTripLedgerLines(i: {
  branchId: string;
  driverId: string;
  corporateAccountId: string;
  subtotalCents: number;
  taxCents: number;
  commissionCents: number;
  driverEarningCents: number;
}): LedgerPostLine[] {
  return accountPostings({
    corporateAccountId: i.corporateAccountId,
    subtotal: i.subtotalCents,
    tax: i.taxCents,
    commission: i.commissionCents,
    driverEarning: i.driverEarningCents,
  }).map((line) => ({
    accountKey: accountKeyFor(line, i),
    type: line.type as AccountType,
    ownerId:
      line.type === 'DRIVER_BALANCE'
        ? i.driverId
        : line.type === 'ACCOUNTS_RECEIVABLE'
          ? i.corporateAccountId
          : undefined,
    amountCents: line.amt,
  }));
}

function accountKeyFor(
  line: { acct: string; type: string },
  i: { branchId: string; driverId: string; corporateAccountId: string },
) {
  switch (line.type) {
    case 'ACCOUNTS_RECEIVABLE':
      return accountsReceivableKey(i.corporateAccountId);
    case 'DRIVER_BALANCE':
      return driverBalanceKey(i.driverId);
    case 'COMPANY_REVENUE':
      return companyRevenueKey(i.branchId);
    case 'GST_PAYABLE':
      return gstPayableKey(i.branchId);
    default:
      return line.acct.includes(':') ? line.acct : `${line.acct}:${i.branchId}`;
  }
}
