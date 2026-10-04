import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { CorporateAccountsService } from './corporate-accounts.service.js';

const admin = {
  userId: 'admin-1',
  role: 'branch_admin',
  branchId: 'branch-1',
};
const dispatcher = {
  userId: 'disp-1',
  role: 'dispatcher',
  branchId: 'branch-1',
};

function accountRow() {
  return {
    id: 'ca-1',
    legacyId: null,
    branchId: 'branch-1',
    groupId: null,
    name: 'Acme Corp',
    billingEmail: 'ap@acme.test',
    billingAddress: null,
    gstNumber: null,
    billingCycle: 'MONTHLY',
    creditLimitCents: 50_000,
    active: true,
    notes: null,
    createdById: 'admin-1',
    createdAt: new Date('2026-10-04T00:00:00.000Z'),
    group: null,
    _count: { contacts: 1, bookings: 0 },
  };
}

describe('CorporateAccountsService', () => {
  it('creates a branch-scoped account', async () => {
    const prisma = {
      corporateAccount: {
        create: vi.fn(async () => accountRow()),
      },
    };
    const service = new CorporateAccountsService(
      prisma as never,
      { getAccountReceivableBalance: vi.fn() } as never,
    );
    await expect(
      service.create({ name: 'Acme Corp', creditLimitCents: 50_000 }, admin),
    ).resolves.toMatchObject({
      id: 'ca-1',
      name: 'Acme Corp',
      creditLimitCents: 50_000,
    });
    expect(prisma.corporateAccount.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          branchId: 'branch-1',
          name: 'Acme Corp',
          createdById: 'admin-1',
        }),
      }),
    );
  });

  it('rejects dispatcher writes', async () => {
    const service = new CorporateAccountsService(
      {} as never,
      { getAccountReceivableBalance: vi.fn() } as never,
    );
    await expect(
      service.create({ name: 'Nope' }, dispatcher),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });

  it('searches active accounts by name for dispatch', async () => {
    const prisma = {
      corporateAccount: {
        findMany: vi.fn(async () => [accountRow()]),
      },
    };
    const service = new CorporateAccountsService(
      prisma as never,
      { getAccountReceivableBalance: vi.fn() } as never,
    );
    await expect(service.search(dispatcher, 'acme')).resolves.toHaveLength(1);
    expect(prisma.corporateAccount.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          branchId: 'branch-1',
          active: true,
          name: { contains: 'acme', mode: 'insensitive' },
        }),
        take: 25,
      }),
    );
  });

  it('returns AR balance from CorporateCreditService', async () => {
    const prisma = {
      corporateAccount: {
        findFirst: vi.fn(async () => accountRow()),
      },
    };
    const credit = {
      getAccountReceivableBalance: vi.fn(async () => 12_500),
    };
    const service = new CorporateAccountsService(
      prisma as never,
      credit as never,
    );
    await expect(service.balance('ca-1', dispatcher)).resolves.toEqual({
      accountId: 'ca-1',
      name: 'Acme Corp',
      currentCents: 12_500,
      creditLimitCents: 50_000,
      remainingCents: 37_500,
      unlimited: false,
    });
    expect(credit.getAccountReceivableBalance).toHaveBeenCalledWith('ca-1');
  });

  it('creates and searches contacts by name or phone', async () => {
    const contact = {
      id: 'cc-1',
      accountId: 'ca-1',
      name: 'Pat Buyer',
      phone: '+14035550100',
      email: null,
      active: true,
      createdAt: new Date('2026-10-04T00:00:00.000Z'),
    };
    const prisma = {
      corporateAccount: {
        findFirst: vi.fn(async () => accountRow()),
      },
      corporateAccountContact: {
        create: vi.fn(async () => contact),
        findMany: vi.fn(async () => [contact]),
      },
    };
    const service = new CorporateAccountsService(
      prisma as never,
      { getAccountReceivableBalance: vi.fn() } as never,
    );

    await expect(
      service.createContact(
        'ca-1',
        { name: 'Pat Buyer', phone: '+1 (403) 555-0100' },
        admin,
      ),
    ).resolves.toMatchObject({ phone: '+14035550100' });

    await service.searchContacts('ca-1', dispatcher, 'pat');
    expect(prisma.corporateAccountContact.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({
          accountId: 'ca-1',
          active: true,
        }),
      }),
    );
  });

  it('hides out-of-branch accounts', async () => {
    const prisma = {
      corporateAccount: { findFirst: vi.fn(async () => null) },
    };
    const service = new CorporateAccountsService(
      prisma as never,
      { getAccountReceivableBalance: vi.fn() } as never,
    );
    await expect(service.findOne('ca-x', admin)).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });
});
