import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import { normalizePage, paginate } from '../common/pagination.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { CreateFareRuleDto } from './dto/create-fare-rule.dto.js';
import type { FareRuleQuery } from './dto/fare-rule-query.dto.js';
import type { UpdateFareRuleDto } from './dto/update-fare-rule.dto.js';

const ruleInclude = {
  vehicleType: { select: { id: true, name: true } },
} satisfies Prisma.FareRuleInclude;

@Injectable()
export class FareRulesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(user: AuthUser, query: FareRuleQuery) {
    const { page, pageSize, skip, take } = normalizePage(query);
    const scope = this.scope(user, query.branchId);
    if (!scope) {
      return paginate([], 0, { page, pageSize });
    }

    const where: Prisma.FareRuleWhereInput = { ...scope };
    if (query.vehicleTypeId) where.vehicleTypeId = query.vehicleTypeId;
    if (query.zone) where.zone = query.zone;
    if (query.active !== undefined) where.active = query.active;
    const term = query.search?.trim();
    if (term) where.title = { contains: term, mode: 'insensitive' };

    const [total, data] = await this.prisma.$transaction([
      this.prisma.fareRule.count({ where }),
      this.prisma.fareRule.findMany({
        where,
        skip,
        take,
        orderBy: this.orderBy(query.sort),
        include: ruleInclude,
      }),
    ]);
    return paginate(data, total, { page, pageSize });
  }

  async findOne(id: string, user: AuthUser) {
    const scope = this.scope(user);
    if (!scope) throw new NotFoundException();
    const rule = await this.prisma.fareRule.findFirst({
      where: { id, ...scope },
      include: ruleInclude,
    });
    if (!rule) throw new NotFoundException();
    return rule;
  }

  async create(dto: CreateFareRuleDto, user: AuthUser) {
    this.assertWriter(user);
    const branch = await this.resolveBranch(user, dto.branchId);
    await this.requireVehicleType(dto.vehicleTypeId);
    return this.write(() =>
      this.prisma.fareRule.create({
        data: {
          branchId: branch.id,
          vehicleTypeId: dto.vehicleTypeId,
          zone: dto.zone,
          title: dto.title,
          baseFareCents: dto.baseFareCents,
          perKmCents: dto.perKmCents,
          perMinuteCents: dto.perMinuteCents ?? 0,
          minFareCents: dto.minFareCents ?? 0,
          active: dto.active,
        },
        include: ruleInclude,
      }),
    );
  }

  async update(id: string, dto: UpdateFareRuleDto, user: AuthUser) {
    this.assertWriter(user);
    const existing = await this.findOne(id, user);
    if (dto.vehicleTypeId) await this.requireVehicleType(dto.vehicleTypeId);

    let branchId = existing.branchId;
    if (user.role === 'super_admin' && dto.branchId) {
      branchId = (await this.resolveBranch(user, dto.branchId)).id;
    }

    return this.write(() =>
      this.prisma.fareRule.update({
        where: { id },
        data: {
          branchId,
          vehicleTypeId: dto.vehicleTypeId,
          zone: dto.zone,
          title: dto.title,
          baseFareCents: dto.baseFareCents,
          perKmCents: dto.perKmCents,
          perMinuteCents: dto.perMinuteCents,
          minFareCents: dto.minFareCents,
          active: dto.active,
        },
        include: ruleInclude,
      }),
    );
  }

  async remove(id: string, user: AuthUser) {
    this.assertWriter(user);
    await this.findOne(id, user);
    return this.prisma.fareRule.delete({ where: { id }, include: ruleInclude });
  }

  private scope(
    user: AuthUser,
    requestedBranchId?: string,
  ): { branchId?: string } | null {
    if (user.role !== 'super_admin' && !user.branchId) return null;
    return branchWhere(user, requestedBranchId);
  }

  private assertWriter(user: AuthUser) {
    if (user.role !== 'super_admin' && user.role !== 'branch_admin') {
      throw new ForbiddenException();
    }
  }

  private async resolveBranch(user: AuthUser, requested?: string) {
    if (user.role === 'super_admin') {
      if (!requested) throw new BadRequestException('branchId is required');
      return this.requireBranch(requested);
    }
    if (!user.branchId) throw new ForbiddenException();
    return this.requireBranch(user.branchId);
  }

  private async requireBranch(id: string) {
    const branch = await this.prisma.branch.findUnique({ where: { id } });
    if (!branch) throw new NotFoundException();
    return branch;
  }

  private async requireVehicleType(id: string) {
    const type = await this.prisma.vehicleType.findUnique({ where: { id } });
    if (!type) throw new NotFoundException();
    return type;
  }

  private orderBy(sort?: string): Prisma.FareRuleOrderByWithRelationInput {
    if (!sort) return { title: 'asc' };
    const [field, direction] = sort.split(':');
    if (field !== 'title' || (direction !== 'asc' && direction !== 'desc')) {
      throw new BadRequestException('sort must be title:asc or title:desc');
    }
    return { title: direction };
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
          'A fare rule already exists for this vehicle type and zone',
        );
      }
      throw error;
    }
  }
}
