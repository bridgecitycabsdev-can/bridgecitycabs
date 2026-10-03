import { describe, expect, it, vi } from 'vitest';
import {
  companyRevenueKey,
  driverBalanceKey,
  gstPayableKey,
  paymentClearingKey,
} from './account-keys.js';
import { LedgerService } from './ledger.service.js';

describe('account keys', () => {
  it('uses the stable prefixes from the money design', () => {
    expect(driverBalanceKey('d1')).toBe('DRIVER_BALANCE:d1');
    expect(companyRevenueKey('b1')).toBe('COMPANY_REVENUE:b1');
    expect(gstPayableKey('b1')).toBe('GST_PAYABLE:b1');
    expect(paymentClearingKey('b1')).toBe('PAYMENT_CLEARING:b1');
  });
});

describe('LedgerService.post', () => {
  it('returns the existing transaction without writing again', async () => {
    const existing = { id: 'txn-1', kind: 'TRIP_CASH' };
    const tx = {
      ledgerTransaction: {
        findUnique: vi.fn(async () => existing),
        create: vi.fn(),
      },
      financialAccount: { upsert: vi.fn() },
      ledgerEntry: { create: vi.fn() },
    };
    const service = new LedgerService();

    const result = await service.post(tx as never, {
      kind: 'TRIP_CASH',
      sourceType: 'BOOKING',
      sourceId: 'booking-1',
      branchId: 'branch-1',
      lines: [
        {
          accountKey: companyRevenueKey('branch-1'),
          type: 'COMPANY_REVENUE',
          amountCents: -100,
        },
      ],
    });

    expect(result).toBe(existing);
    expect(tx.ledgerTransaction.create).not.toHaveBeenCalled();
    expect(tx.financialAccount.upsert).not.toHaveBeenCalled();
    expect(tx.ledgerEntry.create).not.toHaveBeenCalled();
  });

  it('creates the transaction, upserts accounts, and posts each line', async () => {
    const created = { id: 'txn-2', kind: 'TRIP_CARD' };
    const tx = {
      ledgerTransaction: {
        findUnique: vi.fn(async () => null),
        create: vi.fn(async () => created),
      },
      financialAccount: {
        upsert: vi
          .fn()
          .mockResolvedValueOnce({ id: 'acct-clearing' })
          .mockResolvedValueOnce({ id: 'acct-driver' }),
      },
      ledgerEntry: { create: vi.fn(async () => ({ id: 'entry' })) },
    };
    const service = new LedgerService();
    const lines = [
      {
        accountKey: paymentClearingKey('branch-1'),
        type: 'PAYMENT_CLEARING' as const,
        amountCents: 2100,
      },
      {
        accountKey: driverBalanceKey('driver-1'),
        type: 'DRIVER_BALANCE' as const,
        ownerId: 'driver-1',
        amountCents: -1800,
      },
    ];

    const result = await service.post(tx as never, {
      kind: 'TRIP_CARD',
      sourceType: 'BOOKING',
      sourceId: 'booking-2',
      branchId: 'branch-1',
      description: 'Trip card settlement',
      createdById: 'user-1',
      lines,
    });

    expect(result).toBe(created);
    expect(tx.ledgerTransaction.create).toHaveBeenCalledWith({
      data: {
        kind: 'TRIP_CARD',
        sourceType: 'BOOKING',
        sourceId: 'booking-2',
        branchId: 'branch-1',
        description: 'Trip card settlement',
        createdById: 'user-1',
        reversalOfId: undefined,
      },
    });
    expect(tx.financialAccount.upsert).toHaveBeenCalledTimes(2);
    expect(tx.financialAccount.upsert).toHaveBeenNthCalledWith(1, {
      where: { key: 'PAYMENT_CLEARING:branch-1' },
      update: {},
      create: {
        key: 'PAYMENT_CLEARING:branch-1',
        type: 'PAYMENT_CLEARING',
        branchId: 'branch-1',
        ownerId: undefined,
      },
    });
    expect(tx.financialAccount.upsert).toHaveBeenNthCalledWith(2, {
      where: { key: 'DRIVER_BALANCE:driver-1' },
      update: {},
      create: {
        key: 'DRIVER_BALANCE:driver-1',
        type: 'DRIVER_BALANCE',
        branchId: 'branch-1',
        ownerId: 'driver-1',
      },
    });
    expect(tx.ledgerEntry.create).toHaveBeenNthCalledWith(1, {
      data: {
        transactionId: 'txn-2',
        accountId: 'acct-clearing',
        amountCents: 2100,
      },
    });
    expect(tx.ledgerEntry.create).toHaveBeenNthCalledWith(2, {
      data: {
        transactionId: 'txn-2',
        accountId: 'acct-driver',
        amountCents: -1800,
      },
    });
  });

  it('stores reversalOfId when posting a REVERSAL', async () => {
    const created = { id: 'txn-rev', kind: 'REVERSAL' };
    const tx = {
      ledgerTransaction: {
        findUnique: vi.fn(async () => null),
        create: vi.fn(async () => created),
      },
      financialAccount: {
        upsert: vi.fn(async () => ({ id: 'acct-1' })),
      },
      ledgerEntry: { create: vi.fn(async () => ({ id: 'entry' })) },
    };
    const service = new LedgerService();
    await service.post(tx as never, {
      kind: 'REVERSAL',
      sourceType: 'REVERSAL',
      sourceId: 'txn-orig',
      branchId: 'branch-1',
      reversalOfId: 'txn-orig',
      lines: [
        {
          accountKey: companyRevenueKey('branch-1'),
          type: 'COMPANY_REVENUE',
          amountCents: 100,
        },
      ],
    });
    expect(tx.ledgerTransaction.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        kind: 'REVERSAL',
        reversalOfId: 'txn-orig',
      }),
    });
  });
});
