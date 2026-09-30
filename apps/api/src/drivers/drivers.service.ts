import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { parsePhoneNumberFromString } from 'libphonenumber-js';
import type { AuthUser } from '../common/auth-user.js';
import { branchIdForCreate, branchWhere } from '../common/branch-scope.js';
import { normalizePage, paginate } from '../common/pagination.js';
import { normalizePhone } from '../common/phone.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { assertDriverTransition } from './driver-status.js';
import type { CreateDriverDto } from './dto/create-driver.dto.js';
import type { DriverOptionsQuery } from './dto/driver-options-query.dto.js';
import type { DriverQuery } from './dto/driver-query.dto.js';
import type { SuspendDriverDto } from './dto/suspend-driver.dto.js';
import type { UpdateDriverDto } from './dto/update-driver.dto.js';

const APPROVER_ROLES = ['super_admin', 'branch_admin', 'hr_admin'] as const;

const SORT_FIELDS = new Set(['createdAt', 'firstName', 'lastName', 'status']);

const userSelect = {
  id: true,
  email: true,
  phone: true,
  isActive: true,
} satisfies Prisma.UserSelect;

const listInclude = {
  user: { select: userSelect },
} satisfies Prisma.DriverInclude;

const detailInclude = {
  user: { select: userSelect },
  documents: {
    include: {
      documentType: {
        select: { id: true, code: true, name: true, required: true, hasExpiry: true },
      },
    },
    orderBy: { createdAt: 'desc' as const },
  },
  assignments: {
    where: { endedAt: null },
    orderBy: { startedAt: 'desc' as const },
    take: 1,
    include: {
      vehicle: {
        select: {
          id: true,
          plateNumber: true,
          unitNumber: true,
          year: true,
          active: true,
        },
      },
    },
  },
} satisfies Prisma.DriverInclude;

