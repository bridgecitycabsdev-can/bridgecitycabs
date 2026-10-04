import { ForbiddenException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { CorporateAccountGroupsService } from './corporate-account-groups.service.js';

const superAdmin = {
  userId: 'sa-1',
  role: 'super_admin',
  branchId: null,
};
const branchAdmin = {
  userId: 'ba-1',
  role: 'branch_admin',
  branchId: 'branch-1',
};

describe('CorporateAccountGroupsService', () => {
  it('lets super_admin create a group', async () => {
    const prisma = {
      corporateAccountGroup: {
        create: vi.fn(async () => ({
          id: 'g-1',
          name: 'West Franchise',
          active: true,
          createdAt: new Date('2026-10-04T00:00:00.000Z'),
          _count: { accounts: 0 },
        })),
      },
    };
    const service = new CorporateAccountGroupsService(prisma as never);
    await expect(
      service.create({ name: 'West Franchise' }, superAdmin),
    ).resolves.toMatchObject({
      id: 'g-1',
      name: 'West Franchise',
      accountCount: 0,
    });
  });

  it('rejects branch_admin', async () => {
    const service = new CorporateAccountGroupsService({} as never);
    await expect(
      service.create({ name: 'Nope' }, branchAdmin),
    ).rejects.toBeInstanceOf(ForbiddenException);
  });
});
