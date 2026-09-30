import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { AuthUser } from '../common/auth-user.js';
import { branchIdForCreate, branchWhere } from '../common/branch-scope.js';
import { normalizePage, paginate } from '../common/pagination.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { CreateVehicleDto } from './dto/create-vehicle.dto.js';
import type { UpdateVehicleDto } from './dto/update-vehicle.dto.js';
import type { VehicleQuery } from './dto/vehicle-query.dto.js';

const vehicleInclude = {
  model: {
    select: {
      id: true,
      name: true,
      make: { select: { id: true, name: true } },
    },
  },
  vehicleType: { select: { id: true, name: true } },
} satisfies Prisma.VehicleInclude;

const SORT_FIELDS = new Set(['createdAt', 'plateNumber', 'year', 'unitNumber']);

@Injectable()
export class VehiclesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(user: AuthUser, query: VehicleQuery) {
    const { page, pageSize, skip, take } = normalizePage(query);
    const scope = this.scope(user, query.branchId);
    if (!scope) {
      return paginate([], 0, { page, pageSize });
    }

    const where: Prisma.VehicleWhereInput = { ...scope };
    if (query.typeId) {
      where.vehicleTypeId = query.typeId;
    }
    if (query.active !== undefined) {
      where.active = query.active;
    }
    if (query.unassigned === true) {
      where.assignments = { none: { endedAt: null } };
    }
    const term = query.search?.trim();
    if (term) {
      where.OR = [
        { plateNumber: { contains: term, mode: 'insensitive' } },
        { unitNumber: { contains: term, mode: 'insensitive' } },
      ];
    }

    const [total, data] = await this.prisma.$transaction([
      this.prisma.vehicle.count({ where }),
      this.prisma.vehicle.findMany({
        where,
        skip,
        take,
        orderBy: this.orderBy(query.sort),
        include: vehicleInclude,
      }),
    ]);
    return paginate(data, total, { page, pageSize });
  }

  async findOne(id: string, user: AuthUser) {
    const scope = this.scope(user);
    if (!scope) {
      throw new NotFoundException();
    }
    const vehicle = await this.prisma.vehicle.findFirst({
      where: { id, ...scope },
      include: vehicleInclude,
    });
    if (!vehicle) {
      throw new NotFoundException();
    }
    return vehicle;
  }

  async create(dto: CreateVehicleDto, user: AuthUser) {
    const branchId = branchIdForCreate(user, dto.branchId);
    if (!branchId) {
      throw user.role === 'super_admin'
        ? new BadRequestException('branchId is required')
        : new ForbiddenException();
    }
    await this.requireBranch(branchId);
    const vehicleTypeId = await this.resolveType(dto.modelId, dto.vehicleTypeId);
    return this.write(() =>
      this.prisma.vehicle.create({
        data: {
          branchId,
          modelId: dto.modelId,
          vehicleTypeId,
          plateNumber: dto.plateNumber,
          unitNumber: dto.unitNumber,
          year: dto.year,
          color: dto.color,
          seats: dto.seats,
          active: dto.active,
        },
        include: vehicleInclude,
      }),
    );
  }

  async update(id: string, dto: UpdateVehicleDto, user: AuthUser) {
    const existing = await this.findOne(id, user);
    const modelId = dto.modelId ?? existing.modelId;
    const vehicleTypeId = await this.resolveType(modelId, dto.vehicleTypeId);

    let branchId = existing.branchId;
    if (user.role === 'super_admin' && dto.branchId) {
      await this.requireBranch(dto.branchId);
      branchId = dto.branchId;
    }

    return this.write(() =>
      this.prisma.$transaction(async (tx) => {
        if (dto.active === false) {
          await this.endOpenAssignments(tx, id);
        }
        return tx.vehicle.update({
          where: { id },
          data: {
            branchId,
            modelId,
            vehicleTypeId,
            plateNumber: dto.plateNumber,
            unitNumber: dto.unitNumber,
            year: dto.year,
            color: dto.color,
            seats: dto.seats,
            active: dto.active,
          },
          include: vehicleInclude,
        });
      }),
    );
  }

  async deactivate(id: string, user: AuthUser) {
    const scope = this.scope(user);
    if (!scope) {
      throw new NotFoundException();
    }
    return this.prisma.$transaction(async (tx) => {
      const vehicle = await tx.vehicle.findFirst({
        where: { id, ...scope },
      });
      if (!vehicle) {
        throw new NotFoundException();
      }
      await this.endOpenAssignments(tx, id);
      return tx.vehicle.update({
        where: { id },
        data: { active: false },
        include: vehicleInclude,
      });
    });
  }

  private scope(
    user: AuthUser,
    requestedBranchId?: string,
  ): Prisma.VehicleWhereInput | null {
    if (user.role !== 'super_admin' && !user.branchId) {
      return null;
    }
    return branchWhere(user, requestedBranchId);
  }

  private async resolveType(modelId: string, vehicleTypeId?: string) {
    const model = await this.prisma.vehicleModel.findUnique({
      where: { id: modelId },
    });
    if (!model) {
      throw new NotFoundException();
    }
    if (vehicleTypeId && vehicleTypeId !== model.vehicleTypeId) {
      throw new BadRequestException(
        'vehicleTypeId does not match the selected model',
      );
    }
    return model.vehicleTypeId;
  }

  private async requireBranch(id: string) {
    const branch = await this.prisma.branch.findUnique({ where: { id } });
    if (!branch) {
      throw new NotFoundException();
    }
    return branch;
  }

  private endOpenAssignments(
    tx: Prisma.TransactionClient,
    vehicleId: string,
  ) {
    return tx.driverVehicleAssignment.updateMany({
      where: { vehicleId, endedAt: null },
      data: { endedAt: new Date() },
    });
  }

  private orderBy(sort?: string): Prisma.VehicleOrderByWithRelationInput {
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
        'sort must be createdAt, plateNumber, year, or unitNumber with :asc or :desc',
      );
    }
    return { [field]: direction };
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
          'A vehicle with that plate already exists in this branch',
        );
      }
      throw error;
    }
  }
}
