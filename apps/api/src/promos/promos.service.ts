import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import { ApiCode } from '../common/api-code.js';
import type { AuthUser } from '../common/auth-user.js';
import { branchIdForCreate, branchWhere } from '../common/branch-scope.js';
import {
  normalizePage,
  paginate,
  type PageQuery,
} from '../common/pagination.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { applyPromo } from './apply-promo.js';
import type { CreatePromoCodeDto } from './dto/create-promo-code.dto.js';
import type { UpdatePromoCodeDto } from './dto/update-promo-code.dto.js';

const WRITE_ROLES = ['super_admin', 'branch_admin'] as const;

type Tx = Prisma.TransactionClient;

@Injectable()
export class PromosService {
  constructor(private readonly prisma: PrismaService) {}

  async create(user: AuthUser, dto: CreatePromoCodeDto) {
    this.assertWrite(user);
    this.assertTypeValues(dto.type, dto.valueBps, dto.valueCents);
    const branchId =
      dto.branchId === undefined
        ? user.role === 'super_admin'
          ? null
          : branchIdForCreate(user, undefined)
        : branchIdForCreate(user, dto.branchId);
    if (user.role !== 'super_admin' && !branchId) {
      throw new BadRequestException('branchId is required');
    }
    if (branchId) this.assertBranch(user, branchId);

    const row = await this.prisma.promoCode.create({
      data: {
        code: dto.code.trim().toUpperCase(),
        branchId,
        type: dto.type,
        valueBps: dto.type === 'PERCENT' ? dto.valueBps : null,
        valueCents: dto.type === 'FIXED' ? dto.valueCents : null,
        maxDiscountCents: dto.maxDiscountCents,
        minSubtotalCents: dto.minSubtotalCents ?? 0,
        usageLimitTotal: dto.usageLimitTotal,
        usageLimitPerPassenger:
          dto.usageLimitPerPassenger === undefined
            ? 1
            : dto.usageLimitPerPassenger,
        startAt: dto.startAt,
        endAt: dto.endAt,
        active: dto.active ?? true,
        createdById: user.userId,
      },
    });
    return this.present(row);
  }

