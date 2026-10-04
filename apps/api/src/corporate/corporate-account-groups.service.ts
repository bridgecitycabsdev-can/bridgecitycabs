import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { CreateCorporateAccountGroupDto } from './dto/create-corporate-account-group.dto.js';
import type { UpdateCorporateAccountGroupDto } from './dto/update-corporate-account-group.dto.js';

@Injectable()
export class CorporateAccountGroupsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(dto: CreateCorporateAccountGroupDto, user: AuthUser) {
    this.assertSuper(user);
    const row = await this.prisma.corporateAccountGroup.create({
      data: {
        name: dto.name.trim(),
        active: dto.active ?? true,
      },
      include: { _count: { select: { accounts: true } } },
    });
    return this.present(row);
  }

  async findAll(user: AuthUser) {
    this.assertSuper(user);
    const rows = await this.prisma.corporateAccountGroup.findMany({
      include: { _count: { select: { accounts: true } } },
      orderBy: [{ active: 'desc' }, { name: 'asc' }],
    });
    return rows.map((row) => this.present(row));
  }

  async findOne(id: string, user: AuthUser) {
    this.assertSuper(user);
    const row = await this.prisma.corporateAccountGroup.findUnique({
      where: { id },
      include: { _count: { select: { accounts: true } } },
    });
    if (!row) throw new NotFoundException();
    return this.present(row);
  }

  async update(id: string, dto: UpdateCorporateAccountGroupDto, user: AuthUser) {
    this.assertSuper(user);
    const existing = await this.prisma.corporateAccountGroup.findUnique({
      where: { id },
    });
    if (!existing) throw new NotFoundException();

    const row = await this.prisma.corporateAccountGroup.update({
      where: { id },
      data: {
        ...(dto.name !== undefined ? { name: dto.name.trim() } : {}),
        ...(dto.active !== undefined ? { active: dto.active } : {}),
      },
      include: { _count: { select: { accounts: true } } },
    });
    return this.present(row);
  }

  private present(row: {
    id: string;
    name: string;
    active: boolean;
    createdAt: Date;
    _count: { accounts: number };
  }) {
    return {
      id: row.id,
      name: row.name,
      active: row.active,
      createdAt: row.createdAt.toISOString(),
      accountCount: row._count.accounts,
    };
  }

  private assertSuper(user: AuthUser) {
    if (user.role !== 'super_admin') throw new ForbiddenException();
  }
}