@Injectable()
export class DriversService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateDriverDto, user: AuthUser) {
    const phone = normalizePhone(dto.phone);
    const branchId = this.branchForCreate(user, dto.branchId);
    await this.requireBranch(branchId);
    return this.write(() =>
      this.prisma.$transaction(async (tx) => {
        const role = await tx.role.findUnique({ where: { name: 'driver' } });
        if (!role) {
          throw new InternalServerErrorException('Driver role is not configured');
        }
        const account = await tx.user.create({
          data: {
            email: dto.email?.toLowerCase(),
            phone,
            passwordHash: null,
            branchId,
            roleId: role.id,
          },
        });
        return tx.driver.create({
          data: {
            userId: account.id,
            branchId,
            firstName: dto.firstName,
            lastName: dto.lastName,
            phone,
            status: 'PENDING_DOCUMENTS',
          },
          include: listInclude,
        });
      }),
    );
  }

  async findAll(user: AuthUser, query: DriverQuery) {
    const { page, pageSize, skip, take } = normalizePage(query);
    const scope = this.scope(user, query.branchId);
    if (!scope) {
      return paginate([], 0, { page, pageSize });
    }
    const where: Prisma.DriverWhereInput = {
      ...scope,
      ...this.searchFilter(query.search),
    };
    if (query.status) {
      where.status = query.status;
    }
    const [total, data] = await this.prisma.$transaction([
      this.prisma.driver.count({ where }),
      this.prisma.driver.findMany({
        where,
        skip,
        take,
        orderBy: this.orderBy(query.sort),
        include: listInclude,
      }),
    ]);
    return paginate(data, total, { page, pageSize });
  }

  async options(user: AuthUser, query: DriverOptionsQuery) {
    const scope = this.scope(user, query.branchId);
    if (!scope) {
      return [];
    }
    const where: Prisma.DriverWhereInput = { ...scope };
    if (query.withoutVehicle === true) {
      where.assignments = { none: { endedAt: null } };
    }
    const rows = await this.prisma.driver.findMany({
      where,
      orderBy: [{ lastName: 'asc' }, { firstName: 'asc' }],
      select: { id: true, firstName: true, lastName: true },
    });
    return rows.map((row) => ({
      id: row.id,
      name: `${row.firstName} ${row.lastName}`,
    }));
  }

  async findOne(id: string, user: AuthUser) {
    const driver = await this.findScoped(id, user);
    return this.presentDetail(driver);
  }

  async update(id: string, dto: UpdateDriverDto, user: AuthUser) {
    const existing = await this.findScoped(id, user);
    const phone = dto.phone ? normalizePhone(dto.phone) : undefined;
    let branchId = existing.branchId;
    if (user.role === 'super_admin' && dto.branchId) {
      await this.requireBranch(dto.branchId);
      branchId = dto.branchId;
    }
    return this.write(() =>
      this.prisma.$transaction(async (tx) => {
        if (phone || dto.email !== undefined || branchId !== existing.branchId) {
          await tx.user.update({
            where: { id: existing.userId },
            data: {
              phone,
              email:
                dto.email === undefined ? undefined : dto.email.toLowerCase(),
              branchId,
            },
          });
        }
        return tx.driver.update({
          where: { id },
          data: {
            firstName: dto.firstName,
            lastName: dto.lastName,
            phone,
            branchId,
          },
          include: listInclude,
        });
      }),
    );
  }

  async approve(id: string, user: AuthUser) {
    this.assertApprover(user);
    return this.prisma.$transaction(async (tx) => {
      const driver = await this.findScoped(id, user, tx);
      assertDriverTransition(driver.status, 'APPROVED');
      const required = await tx.documentType.findMany({
        where: { owner: 'DRIVER', required: true },
        orderBy: { code: 'asc' },
      });
      const approved = await tx.document.findMany({
        where: {
          driverId: id,
          status: 'APPROVED',
          OR: [{ expiresAt: null }, { expiresAt: { gt: new Date() } }],
        },
      });
      const missing = required.filter(
        (documentType) =>
          !approved.some((document) => document.documentTypeId === documentType.id),
      );
      if (missing.length) {
        throw new UnprocessableEntityException({
          message: 'Missing documents',
          missing: missing.map((documentType) => documentType.code),
        });
      }
      return tx.driver.update({
        where: { id },
        data: {
          status: 'APPROVED',
          approvedAt: new Date(),
          approvedById: user.userId,
          suspensionReason: null,
        },
        include: listInclude,
      });
    });
  }

  async suspend(id: string, dto: SuspendDriverDto, user: AuthUser) {
    return this.prisma.$transaction(async (tx) => {
      const driver = await this.findScoped(id, user, tx);
      assertDriverTransition(driver.status, 'SUSPENDED');
      return tx.driver.update({
        where: { id },
        data: {
          status: 'SUSPENDED',
          suspensionReason: dto.reason,
        },
        include: listInclude,
      });
    });
  }

  private assertApprover(user: AuthUser) {
    if (!APPROVER_ROLES.includes(user.role as (typeof APPROVER_ROLES)[number])) {
      throw new ForbiddenException();
    }
  }

  private branchForCreate(user: AuthUser, requestedBranchId?: string) {
    const branchId = branchIdForCreate(user, requestedBranchId);
    if (!branchId) {
      throw user.role === 'super_admin'
        ? new BadRequestException('branchId is required')
        : new ForbiddenException();
    }
    return branchId;
  }

  private scope(
    user: AuthUser,
    requestedBranchId?: string,
  ): Prisma.DriverWhereInput | null {
    if (user.role !== 'super_admin' && !user.branchId) {
      return null;
    }
    return branchWhere(user, requestedBranchId);
  }

  private async findScoped(
    id: string,
    user: AuthUser,
    tx: Prisma.TransactionClient | PrismaService = this.prisma,
  ) {
    const scope = this.scope(user);
    if (!scope) {
      throw new NotFoundException();
    }
    const driver = await tx.driver.findFirst({
      where: { id, ...scope },
      include: detailInclude,
    });
    if (!driver) {
      throw new NotFoundException();
    }
    return driver;
  }

  private presentDetail(
    driver: Prisma.DriverGetPayload<{ include: typeof detailInclude }>,
  ) {
    const { assignments, ...profile } = driver;
    return {
      ...profile,
      currentVehicle: assignments[0]?.vehicle ?? null,
    };
  }

  private searchFilter(search?: string): Prisma.DriverWhereInput {
    const term = search?.trim();
    if (!term) {
      return {};
    }
    const parsed = parsePhoneNumberFromString(term, 'CA');
    const phone = parsed?.isValid() ? parsed.number : undefined;
    const parts = term.split(/\s+/).filter(Boolean);
    if (parts.length > 1) {
      return {
        AND: parts.map((part) => ({
          OR: [
            { firstName: { contains: part, mode: 'insensitive' as const } },
            { lastName: { contains: part, mode: 'insensitive' as const } },
          ],
        })),
      };
    }
    return {
      OR: [
        { firstName: { contains: term, mode: 'insensitive' } },
        { lastName: { contains: term, mode: 'insensitive' } },
        { phone: { contains: term } },
        ...(phone ? [{ phone }] : []),
      ],
    };
  }

  private orderBy(sort?: string): Prisma.DriverOrderByWithRelationInput {
    if (!sort) {
      return { createdAt: 'desc' };
    }
    const [field, direction] = sort.split(':');
    if (
      !field ||
      !SORT_FIELDS.has(field) ||
      (direction !== 'asc' && direction !== 'desc')
    ) {
      throw new BadRequestException(
        'sort must be createdAt, firstName, lastName, or status with :asc or :desc',
      );
    }
    return { [field]: direction };
  }

  private async requireBranch(id: string) {
    const branch = await this.prisma.branch.findUnique({ where: { id } });
    if (!branch) {
      throw new NotFoundException();
    }
    return branch;
  }

  private async write<T>(action: () => Promise<T>): Promise<T> {
    try {
      return await action();
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException(
          'A user with that phone or email already exists',
        );
      }
      throw error;
    }
  }
}