  async list(
    user: AuthUser,
    query: Partial<Pick<PageQuery, 'page' | 'pageSize'>> = {},
  ) {
    this.assertWrite(user);
    const scope = branchWhere(user);
    const { page, pageSize, skip, take } = normalizePage(query);
    const where = {
      ...(scope.branchId
        ? {
            OR: [{ branchId: scope.branchId }, { branchId: null }],
          }
        : {}),
    };
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.promoCode.count({ where }),
      this.prisma.promoCode.findMany({
        where,
        orderBy: [{ active: 'desc' }, { createdAt: 'desc' }],
        skip,
        take,
      }),
    ]);
    return paginate(
      rows.map((row) => this.present(row)),
      total,
      { page, pageSize },
    );
  }

  async update(user: AuthUser, id: string, dto: UpdatePromoCodeDto) {
    this.assertWrite(user);
    const existing = await this.requireScoped(user, id);
    const type = dto.type ?? existing.type;
    const valueBps =
      dto.valueBps !== undefined ? dto.valueBps : existing.valueBps;
    const valueCents =
      dto.valueCents !== undefined ? dto.valueCents : existing.valueCents;
    this.assertTypeValues(type, valueBps, valueCents);

    let branchId = existing.branchId;
    if (dto.branchId !== undefined) {
      if (dto.branchId === null) {
        if (user.role !== 'super_admin') throw new ForbiddenException();
        branchId = null;
      } else {
        const next = branchIdForCreate(user, dto.branchId);
        if (!next) throw new BadRequestException('branchId is required');
        this.assertBranch(user, next);
        branchId = next;
      }
    }

    const row = await this.prisma.promoCode.update({
      where: { id: existing.id },
      data: {
        branchId,
        type,
        valueBps: type === 'PERCENT' ? valueBps : null,
        valueCents: type === 'FIXED' ? valueCents : null,
        maxDiscountCents:
          dto.maxDiscountCents !== undefined
            ? dto.maxDiscountCents
            : undefined,
        minSubtotalCents: dto.minSubtotalCents,
        usageLimitTotal:
          dto.usageLimitTotal !== undefined ? dto.usageLimitTotal : undefined,
        usageLimitPerPassenger:
          dto.usageLimitPerPassenger !== undefined
            ? dto.usageLimitPerPassenger
            : undefined,
        startAt: dto.startAt !== undefined ? dto.startAt : undefined,
        endAt: dto.endAt !== undefined ? dto.endAt : undefined,
        active: dto.active,
      },
    });
    return this.present(row);
  }

  async preview(user: AuthUser, code: string, subtotalCents: number) {
    this.assertWrite(user);
    const promo = await this.prisma.promoCode.findUnique({
      where: { code: code.trim().toUpperCase() },
    });
    if (!promo) throw new NotFoundException();
    if (user.role !== 'super_admin') {
      if (promo.branchId && promo.branchId !== user.branchId) {
        throw new NotFoundException();
      }
    }
    const applied = applyPromo(subtotalCents, promo);
    return {
      ...this.present(promo),
      subtotalCents,
      discountCents: applied.discountCents,
      netSubtotalCents: applied.netSubtotalCents,
    };
  }

  /**
   * Atomic redeem inside the booking-create transaction. Uses conditional
   * UPDATE for the global cap (same pattern as optimistic locks).
   */
  async redeem(
    tx: Tx,
    input: {
      promoCodeId: string;
      passengerId: string;
      bookingId: string;
      discountCents: number;
    },
  ) {
    const rows = await tx.$queryRaw<Array<{ id: string }>>`
      UPDATE "PromoCode"
      SET "redeemedCount" = "redeemedCount" + 1
      WHERE id = ${input.promoCodeId}
        AND active = true
        AND ("usageLimitTotal" IS NULL OR "redeemedCount" < "usageLimitTotal")
      RETURNING id
    `;
    if (rows.length !== 1) {
      throw new ConflictException({ code: ApiCode.PROMO_LIMIT_REACHED });
    }

    const promo = await tx.promoCode.findUniqueOrThrow({
      where: { id: input.promoCodeId },
    });
    if (promo.usageLimitPerPassenger != null) {
      const used = await tx.promoRedemption.count({
        where: {
          promoCodeId: input.promoCodeId,
          passengerId: input.passengerId,
          releasedAt: null,
        },
      });
      if (used >= promo.usageLimitPerPassenger) {
        throw new ConflictException({
          code: ApiCode.PROMO_PASSENGER_LIMIT_REACHED,
        });
      }
    }

    await tx.promoRedemption.create({
      data: {
        promoCodeId: input.promoCodeId,
        passengerId: input.passengerId,
        bookingId: input.bookingId,
        discountCents: input.discountCents,
      },
    });
  }

  /** Cancel path: free the usage slot if a non-released redemption exists. */
  async releaseIfAny(tx: Tx, bookingId: string) {
    const redemption = await tx.promoRedemption.findUnique({
      where: { bookingId },
    });
    if (!redemption || redemption.releasedAt) return;

    await tx.promoRedemption.update({
      where: { id: redemption.id },
      data: { releasedAt: new Date() },
    });
    await tx.$executeRaw`
      UPDATE "PromoCode"
      SET "redeemedCount" = GREATEST("redeemedCount" - 1, 0)
      WHERE id = ${redemption.promoCodeId}
    `;
  }

  private async requireScoped(user: AuthUser, id: string) {
    const row = await this.prisma.promoCode.findUnique({ where: { id } });
    if (!row) throw new NotFoundException();
    if (user.role !== 'super_admin') {
      if (row.branchId && row.branchId !== user.branchId) {
        throw new NotFoundException();
      }
    }
    return row;
  }

  private assertTypeValues(
    type: 'PERCENT' | 'FIXED',
    valueBps: number | null | undefined,
    valueCents: number | null | undefined,
  ) {
    if (type === 'PERCENT' && (valueBps == null || valueBps <= 0)) {
      throw new BadRequestException('valueBps is required for PERCENT');
    }
    if (type === 'FIXED' && (valueCents == null || valueCents <= 0)) {
      throw new BadRequestException('valueCents is required for FIXED');
    }
  }

  private assertWrite(user: AuthUser) {
    if (!(WRITE_ROLES as readonly string[]).includes(user.role)) {
      throw new ForbiddenException();
    }
  }

  private assertBranch(user: AuthUser, branchId: string) {
    if (user.role === 'super_admin') return;
    if (!user.branchId || user.branchId !== branchId) {
      throw new ForbiddenException();
    }
  }

  private present(row: {
    id: string;
    code: string;
    branchId: string | null;
    type: string;
    valueBps: number | null;
    valueCents: number | null;
    maxDiscountCents: number | null;
    minSubtotalCents: number;
    usageLimitTotal: number | null;
    usageLimitPerPassenger: number | null;
    redeemedCount: number;
    startAt: Date | null;
    endAt: Date | null;
    active: boolean;
    createdById: string | null;
    createdAt: Date;
  }) {
    return {
      id: row.id,
      code: row.code,
      branchId: row.branchId,
      type: row.type,
      valueBps: row.valueBps,
      valueCents: row.valueCents,
      maxDiscountCents: row.maxDiscountCents,
      minSubtotalCents: row.minSubtotalCents,
      usageLimitTotal: row.usageLimitTotal,
      usageLimitPerPassenger: row.usageLimitPerPassenger,
      redeemedCount: row.redeemedCount,
      startAt: row.startAt?.toISOString() ?? null,
      endAt: row.endAt?.toISOString() ?? null,
      active: row.active,
      createdById: row.createdById,
      createdAt: row.createdAt.toISOString(),
    };
  }
}
