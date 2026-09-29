import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { CreateBranchDto } from './dto/create-branch.dto.js';
import { UpdateBranchDto } from './dto/update-branch.dto.js';

@Injectable()
export class BranchesService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateBranchDto, user: AuthUser) {
    if (user.role !== 'super_admin') {
      throw new ForbiddenException();
    }
    return this.prisma.branch.create({ data: dto });
  }

  async findAll(user: AuthUser) {
    if (user.role === 'super_admin') {
      return this.prisma.branch.findMany();
    }
    if (!user.branchId) {
      return [];
    }
    return this.prisma.branch.findMany({ where: { id: user.branchId } });
  }

  async findOne(id: string, user: AuthUser) {
    if (user.role !== 'super_admin' && user.branchId !== id) {
      throw new ForbiddenException();
    }
    const branch = await this.prisma.branch.findUnique({ where: { id } });
    if (!branch) {
      throw new NotFoundException();
    }
    return branch;
  }

  async update(id: string, dto: UpdateBranchDto, user: AuthUser) {
    if (user.role !== 'super_admin' && user.role !== 'branch_admin') {
      throw new ForbiddenException();
    }
    await this.findOne(id, user);
    return this.prisma.branch.update({ where: { id }, data: dto });
  }

  async deactivate(id: string, user: AuthUser) {
    if (user.role !== 'super_admin') {
      throw new ForbiddenException();
    }
    await this.findOne(id, user);
    return this.prisma.branch.update({
      where: { id },
      data: { active: false },
    });
  }
}
