import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { CreateLeaseAgreementDto } from './dto/create-lease-agreement.dto.js';
import type { LeaseAgreementQuery } from './dto/lease-agreement-query.dto.js';
import type { UpdateLeaseAgreementDto } from './dto/update-lease-agreement.dto.js';

const ADMIN_ROLES = ['super_admin', 'branch_admin'] as const;

const leaseInclude = {
  driver: {
    select: {
      id: true,
      firstName: true,
      lastName: true,
      branchId: true,
      branch: { select: { id: true, name: true, timezone: true } },
    },
  },
  vehicle: {
    select: {
      id: true,
      plateNumber: true,
      unitNumber: true,
      branchId: true,
    },
  },
} as const;

@Injectable()
export class LeaseAgreementsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateLeaseAgreementDto, user: AuthUser) {
    this.assertAdmin(user);
    const { driver, vehicle } = await this.requirePair(dto.driverId, dto.vehicleId);
    this.assertBranchAccess(user, driver.branchId);
    if (driver.branchId !== vehicle.branchId) {
      throw new BadRequestException('Driver and vehicle must share a branch');
    }
    if (dto.endDate && dto.endDate <= dto.startDate) {
      throw new BadRequestException('endDate must be after startDate');
    }

    const row = await this.prisma.leaseAgreement.create({
      data: {
        driverId: driver.id,
        vehicleId: vehicle.id,
        weeklyAmountCents: dto.weeklyAmountCents,
        startDate: dto.startDate,
        endDate: dto.endDate ?? null,
        active: dto.active ?? true,
        createdById: user.userId,
      },
      include: leaseInclude,
    });
    return this.present(row);
  }

  async findAll(user: AuthUser, query: LeaseAgreementQuery) {
    this.assertAdmin(user);
    const scope = branchWhere(user, query.branchId);
    const rows = await this.prisma.leaseAgreement.findMany({
      where: {
        ...(query.driverId ? { driverId: query.driverId } : {}),
        ...(query.vehicleId ? { vehicleId: query.vehicleId } : {}),
        ...(query.active === undefined ? {} : { active: query.active }),
        driver: { ...scope },
      },
      include: leaseInclude,
      orderBy: [{ active: 'desc' }, { createdAt: 'desc' }],
    });
    return rows.map((row) => this.present(row));
  }

  async findOne(id: string, user: AuthUser) {
    this.assertAdmin(user);
    const row = await this.requireLease(id, user);
    return this.present(row);
  }

  async update(id: string, dto: UpdateLeaseAgreementDto, user: AuthUser) {
    this.assertAdmin(user);
    const existing = await this.requireLease(id, user);
    const startDate = dto.startDate ?? existing.startDate;
    const endDate =
      dto.endDate === undefined ? existing.endDate : dto.endDate;
    if (endDate && endDate <= startDate) {
      throw new BadRequestException('endDate must be after startDate');
    }

    const row = await this.prisma.leaseAgreement.update({
      where: { id: existing.id },
      data: {
        ...(dto.weeklyAmountCents !== undefined
          ? { weeklyAmountCents: dto.weeklyAmountCents }
          : {}),
        ...(dto.startDate !== undefined ? { startDate: dto.startDate } : {}),
        ...(dto.endDate !== undefined ? { endDate: dto.endDate } : {}),
        ...(dto.active !== undefined ? { active: dto.active } : {}),
      },
      include: leaseInclude,
    });
    return this.present(row);
  }

  private async requireLease(id: string, user: AuthUser) {
    const scope = branchWhere(user);
    const row = await this.prisma.leaseAgreement.findFirst({
      where: { id, driver: { ...scope } },
      include: leaseInclude,
    });
    if (!row) throw new NotFoundException();
    return row;
  }

  private async requirePair(driverId: string, vehicleId: string) {
    const [driver, vehicle] = await Promise.all([
      this.prisma.driver.findUnique({
        where: { id: driverId },
        select: { id: true, branchId: true },
      }),
      this.prisma.vehicle.findUnique({
        where: { id: vehicleId },
        select: { id: true, branchId: true },
      }),
    ]);
    if (!driver || !vehicle) throw new NotFoundException();
    return { driver, vehicle };
  }

  private assertAdmin(user: AuthUser) {
    if (!ADMIN_ROLES.includes(user.role as (typeof ADMIN_ROLES)[number])) {
      throw new ForbiddenException();
    }
  }

  private assertBranchAccess(user: AuthUser, branchId: string) {
    if (user.role === 'super_admin') return;
    if (user.branchId !== branchId) throw new ForbiddenException();
  }

  private present(row: {
    id: string;
    driverId: string;
    vehicleId: string;
    weeklyAmountCents: number;
    startDate: Date;
    endDate: Date | null;
    active: boolean;
    createdById: string | null;
    createdAt: Date;
    driver: {
      id: string;
      firstName: string;
      lastName: string;
      branchId: string;
      branch: { id: string; name: string; timezone: string };
    };
    vehicle: {
      id: string;
      plateNumber: string;
      unitNumber: string | null;
      branchId: string;
    };
  }) {
    return {
      id: row.id,
      driverId: row.driverId,
      vehicleId: row.vehicleId,
      weeklyAmountCents: row.weeklyAmountCents,
      startDate: row.startDate.toISOString(),
      endDate: row.endDate?.toISOString() ?? null,
      active: row.active,
      createdById: row.createdById,
      createdAt: row.createdAt.toISOString(),
      driver: {
        id: row.driver.id,
        firstName: row.driver.firstName,
        lastName: row.driver.lastName,
        branchId: row.driver.branchId,
        branch: row.driver.branch,
      },
      vehicle: {
        id: row.vehicle.id,
        plateNumber: row.vehicle.plateNumber,
        unitNumber: row.vehicle.unitNumber,
        branchId: row.vehicle.branchId,
      },
    };
  }
}
