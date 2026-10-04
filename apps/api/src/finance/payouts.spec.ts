import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { FinanceService } from './finance.service.js';

const accountsUser = {
  userId: 'acct-1',
  role: 'accounts_admin',
  branchId: 'branch-1',
};
const branchAdmin = {
  userId: 'ba-1',
  role: 'branch_admin',
  branchId: 'branch-1',
};

describe('FinanceService.runPayouts', () => {
  it('creates PENDING payouts and SETTLEMENT posts for positive balances', async () => {
    const post = vi.fn(async () => ({ id: 'txn-1' }));
    const prisma = {
      driver: {
        findMany: vi.fn(async () => [
          { id: 'd-owed' },
          { id: 'd-owes' },
          { id: 'd-pending' },
        ]),
      },
      financialAccount: {
        findMany: vi.fn(async () => [
          { id: 'a1', ownerId: 'd-owed' },
          { id: 'a2', ownerId: 'd-owes' },
          { id: 'a3', ownerId: 'd-pending' },
        ]),
      },
      ledgerEntry: {
        groupBy: vi.fn(async () => [
          // balance = -SUM → +2500 for d-owed, -100 for d-owes, +800 for d-pending
          { accountId: 'a1', _sum: { amountCents: -2500 } },
          { accountId: 'a2', _sum: { amountCents: 100 } },
          { accountId: 'a3', _sum: { amountCents: -800 } },
        ]),
      },
      driverPayout: {
        findMany: vi.fn(async () => [{ driverId: 'd-pending' }]),
        create: vi.fn(async ({ data }) => ({
          id: 'payout-1',
          ...data,
          status: 'PENDING',
        })),
      },
      $transaction: vi.fn(async (fn: (tx: unknown) => unknown) => fn(prisma)),
    };
    const service = new FinanceService(
      prisma as never,
      { post } as never,
      { get: () => 'E_TRANSFER' } as never,
    );

    await expect(service.runPayouts(accountsUser)).resolves.toEqual({
      branchId: 'branch-1',
      method: 'E_TRANSFER',
      created: [
        {
          id: 'payout-1',
          driverId: 'd-owed',
          amountCents: 2500,
          status: 'PENDING',
        },
      ],
      skipped: [
        { driverId: 'd-pending', reason: 'PENDING_PAYOUT_EXISTS' },
      ],
    });

    expect(post).toHaveBeenCalledWith(
      prisma,
      expect.objectContaining({
        kind: 'SETTLEMENT',
        sourceType: 'DRIVER_PAYOUT',
        sourceId: 'payout-1',
        lines: [
          {
            accountKey: 'DRIVER_BALANCE:d-owed',
            type: 'DRIVER_BALANCE',
            ownerId: 'd-owed',
            amountCents: 2500,
          },
          {
            accountKey: 'BANK_CLEARING:branch-1',
            type: 'BANK_CLEARING',
            amountCents: -2500,
          },
        ],
      }),
    );
  });

  it('skips negative/zero balances and does not create a second PENDING on re-run', async () => {
    const post = vi.fn(async () => ({ id: 'txn-1' }));
    let pendingDriverIds: string[] = [];
    const prisma = {
      driver: {
        findMany: vi.fn(async () => [
          { id: 'd-owed' },
          { id: 'd-owes' },
          { id: 'd-zero' },
        ]),
      },
      financialAccount: {
        findMany: vi.fn(async () => [
          { id: 'a1', ownerId: 'd-owed' },
          { id: 'a2', ownerId: 'd-owes' },
          { id: 'a3', ownerId: 'd-zero' },
        ]),
      },
      ledgerEntry: {
        groupBy: vi.fn(async () => [
          { accountId: 'a1', _sum: { amountCents: -2500 } }, // +2500 owed
          { accountId: 'a2', _sum: { amountCents: 100 } }, // -100 owes
          // a3 missing → balance 0
        ]),
      },
      driverPayout: {
        findMany: vi.fn(async () =>
          pendingDriverIds.map((driverId) => ({ driverId })),
        ),
        create: vi.fn(async ({ data }) => {
          pendingDriverIds.push(data.driverId);
          return { id: 'payout-1', ...data, status: 'PENDING' };
        }),
      },
      $transaction: vi.fn(async (fn: (tx: unknown) => unknown) => fn(prisma)),
    };
    const service = new FinanceService(
      prisma as never,
      { post } as never,
      { get: () => 'E_TRANSFER' } as never,
    );

    const first = await service.runPayouts(accountsUser);
    expect(first.created).toEqual([
      {
        id: 'payout-1',
        driverId: 'd-owed',
        amountCents: 2500,
        status: 'PENDING',
      },
    ]);
    expect(first.skipped).toEqual([]);
    expect(post).toHaveBeenCalledTimes(1);

    const second = await service.runPayouts(accountsUser);
    expect(second.created).toEqual([]);
    expect(second.skipped).toEqual([
      { driverId: 'd-owed', reason: 'PENDING_PAYOUT_EXISTS' },
    ]);
    expect(prisma.driverPayout.create).toHaveBeenCalledTimes(1);
    expect(post).toHaveBeenCalledTimes(1);
  });

  it('rejects branch_admin from running payouts', async () => {
    const service = new FinanceService(
      {} as never,
      { post: vi.fn() } as never,
      { get: () => 'E_TRANSFER' } as never,
    );
    await expect(service.runPayouts(branchAdmin)).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });
});

