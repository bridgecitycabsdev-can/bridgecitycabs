import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { AuthUser } from '../common/auth-user.js';
import type { PageQuery } from '../common/pagination.js';
import { normalizePage, paginate } from '../common/pagination.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { CreateVehicleMakeDto } from './dto/create-vehicle-make.dto.js';
import type { CreateVehicleModelDto } from './dto/create-vehicle-model.dto.js';
import type { CreateVehicleTypeDto } from './dto/create-vehicle-type.dto.js';
import type { UpdateVehicleMakeDto } from './dto/update-vehicle-make.dto.js';
import type { UpdateVehicleModelDto } from './dto/update-vehicle-model.dto.js';
import type { UpdateVehicleTypeDto } from './dto/update-vehicle-type.dto.js';

@Injectable()
export class CatalogService {
  constructor(private readonly prisma: PrismaService) {}

  listTypes(query: PageQuery) {
    return this.list(query, this.nameFilter(query.search), (args) =>
      this.prisma.$transaction([
        this.prisma.vehicleType.count({ where: args.where }),
        this.prisma.vehicleType.findMany(args),
      ]),
    );
  }

  async createType(dto: CreateVehicleTypeDto, user: AuthUser) {
    this.assertSuperAdmin(user);
    return this.write(() => this.prisma.vehicleType.create({ data: dto }));
  }

  async updateType(id: string, dto: UpdateVehicleTypeDto, user: AuthUser) {
    this.assertSuperAdmin(user);
    await this.requireType(id);
    return this.write(() =>
      this.prisma.vehicleType.update({ where: { id }, data: dto }),
    );
  }

  listMakes(query: PageQuery) {
    return this.list(query, this.nameFilter(query.search), (args) =>
      this.prisma.$transaction([
        this.prisma.vehicleMake.count({ where: args.where }),
        this.prisma.vehicleMake.findMany(args),
      ]),
    );
  }

  async createMake(dto: CreateVehicleMakeDto, user: AuthUser) {
    this.assertSuperAdmin(user);
    return this.write(() => this.prisma.vehicleMake.create({ data: dto }));
  }

  async updateMake(id: string, dto: UpdateVehicleMakeDto, user: AuthUser) {
    this.assertSuperAdmin(user);
    await this.requireMake(id);
    return this.write(() =>
      this.prisma.vehicleMake.update({ where: { id }, data: dto }),
    );
  }

  async listModels(makeId: string, query: PageQuery) {
    await this.requireMake(makeId);
    return this.list(
      query,
      { makeId, ...this.nameFilter(query.search) },
      (args) =>
        this.prisma.$transaction([
          this.prisma.vehicleModel.count({ where: args.where }),
          this.prisma.vehicleModel.findMany({
            ...args,
            include: { vehicleType: { select: { id: true, name: true } } },
          }),
        ]),
    );
  }

  async createModel(dto: CreateVehicleModelDto, user: AuthUser) {
    this.assertSuperAdmin(user);
    await this.requireMake(dto.makeId);
    await this.requireType(dto.vehicleTypeId);
    return this.write(() => this.prisma.vehicleModel.create({ data: dto }));
  }

  async updateModel(id: string, dto: UpdateVehicleModelDto, user: AuthUser) {
    this.assertSuperAdmin(user);
    await this.requireModel(id);
    if (dto.makeId) {
      await this.requireMake(dto.makeId);
    }
    if (dto.vehicleTypeId) {
      await this.requireType(dto.vehicleTypeId);
    }
    return this.write(() =>
      this.prisma.vehicleModel.update({ where: { id }, data: dto }),
    );
  }

  private list<T, W>(
    query: PageQuery,
    where: W,
    run: (args: {
      where: W;
      skip: number;
      take: number;
      orderBy: { name: 'asc' | 'desc' };
    }) => Promise<[number, T[]]>,
  ) {
    const { page, pageSize, skip, take } = normalizePage(query);
    return run({
      where,
      skip,
      take,
      orderBy: this.orderBy(query.sort),
    }).then(([total, data]) => paginate(data, total, { page, pageSize }));
  }

  private nameFilter(search?: string): {
    name?: { contains: string; mode: 'insensitive' };
  } {
    const term = search?.trim();
    if (!term) {
      return {};
    }
    return {
      name: { contains: term, mode: 'insensitive' },
    };
  }

  private orderBy(sort?: string): { name: 'asc' | 'desc' } {
    if (!sort) {
      return { name: 'asc' };
    }
    const [field, direction] = sort.split(':');
    if (field !== 'name' || (direction !== 'asc' && direction !== 'desc')) {
      throw new BadRequestException('sort must be name:asc or name:desc');
    }
    return { name: direction };
  }

  private assertSuperAdmin(user: AuthUser) {
    if (user.role !== 'super_admin') {
      throw new ForbiddenException();
    }
  }

  private async requireType(id: string) {
    const row = await this.prisma.vehicleType.findUnique({ where: { id } });
    if (!row) {
      throw new NotFoundException();
    }
    return row;
  }

  private async requireMake(id: string) {
    const row = await this.prisma.vehicleMake.findUnique({ where: { id } });
    if (!row) {
      throw new NotFoundException();
    }
    return row;
  }

  private async requireModel(id: string) {
    const row = await this.prisma.vehicleModel.findUnique({ where: { id } });
    if (!row) {
      throw new NotFoundException();
    }
    return row;
  }

  private async write<T>(action: () => Promise<T>): Promise<T> {
    try {
      return await action();
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException('A catalog entry with that name already exists');
      }
      throw error;
    }
  }
}
