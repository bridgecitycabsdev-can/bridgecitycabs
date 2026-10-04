/** Stable FinancialAccount.key values used by LedgerService.post. */

export function driverBalanceKey(driverId: string) {
  return `DRIVER_BALANCE:${driverId}`;
}

export function companyRevenueKey(branchId: string) {
  return `COMPANY_REVENUE:${branchId}`;
}

export function gstPayableKey(branchId: string) {
  return `GST_PAYABLE:${branchId}`;
}

export function paymentClearingKey(branchId: string) {
  return `PAYMENT_CLEARING:${branchId}`;
}

/** Manual payout clearing (e-Transfer / deposit in flight). */
export function bankClearingKey(branchId: string) {
  return `BANK_CLEARING:${branchId}`;
}

/** Corporate account receivable — positive sum = amount the account owes. */
export function accountsReceivableKey(corporateAccountId: string) {
  return `ACCOUNTS_RECEIVABLE:${corporateAccountId}`;
}