describe('FinanceService.markPayoutSent / markPayoutFailed', () => {
  function harness(status = 'PENDING') {
    const payout = {
      id: 'payout-1',
      driverId: 'd1',
      branchId: 'branch-1',
      amountCents: 1000,
      status,
      method: 'E_TRANSFER',
      reference: null,
      requestedById: 'acct-1',
      requestedAt: new Date('2026-10-04T00:00:00.000Z'),
      sentAt: null,
      sentById: null,
      failureNote: null,
      driver: { id: 'd1', firstName: 'Sam', lastName: 'Singh' },
    };
    const prisma = {
      driverPayout: {
        findUnique: vi.fn(async () => payout),
        update: vi.fn(async ({ data }) => ({ ...payout, ...data })),
      },
    };
    const service = new FinanceService(
      prisma as never,
      { post: vi.fn() } as never,
      { get: () => 'E_TRANSFER' } as never,
    );
    return { service, prisma, payout };
  }

  it('marks sent with reference', async () => {
    const { service, prisma } = harness();
    await expect(
      service.markPayoutSent(accountsUser, 'payout-1', {
        reference: 'et-123',
      }),
    ).resolves.toMatchObject({
      status: 'SENT',
      reference: 'et-123',
      sentById: 'acct-1',
    });
    expect(prisma.driverPayout.update).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          status: 'SENT',
          reference: 'et-123',
        }),
      }),
    );
  });

  it('marks failed without reversing the ledger', async () => {
    const post = vi.fn();
    const { prisma } = harness();
    const service = new FinanceService(
      prisma as never,
      { post } as never,
      { get: () => 'E_TRANSFER' } as never,
    );
    await expect(
      service.markPayoutFailed(accountsUser, 'payout-1', {
        note: 'Wrong account',
      }),
    ).resolves.toMatchObject({
      status: 'FAILED',
      failureNote: 'Wrong account',
    });
    expect(post).not.toHaveBeenCalled();
  });

  it('rejects non-PENDING transitions', async () => {
    const { service } = harness('SENT');
    await expect(
      service.markPayoutSent(accountsUser, 'payout-1', {}),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it('requires branchId for super_admin run', async () => {
    const service = new FinanceService(
      {} as never,
      { post: vi.fn() } as never,
      { get: () => 'E_TRANSFER' } as never,
    );
    await expect(
      service.runPayouts({
        userId: 'sa',
        role: 'super_admin',
        branchId: null,
      }),
    ).rejects.toBeInstanceOf(BadRequestException);
  });
});
