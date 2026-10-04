-- Corporate AR + bank clearing as first-class ledger account types.
ALTER TYPE "AccountType" ADD VALUE IF NOT EXISTS 'ACCOUNTS_RECEIVABLE';
ALTER TYPE "AccountType" ADD VALUE IF NOT EXISTS 'BANK_CLEARING';
