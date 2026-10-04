import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import {
  previousBranchWeek,
  startOfBranchWeek,
} from '../lease/lease-week.js';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class WeeklyClosingService {
  private readonly logger = new Logger(WeeklyClosingService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Materializes opening/movement/closing cents per account for a branch week.
   * DRAFT periods may be recomputed freely; FINALIZED is refused.
   * Never writes LedgerEntry / LedgerTransaction.
   */
  async closeWeek(
    branchId: string,
    weekStart: Date,
    weekEnd: Date,
    actorId?: string,
  ) {
    if (!(weekStart.getTime() < weekEnd.getTime())) {
      throw new BadRequestException('weekStart must be before weekEnd');
    }

    const existing = await this.prisma.closingPeriod.findUnique({
      where: { branchId_weekStart: { branchId, weekStart } },
    });
    if (existing?.status === 'FINALIZED') {
      throw new ConflictException('Week already closed');
    }

    const accounts = await this.prisma.financialAccount.findMany({
      where: { branchId },
    });
    const lines = [];
    for (const acct of accounts) {
      const [opening, through] = await Promise.all([
        this.sumEntries(acct.id, { lt: weekStart }),
        this.sumEntries(acct.id, { lt: weekEnd }),
      ]);
      lines.push({
        accountKey: acct.key,
        accountType: acct.type,
        ownerId: acct.ownerId,
        // Negate so reporting matches driverBalanceFromEntries (−SUM).
        openingCents: -opening,
        movementCents: -(through - opening),
        closingCents: -through,
      });
    }

    const period = await this.prisma.$transaction(async (tx) => {
      const saved = await tx.closingPeriod.upsert({
        where: { branchId_weekStart: { branchId, weekStart } },
        update: { weekEnd },
        create: { branchId, weekStart, weekEnd },
      });
      // DRAFT can be recomputed freely (trigger allows DELETE while DRAFT).
      await tx.closingLine.deleteMany({ where: { closingPeriodId: saved.id } });
      if (lines.length > 0) {
        await tx.closingLine.createMany({
          data: lines.map((line) => ({
            ...line,
            closingPeriodId: saved.id,
          })),
        });
      }
      return saved;
    });

    this.logger.log(
      `Closing period ${period.id} branch=${branchId} lines=${lines.length}` +
        (actorId ? ` by=${actorId}` : ''),
    );
    return this.getPeriod(period.id);
  }

  async closePreviousWeekForBranch(branchId: string, now = new Date()) {
    const branch = await this.prisma.branch.findUnique({
      where: { id: branchId },
      select: { id: true, timezone: true },
    });
    if (!branch) throw new NotFoundException();
    const { weekStart, weekEnd } = previousBranchWeek(branch.timezone, now);
    return this.closeWeek(branch.id, weekStart, weekEnd);
  }

  async closePreviousWeekForTimezone(timezone: string, now = new Date()) {
    const branches = await this.prisma.branch.findMany({
      where: { timezone },
      select: { id: true },
    });
    const results = [];
    for (const branch of branches) {
      try {
        results.push(await this.closePreviousWeekForBranch(branch.id, now));
      } catch (error) {
        if (error instanceof ConflictException) {
          this.logger.debug(
            `Skipping finalized closing for branch ${branch.id}`,
          );
          continue;
        }
        throw error;
      }
    }
    return { timezone, closed: results.length, periods: results };
  }

  async runOnDemand(user: AuthUser, branchId?: string, weekStartIso?: string) {
    this.assertFinanceWrite(user);
    const resolvedBranchId = this.resolveBranchId(user, branchId);
    const branch = await this.prisma.branch.findUnique({
      where: { id: resolvedBranchId },
      select: { id: true, timezone: true },
    });
    if (!branch) throw new NotFoundException();

    let weekStart: Date;
    let weekEnd: Date;
    if (weekStartIso) {
      weekStart = new Date(weekStartIso);
      if (Number.isNaN(weekStart.getTime())) {
        throw new BadRequestException('weekStart must be an ISO date');
      }
      weekEnd = startOfBranchWeek(
        branch.timezone,
        new Date(weekStart.getTime() + 8 * 24 * 60 * 60 * 1000),
      );
    } else {
      ({ weekStart, weekEnd } = previousBranchWeek(branch.timezone));
    }

    return this.closeWeek(
      branch.id,
      weekStart,
      weekEnd,
      user.userId,
    );
  }

  async finalize(user: AuthUser, id: string) {
    this.assertFinanceWrite(user);
    const period = await this.requirePeriod(user, id);
    if (period.status === 'FINALIZED') {
      throw new ConflictException('Week already closed');
    }
    await this.prisma.closingPeriod.update({
      where: { id: period.id },
      data: {
        status: 'FINALIZED',
        finalizedAt: new Date(),
        finalizedById: user.userId,
      },
    });
    return this.getPeriod(period.id);
  }

  async list(user: AuthUser, branchId?: string) {
    this.assertFinanceRead(user);
    const scopeBranchId =
      user.role === 'super_admin' ? branchId : user.branchId ?? undefined;
    if (user.role !== 'super_admin' && !scopeBranchId) {
      throw new ForbiddenException();
    }
    const rows = await this.prisma.closingPeriod.findMany({
      where: scopeBranchId ? { branchId: scopeBranchId } : {},
      orderBy: { weekStart: 'desc' },
      include: { _count: { select: { lines: true } } },
    });
    return rows.map((row) => ({
      id: row.id,
      branchId: row.branchId,
      weekStart: row.weekStart.toISOString(),
      weekEnd: row.weekEnd.toISOString(),
      status: row.status,
      finalizedAt: row.finalizedAt?.toISOString() ?? null,
      finalizedById: row.finalizedById,
      createdAt: row.createdAt.toISOString(),
      lineCount: row._count.lines,
    }));
  }

  async get(user: AuthUser, id: string) {
    this.assertFinanceRead(user);
    const period = await this.requirePeriod(user, id);
    return this.getPeriod(period.id);
  }

  private async getPeriod(id: string) {
    const period = await this.prisma.closingPeriod.findUniqueOrThrow({
      where: { id },
      include: {
        lines: { orderBy: [{ accountType: 'asc' }, { accountKey: 'asc' }] },
      },
    });
    return {
      id: period.id,
      branchId: period.branchId,
      weekStart: period.weekStart.toISOString(),
      weekEnd: period.weekEnd.toISOString(),
      status: period.status,
      finalizedAt: period.finalizedAt?.toISOString() ?? null,
      finalizedById: period.finalizedById,
      createdAt: period.createdAt.toISOString(),
      lines: period.lines.map((line) => ({
        id: line.id,
        accountKey: line.accountKey,
        accountType: line.accountType,
        ownerId: line.ownerId,
        openingCents: line.openingCents,
        movementCents: line.movementCents,
        closingCents: line.closingCents,
      })),
    };
  }

  private async sumEntries(
    accountId: string,
    createdAt: { lt: Date },
  ): Promise<number> {
    const agg = await this.prisma.ledgerEntry.aggregate({
      where: { accountId, createdAt },
      _sum: { amountCents: true },
    });
    return agg._sum.amountCents ?? 0;
  }

  private async requirePeriod(user: AuthUser, id: string) {
    const period = await this.prisma.closingPeriod.findUnique({
      where: { id },
    });
    if (!period) throw new NotFoundException();
    this.assertBranch(user, period.branchId);
    return period;
  }

  private resolveBranchId(user: AuthUser, requested?: string) {
    if (user.role === 'super_admin') {
      if (!requested) throw new BadRequestException('branchId is required');
      return requested;
    }
    if (!user.branchId) throw new ForbiddenException();
    if (requested && requested !== user.branchId) {
      throw new ForbiddenException();
    }
    return user.branchId;
  }

  private assertFinanceRead(user: AuthUser) {
    const roles = ['accounts_admin', 'branch_admin', 'super_admin'];
    if (!roles.includes(user.role)) throw new ForbiddenException();
  }

  private assertFinanceWrite(user: AuthUser) {
    if (user.role !== 'accounts_admin' && user.role !== 'super_admin') {
      throw new ForbiddenException();
    }
  }

  private assertBranch(user: AuthUser, branchId: string) {
    if (user.role === 'super_admin') return;
    if (!user.branchId || user.branchId !== branchId) {
      throw new NotFoundException();
    }
  }
}
