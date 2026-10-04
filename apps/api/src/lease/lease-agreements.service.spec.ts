import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { LeaseAgreementsService } from './lease-agreements.service.js';

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

function row() {
  return {
    id: 'lease-1',
    driverId: 'driver-1',
    vehicleId: 'veh-1',
    weeklyAmountCents: 50000,
    startDate: new Date('2026-10-01T00:00:00.000Z'),
    endDate: null,
    active: true,
    createdById: 'admin-1',
    createdAt: new Date('2026-10-01T00:00:00.000Z'),
    driver: {
      id: 'driver-1',
      firstName: 'Sam',
      lastName: 'Singh',
      branchId: 'branch-1',
      branch: {
        id: 'branch-1',
        name: 'Lethbridge',
        timezone: 'America/Edmonton',
      },
    },
    vehicle: {
      id: 'veh-1',
      plateNumber: 'ABC123',
      unitNumber: '111',
      branchId: 'branch-1',
    },
  };
}

describe('LeaseAgreementsService', () => {
  it('creates a lease when driver and vehicle share the admin branch', async () => {
    const prisma = {
      driver: {
        findUnique: vi.fn(async () => ({ id: 'driver-1', branchId: 'branch-1' })),
      },
      vehicle: {
        findUnique: vi.fn(async () => ({ id: 'veh-1', branchId: 'branch-1' })),
      },
      leaseAgreement: {
        create: vi.fn(async () => row()),
      },
    };
    const service = new LeaseAgreementsService(prisma as never);

    await expect(
      service.create(
        {
          driverId: 'driver-1',
          vehicleId: 'veh-1',
          weeklyAmountCents: 50000,
          startDate: new Date('2026-10-01T00:00:00.000Z'),
        },
        admin,
      ),
    ).resolves.toMatchObject({
      id: 'lease-1',
      weeklyAmountCents: 50000,
      active: true,
    });
  });

  it('rejects dispatchers and cross-branch pairs', async () => {
    const prisma = {
      driver: {
        findUnique: vi.fn(async () => ({ id: 'driver-1', branchId: 'branch-1' })),
      },
      vehicle: {
        findUnique: vi.fn(async () => ({ id: 'veh-1', branchId: 'branch-2' })),
      },
      leaseAgreement: { create: vi.fn() },
    };
    const service = new LeaseAgreementsService(prisma as never);

    await expect(
      service.create(
        {
          driverId: 'driver-1',
          vehicleId: 'veh-1',
          weeklyAmountCents: 1,
          startDate: new Date(),
        },
        dispatcher,
      ),
    ).rejects.toBeInstanceOf(ForbiddenException);

    await expect(
      service.create(
        {
          driverId: 'driver-1',
          vehicleId: 'veh-1',
          weeklyAmountCents: 1,
          startDate: new Date(),
        },
        admin,
      ),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('updates active/amount and 404s unknown leases', async () => {
    const prisma = {
      leaseAgreement: {
        findFirst: vi
          .fn()
          .mockResolvedValueOnce(row())
          .mockResolvedValueOnce(null),
        update: vi.fn(async () => ({ ...row(), active: false, weeklyAmountCents: 40000 })),
      },
    };
    const service = new LeaseAgreementsService(prisma as never);

    await expect(
      service.update('lease-1', { active: false, weeklyAmountCents: 40000 }, admin),
    ).resolves.toMatchObject({ active: false, weeklyAmountCents: 40000 });

    await expect(service.findOne('missing', admin)).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });
});
