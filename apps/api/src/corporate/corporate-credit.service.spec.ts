import {
  ConflictException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { CorporateCreditService } from './corporate-credit.service.js';

describe('CorporateCreditService', () => {
  it('returns debit-positive AR balance from ledger sums', async () => {
    const prisma = {
      ledgerEntry: {
        aggregate: vi.fn(async () => ({
          _sum: { amountCents: 12_500 },
        })),
      },
    };
    const service = new CorporateCreditService(prisma as never);
    await expect(
      service.getAccountReceivableBalance('acct-1'),
    ).resolves.toBe(12_500);
    expect(prisma.ledgerEntry.aggregate).toHaveBeenCalledWith({
      _sum: { amountCents: true },
      where: { account: { key: 'ACCOUNTS_RECEIVABLE:acct-1' } },
    });
  });

  it('treats creditLimitCents 0 as unlimited', async () => {
    const prisma = {
      corporateAccount: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'acct-1',
          active: true,
          creditLimitCents: 0,
        })),
      },
      ledgerEntry: {
        aggregate: vi.fn(async () => ({
          _sum: { amountCents: 999_999 },
        })),
      },
    };
    const service = new CorporateCreditService(prisma as never);
    await expect(
      service.checkCreditLimit('acct-1', 50_000),
    ).resolves.toMatchObject({
      currentCents: 999_999,
      limitCents: 0,
      requestedCents: 50_000,
    });
  });

  it('rejects inactive accounts', async () => {
    const prisma = {
      corporateAccount: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'acct-1',
          active: false,
          creditLimitCents: 10_000,
        })),
      },
      ledgerEntry: { aggregate: vi.fn() },
    };
    const service = new CorporateCreditService(prisma as never);
    await expect(service.checkCreditLimit('acct-1', 100)).rejects.toMatchObject(
      {
        response: { code: 'ACCOUNT_INACTIVE' },
      },
    );
    expect(prisma.ledgerEntry.aggregate).not.toHaveBeenCalled();
    await expect(
      service.checkCreditLimit('acct-1', 100),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
  });

  it('rejects when current AR plus estimate exceeds the limit', async () => {
    const prisma = {
      corporateAccount: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'acct-1',
          active: true,
          creditLimitCents: 10_000,
        })),
      },
      ledgerEntry: {
        aggregate: vi.fn(async () => ({
          _sum: { amountCents: 8_000 },
        })),
      },
    };
    const service = new CorporateCreditService(prisma as never);
    await expect(
      service.checkCreditLimit('acct-1', 3_000),
    ).rejects.toBeInstanceOf(ConflictException);
    await expect(service.checkCreditLimit('acct-1', 3_000)).rejects.toMatchObject(
      {
        response: {
          code: 'CREDIT_LIMIT_EXCEEDED',
          currentCents: 8_000,
          limitCents: 10_000,
          requestedCents: 3_000,
        },
      },
    );
  });

  it('allows a booking that fits under the remaining credit', async () => {
    const prisma = {
      corporateAccount: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'acct-1',
          active: true,
          creditLimitCents: 10_000,
        })),
      },
      ledgerEntry: {
        aggregate: vi.fn(async () => ({
          _sum: { amountCents: 8_000 },
        })),
      },
    };
    const service = new CorporateCreditService(prisma as never);
    await expect(
      service.checkCreditLimit('acct-1', 2_000),
    ).resolves.toMatchObject({ currentCents: 8_000, requestedCents: 2_000 });
  });
});
