import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { parsePhoneNumberFromString } from 'libphonenumber-js';
import type { AuthUser } from '../common/auth-user.js';
import { normalizePage, paginate, type PageQuery } from '../common/pagination.js';
import { normalizePhone } from '../common/phone.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { CreatePassengerDto } from './dto/create-passenger.dto.js';
import type { PassengerReasonDto } from './dto/passenger-reason.dto.js';
import type { UpdatePassengerDto } from './dto/update-passenger.dto.js';

const BLOCK_ROLES = ['super_admin', 'branch_admin', 'customer_care'] as const;

const SORT_FIELDS = new Set(['createdAt', 'firstName', 'lastName']);

const passengerInclude = {
  user: {
    select: { id: true, email: true, phone: true, isActive: true },
  },
} satisfies Prisma.PassengerInclude;

@Injectable()
export class PassengersService {
  constructor(private readonly prisma: PrismaService) {}

  create(dto: CreatePassengerDto) {
    const phone = normalizePhone(dto.phone);
    const email = dto.email?.toLowerCase();
    return this.write(() =>
      this.prisma.$transaction(async (tx) => {
        const role = await tx.role.findUnique({ where: { name: 'passenger' } });
        if (!role) {
          throw new InternalServerErrorException(
            'Passenger role is not configured',
          );
        }
        const account = await tx.user.create({
          data: {
            email,
            phone,
            passwordHash: null,
            roleId: role.id,
          },
        });
        return tx.passenger.create({
          data: {
            userId: account.id,
            firstName: dto.firstName,
            lastName: dto.lastName,
            phone,
            email,
          },
          include: passengerInclude,
        });
      }),
    );
  }

  async findAll(query: PageQuery) {
    const { page, pageSize, skip, take } = normalizePage(query);
    const where = this.searchFilter(query.search);
    const [total, data] = await this.prisma.$transaction([
      this.prisma.passenger.count({ where }),
      this.prisma.passenger.findMany({
        where,
        skip,
        take,
        orderBy: this.orderBy(query.sort),
        include: passengerInclude,
      }),
    ]);
    return paginate(data, total, { page, pageSize });
  }

  async findOne(id: string) {
    const passenger = await this.prisma.passenger.findUnique({
      where: { id },
      include: passengerInclude,
    });
    if (!passenger) {
      throw new NotFoundException();
    }
    return passenger;
  }

  async update(id: string, dto: UpdatePassengerDto) {
    const existing = await this.findOne(id);
    const phone = dto.phone ? normalizePhone(dto.phone) : undefined;
    const email = dto.email === undefined ? undefined : dto.email.toLowerCase();
    return this.write(() =>
      this.prisma.$transaction(async (tx) => {
        if (phone || email !== undefined) {
          await tx.user.update({
            where: { id: existing.userId },
            data: { phone, email },
          });
        }
        return tx.passenger.update({
          where: { id },
          data: {
            firstName: dto.firstName,
            lastName: dto.lastName,
            phone,
            email,
          },
          include: passengerInclude,
        });
      }),
    );
  }

  block(id: string, dto: PassengerReasonDto, user: AuthUser) {
    this.assertBlockRole(user);
    return this.setBlocked(id, true, dto.reason);
  }

  unblock(id: string, dto: PassengerReasonDto, user: AuthUser) {
    this.assertBlockRole(user);
    return this.setBlocked(id, false, dto.reason);
  }

  private async setBlocked(id: string, blocked: boolean, reason: string) {
    const existing = await this.findOne(id);
    if (existing.blocked === blocked) {
      throw new ConflictException(
        blocked ? 'Passenger is already blocked' : 'Passenger is not blocked',
      );
    }
    return this.prisma.passenger.update({
      where: { id },
      data: blocked
        ? {
            blocked: true,
            blockReason: reason,
            blockedAt: new Date(),
            unblockReason: null,
          }
        : {
            blocked: false,
            unblockReason: reason,
            blockedAt: null,
          },
      include: passengerInclude,
    });
  }

  private assertBlockRole(user: AuthUser) {
    if (!BLOCK_ROLES.includes(user.role as (typeof BLOCK_ROLES)[number])) {
      throw new ForbiddenException();
    }
  }

  private searchFilter(search?: string): Prisma.PassengerWhereInput {
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

  private orderBy(sort?: string): Prisma.PassengerOrderByWithRelationInput {
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
        'sort must be createdAt, firstName, or lastName with :asc or :desc',
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
          'A user with that phone or email already exists',
        );
      }
      throw error;
    }
  }
}
