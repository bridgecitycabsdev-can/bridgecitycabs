import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { branchIdForCreate, branchWhere } from '../common/branch-scope.js';
import { normalizePhone } from '../common/phone.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { CorporateCreditService } from './corporate-credit.service.js';
import type { CorporateAccountQuery } from './dto/corporate-account-query.dto.js';
import type { CreateCorporateAccountDto } from './dto/create-corporate-account.dto.js';
import type { CreateCorporateContactDto } from './dto/create-corporate-contact.dto.js';
import type { UpdateCorporateAccountDto } from './dto/update-corporate-account.dto.js';
import type { UpdateCorporateContactDto } from './dto/update-corporate-contact.dto.js';

const WRITE_ROLES = ['super_admin', 'branch_admin'] as const;

const accountInclude = {
  group: { select: { id: true, name: true, active: true } },
  _count: { select: { contacts: true, bookings: true } },
} as const;

@Injectable()
export class CorporateAccountsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly credit: CorporateCreditService,
  ) {}

  async create(dto: CreateCorporateAccountDto, user: AuthUser) {
    this.assertWrite(user);
    const branchId = branchIdForCreate(user, dto.branchId);
    if (!branchId) throw new BadRequestException('branchId is required');
    this.assertBranchAccess(user, branchId);
    if (dto.groupId) await this.requireGroup(dto.groupId);

    const row = await this.prisma.corporateAccount.create({
      data: {
        branchId,
        groupId: dto.groupId,
        name: dto.name.trim(),
        billingEmail: dto.billingEmail?.trim(),
        billingAddress: dto.billingAddress?.trim(),
        gstNumber: dto.gstNumber?.trim(),
        billingCycle: dto.billingCycle,
        creditLimitCents: dto.creditLimitCents ?? 0,
        active: dto.active ?? true,
        notes: dto.notes?.trim(),
        createdById: user.userId,
      },
      include: accountInclude,
    });
    return this.presentAccount(row);
  }

  async findAll(user: AuthUser, query: CorporateAccountQuery) {
    this.assertStaff(user);
    const scope = branchWhere(user, query.branchId);
    const rows = await this.prisma.corporateAccount.findMany({
      where: {
        ...scope,
        ...(query.groupId ? { groupId: query.groupId } : {}),
        ...(query.active === undefined ? {} : { active: query.active }),
      },
      include: accountInclude,
      orderBy: [{ active: 'desc' }, { name: 'asc' }],
    });
    return rows.map((row) => this.presentAccount(row));
  }

  async search(user: AuthUser, q?: string) {
    this.assertStaff(user);
    const term = q?.trim();
    if (!term) return [];
    const scope = branchWhere(user);
    const rows = await this.prisma.corporateAccount.findMany({
      where: {
        ...scope,
        active: true,
        name: { contains: term, mode: 'insensitive' },
      },
      include: accountInclude,
      orderBy: { name: 'asc' },
      take: 25,
    });
    return rows.map((row) => this.presentAccount(row));
  }

  async findOne(id: string, user: AuthUser) {
    this.assertStaff(user);
    return this.presentAccount(await this.requireAccount(id, user));
  }

  async balance(id: string, user: AuthUser) {
    this.assertStaff(user);
    const account = await this.requireAccount(id, user);
    const currentCents = await this.credit.getAccountReceivableBalance(
      account.id,
    );
    return {
      accountId: account.id,
      name: account.name,
      currentCents,
      creditLimitCents: account.creditLimitCents,
      remainingCents:
        account.creditLimitCents > 0
          ? Math.max(0, account.creditLimitCents - currentCents)
          : null,
      unlimited: account.creditLimitCents === 0,
    };
  }

  async update(id: string, dto: UpdateCorporateAccountDto, user: AuthUser) {
    this.assertWrite(user);
    const existing = await this.requireAccount(id, user);
    if (dto.groupId) await this.requireGroup(dto.groupId);

    const row = await this.prisma.corporateAccount.update({
      where: { id: existing.id },
      data: {
        ...(dto.groupId !== undefined ? { groupId: dto.groupId } : {}),
        ...(dto.name !== undefined ? { name: dto.name.trim() } : {}),
        ...(dto.billingEmail !== undefined
          ? { billingEmail: dto.billingEmail?.trim() ?? null }
          : {}),
        ...(dto.billingAddress !== undefined
          ? { billingAddress: dto.billingAddress?.trim() ?? null }
          : {}),
        ...(dto.gstNumber !== undefined
          ? { gstNumber: dto.gstNumber?.trim() ?? null }
          : {}),
        ...(dto.billingCycle !== undefined
          ? { billingCycle: dto.billingCycle }
          : {}),
        ...(dto.creditLimitCents !== undefined
          ? { creditLimitCents: dto.creditLimitCents }
          : {}),
        ...(dto.active !== undefined ? { active: dto.active } : {}),
        ...(dto.notes !== undefined
          ? { notes: dto.notes?.trim() ?? null }
          : {}),
      },
      include: accountInclude,
    });
    return this.presentAccount(row);
  }

  async createContact(
    accountId: string,
    dto: CreateCorporateContactDto,
    user: AuthUser,
  ) {
    this.assertWrite(user);
    const account = await this.requireAccount(accountId, user);
    const row = await this.prisma.corporateAccountContact.create({
      data: {
        accountId: account.id,
        name: dto.name.trim(),
        phone: normalizePhone(dto.phone),
        email: dto.email?.trim(),
        active: dto.active ?? true,
      },
    });
    return this.presentContact(row);
  }

  async listContacts(accountId: string, user: AuthUser) {
    this.assertStaff(user);
    await this.requireAccount(accountId, user);
    const rows = await this.prisma.corporateAccountContact.findMany({
      where: { accountId },
      orderBy: [{ active: 'desc' }, { name: 'asc' }],
    });
    return rows.map((row) => this.presentContact(row));
  }

  async searchContacts(accountId: string, user: AuthUser, q?: string) {
    this.assertStaff(user);
    await this.requireAccount(accountId, user);
    const term = q?.trim();
    if (!term) return [];
    let phoneTerm: string | undefined;
    try {
      phoneTerm = normalizePhone(term);
    } catch {
      phoneTerm = undefined;
    }
    const rows = await this.prisma.corporateAccountContact.findMany({
      where: {
        accountId,
        active: true,
        OR: [
          { name: { contains: term, mode: 'insensitive' } },
          ...(phoneTerm
            ? [{ phone: { contains: phoneTerm } }]
            : [{ phone: { contains: term } }]),
        ],
      },
      orderBy: { name: 'asc' },
      take: 25,
    });
    return rows.map((row) => this.presentContact(row));
  }

  async updateContact(
    accountId: string,
    contactId: string,
    dto: UpdateCorporateContactDto,
    user: AuthUser,
  ) {
    this.assertWrite(user);
    await this.requireAccount(accountId, user);
    const existing = await this.prisma.corporateAccountContact.findFirst({
      where: { id: contactId, accountId },
    });
    if (!existing) throw new NotFoundException();

    const row = await this.prisma.corporateAccountContact.update({
      where: { id: existing.id },
      data: {
        ...(dto.name !== undefined ? { name: dto.name.trim() } : {}),
        ...(dto.phone !== undefined
          ? { phone: normalizePhone(dto.phone) }
          : {}),
        ...(dto.email !== undefined
          ? { email: dto.email?.trim() ?? null }
          : {}),
        ...(dto.active !== undefined ? { active: dto.active } : {}),
      },
    });
    return this.presentContact(row);
  }

  private async requireAccount(id: string, user: AuthUser) {
    const scope = branchWhere(user);
    const row = await this.prisma.corporateAccount.findFirst({
      where: { id, ...scope },
      include: accountInclude,
    });
    if (!row) throw new NotFoundException();
    return row;
  }

  private async requireGroup(id: string) {
    const group = await this.prisma.corporateAccountGroup.findUnique({
      where: { id },
    });
    if (!group) throw new NotFoundException('Corporate account group not found');
    return group;
  }

  private presentAccount(
    row: Awaited<ReturnType<CorporateAccountsService['requireAccount']>>,
  ) {
    return {
      id: row.id,
      legacyId: row.legacyId,
      branchId: row.branchId,
      groupId: row.groupId,
      group: row.group,
      name: row.name,
      billingEmail: row.billingEmail,
      billingAddress: row.billingAddress,
      gstNumber: row.gstNumber,
      billingCycle: row.billingCycle,
      creditLimitCents: row.creditLimitCents,
      active: row.active,
      notes: row.notes,
      createdById: row.createdById,
      createdAt: row.createdAt.toISOString(),
      contactCount: row._count.contacts,
      bookingCount: row._count.bookings,
    };
  }

  private presentContact(row: {
    id: string;
    accountId: string;
    name: string;
    phone: string;
    email: string | null;
    active: boolean;
    createdAt: Date;
  }) {
    return {
      id: row.id,
      accountId: row.accountId,
      name: row.name,
      phone: row.phone,
      email: row.email,
      active: row.active,
      createdAt: row.createdAt.toISOString(),
    };
  }

  private assertStaff(user: AuthUser) {
    if (!(STAFF_ROLES as readonly string[]).includes(user.role)) {
      throw new ForbiddenException();
    }
  }

  private assertWrite(user: AuthUser) {
    if (!(WRITE_ROLES as readonly string[]).includes(user.role)) {
      throw new ForbiddenException();
    }
  }

  private assertBranchAccess(user: AuthUser, branchId: string) {
    if (user.role === 'super_admin') return;
    if (!user.branchId || user.branchId !== branchId) {
      throw new ForbiddenException();
    }
  }
}
