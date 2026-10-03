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
