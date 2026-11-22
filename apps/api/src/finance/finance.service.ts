import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma } from '@prisma/client';
import type { AuthUser } from '../common/auth-user.js';
import { normalizePage, paginate } from '../common/pagination.js';
import {
  bankClearingKey,
  driverBalanceKey,
} from '../ledger/account-keys.js';
import { LedgerService } from '../ledger/ledger.service.js';
import { driverBalanceFromEntries } from '../ledger/trip-postings.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { AccountEntriesQuery } from './dto/account-entries-query.dto.js';
import type { DriverEarningsQuery } from './dto/driver-earnings-query.dto.js';
import type { MarkPayoutFailedDto } from './dto/mark-payout-failed.dto.js';
import type { MarkPayoutSentDto } from './dto/mark-payout-sent.dto.js';
import type { PayoutQuery } from './dto/payout-query.dto.js';

const FINANCE_READ_ROLES = [
  'accounts_admin',
  'branch_admin',
  'super_admin',
] as const;
const PAYOUT_WRITE_ROLES = ['accounts_admin', 'super_admin'] as const;

@Injectable()
export class FinanceService {
  private readonly logger = new Logger(FinanceService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: LedgerService,
    private readonly config: ConfigService,
  ) {}

  async reverse(user: AuthUser, transactionId: string, reason: string) {
    const note = reason.trim();
    if (!note) throw new BadRequestException('reason is required');

    return this.prisma.$transaction(async (tx) => {
      const original = await tx.ledgerTransaction.findUnique({
        where: { id: transactionId },
        include: {
          entries: { include: { account: true } },
        },
      });
      if (!original) throw new NotFoundException();
      this.assertBranch(user, original.branchId);

      if (original.kind === 'REVERSAL') {
        throw new ConflictException('Cannot reverse a reversal');
      }
      const already = await tx.ledgerTransaction.findUnique({
        where: { reversalOfId: original.id },
      });
      if (already) {
        throw new ConflictException('Transaction already reversed');
      }

      const lines = original.entries
        .map((entry) => ({
          accountKey: entry.account.key,
          type: entry.account.type,
          ownerId: entry.account.ownerId ?? undefined,
          amountCents: -entry.amountCents,
        }))
        .filter((line) => line.amountCents !== 0);

      const reversal = await this.ledger.post(tx, {
        kind: 'REVERSAL',
        sourceType: 'REVERSAL',
        sourceId: original.id,
        branchId: original.branchId,
        description: note,
        createdById: user.userId,
        reversalOfId: original.id,
        lines,
      });

      if (original.sourceType === 'BOOKING') {
        await tx.booking.updateMany({
          where: { id: original.sourceId },
          data: { paymentStatus: 'REFUNDED' },
        });
      }

      await tx.auditLog.create({
        data: {
          actorUserId: user.userId,
          actorType: 'STAFF',
          entity: 'ledger_transaction',
          entityId: original.id,
          action: 'ledger.reversed',
          before: {
            kind: original.kind,
            sourceType: original.sourceType,
            sourceId: original.sourceId,
            paymentStatus:
              original.sourceType === 'BOOKING' ? 'PAID' : null,
          },
          after: {
            reversalId: reversal.id,
            reason: note,
            paymentStatus:
              original.sourceType === 'BOOKING' ? 'REFUNDED' : null,
          },
        },
      });

      return {
        id: reversal.id,
        kind: reversal.kind,
        reversalOfId: original.id,
        sourceType: reversal.sourceType,
        sourceId: reversal.sourceId,
        branchId: reversal.branchId,
        description: reversal.description,
        createdAt: reversal.createdAt.toISOString(),
      };
    });
  }

  async driverBalance(user: AuthUser, driverId: string) {
    this.assertFinanceRead(user);
    const driver = await this.prisma.driver.findUnique({
      where: { id: driverId },
      select: { id: true, branchId: true },
    });
    if (!driver) throw new NotFoundException();
    this.assertBranch(user, driver.branchId);

    const asOf = new Date();
    const balanceCents = await this.balanceForDriver(driver.id, asOf);
    return { balanceCents, asOf: asOf.toISOString() };
  }

  /**
   * Creates PENDING DriverPayout rows for every driver the company owes, and
   * posts SETTLEMENT ledger txns that zero DRIVER_BALANCE. Money movement is
   * confirmed later via mark-sent.
   */
  async runPayouts(user: AuthUser, branchId?: string) {
    this.assertPayoutWrite(user);
    const resolvedBranchId = this.resolveBranchId(user, branchId);
    const method =
      this.config.get<string>('PAYOUT_METHOD_DEFAULT')?.trim() || 'E_TRANSFER';

    const balances = await this.getBranchDriverBalances(resolvedBranchId);
    const pending = await this.prisma.driverPayout.findMany({
      where: { branchId: resolvedBranchId, status: 'PENDING' },
      select: { driverId: true },
    });
    const pendingDrivers = new Set(pending.map((row) => row.driverId));

    const created: Array<{
      id: string;
      driverId: string;
      amountCents: number;
      status: 'PENDING';
    }> = [];
    const skipped: Array<{ driverId: string; reason: string }> = [];

    for (const row of balances) {
      if (row.balanceCents <= 0) continue;
      if (pendingDrivers.has(row.driverId)) {
        skipped.push({ driverId: row.driverId, reason: 'PENDING_PAYOUT_EXISTS' });
        continue;
      }

      try {
        const payout = await this.prisma.$transaction(async (tx) => {
          const createdPayout = await tx.driverPayout.create({
            data: {
              driverId: row.driverId,
              branchId: resolvedBranchId,
              amountCents: row.balanceCents,
              method,
              requestedById: user.userId,
            },
          });
          await this.ledger.post(tx, {
            kind: 'SETTLEMENT',
            sourceType: 'DRIVER_PAYOUT',
            sourceId: createdPayout.id,
            branchId: resolvedBranchId,
            description: `Driver payout ${createdPayout.id}`,
            createdById: user.userId,
            lines: [
              {
                accountKey: driverBalanceKey(row.driverId),
                type: 'DRIVER_BALANCE',
                ownerId: row.driverId,
                amountCents: row.balanceCents,
              },
              {
                accountKey: bankClearingKey(resolvedBranchId),
                type: 'BANK_CLEARING',
                amountCents: -row.balanceCents,
              },
            ],
          });
          return createdPayout;
        });
        created.push({
          id: payout.id,
          driverId: payout.driverId,
          amountCents: payout.amountCents,
          status: 'PENDING',
        });
        pendingDrivers.add(row.driverId);
      } catch (error: any) {
        if (
          (error instanceof Prisma.PrismaClientKnownRequestError ||
            error?.code === 'P2002') &&
          error.code === 'P2002'
        ) {
          skipped.push({
            driverId: row.driverId,
            reason: 'PENDING_PAYOUT_EXISTS',
          });
          continue;
        }
        throw error;
      }
    }

    this.logger.log(
      `Payout run branch=${resolvedBranchId}: created=${created.length} skipped=${skipped.length}`,
    );
    return {
      branchId: resolvedBranchId,
      method,
      created,
      skipped,
    };
  }

  async listPayouts(user: AuthUser, query: PayoutQuery) {
    this.assertFinanceRead(user);
    const scopeBranchId =
      user.role === 'super_admin'
        ? query.branchId
        : (user.branchId ?? undefined);
    if (user.role !== 'super_admin' && !scopeBranchId) {
      throw new ForbiddenException();
    }

    const { page, pageSize, skip, take } = normalizePage(query);
    const where = {
      ...(scopeBranchId ? { branchId: scopeBranchId } : {}),
      ...(query.status ? { status: query.status } : {}),
      ...(query.driverId ? { driverId: query.driverId } : {}),
    };
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.driverPayout.count({ where }),
      this.prisma.driverPayout.findMany({
        where,
        orderBy: { requestedAt: 'desc' },
        skip,
        take,
        include: {
          driver: {
            select: { id: true, firstName: true, lastName: true },
          },
        },
      }),
    ]);
    return paginate(
      rows.map((row) => this.presentPayout(row)),
      total,
      { page, pageSize },
    );
  }

  async markPayoutSent(
    user: AuthUser,
    id: string,
    dto: MarkPayoutSentDto,
  ) {
    this.assertPayoutWrite(user);
    const payout = await this.requirePayout(user, id);
    if (payout.status !== 'PENDING') {
      throw new ConflictException('Only PENDING payouts can be marked sent');
    }
    const updated = await this.prisma.driverPayout.update({
      where: { id: payout.id },
      data: {
        status: 'SENT',
        sentAt: new Date(),
        sentById: user.userId,
        reference: dto.reference?.trim() || null,
      },
      include: {
        driver: {
          select: { id: true, firstName: true, lastName: true },
        },
      },
    });
    return this.presentPayout(updated);
  }

  async markPayoutFailed(
    user: AuthUser,
    id: string,
    dto: MarkPayoutFailedDto,
  ) {
    this.assertPayoutWrite(user);
    const note = dto.note.trim();
    if (!note) throw new BadRequestException('note is required');
    const payout = await this.requirePayout(user, id);
    if (payout.status !== 'PENDING') {
      throw new ConflictException('Only PENDING payouts can be marked failed');
    }
    // No automatic ledger reversal — failure reason decides the fix.
    const updated = await this.prisma.driverPayout.update({
      where: { id: payout.id },
      data: {
        status: 'FAILED',
        failureNote: note,
        sentById: user.userId,
      },
      include: {
        driver: {
          select: { id: true, firstName: true, lastName: true },
        },
      },
    });
    return this.presentPayout(updated);
  }

  /** Day 9 balance query, grouped for every driver in the branch. */
  async getBranchDriverBalances(branchId: string) {
    const drivers = await this.prisma.driver.findMany({
      where: { branchId },
      select: { id: true },
    });
    if (drivers.length === 0) return [];

    const accounts = await this.prisma.financialAccount.findMany({
      where: {
        type: 'DRIVER_BALANCE',
        ownerId: { in: drivers.map((d) => d.id) },
      },
      select: { id: true, ownerId: true },
    });
    const accountByDriver = new Map(
      accounts
        .filter((a): a is typeof a & { ownerId: string } => Boolean(a.ownerId))
        .map((a) => [a.ownerId, a.id] as const),
    );
    const sums =
      accounts.length === 0
        ? []
        : await this.prisma.ledgerEntry.groupBy({
            by: ['accountId'],
            where: { accountId: { in: accounts.map((a) => a.id) } },
            _sum: { amountCents: true },
          });
    const sumByAccount = new Map<string, number>(
      sums.map((row) => [row.accountId, row._sum.amountCents ?? 0] as const),
    );

    return drivers.map((driver) => {
      const accountId = accountByDriver.get(driver.id);
      const entrySum = accountId ? (sumByAccount.get(accountId) ?? 0) : 0;
      return {
        driverId: driver.id,
        balanceCents: driverBalanceFromEntries([entrySum]),
      };
    });
  }

  async accountEntries(user: AuthUser, key: string, query: AccountEntriesQuery) {
    this.assertFinanceRead(user);
    const account = await this.prisma.financialAccount.findUnique({
      where: { key },
    });
    if (!account) throw new NotFoundException();
    if (account.branchId) this.assertBranch(user, account.branchId);
    else if (user.role !== 'super_admin') throw new ForbiddenException();

    const { page, pageSize, skip, take } = normalizePage(query);
    const where = { accountId: account.id };
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.ledgerEntry.count({ where }),
      this.prisma.ledgerEntry.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        include: {
          transaction: {
            select: {
              id: true,
              kind: true,
              sourceType: true,
              sourceId: true,
              description: true,
              createdAt: true,
            },
          },
        },
      }),
    ]);

    const bookingIds = [
      ...new Set(
        rows
          .filter((row) => row.transaction.sourceType === 'BOOKING')
          .map((row) => row.transaction.sourceId),
      ),
    ];
    const reversalIds = [
      ...new Set(
        rows
          .filter((row) => row.transaction.sourceType === 'REVERSAL')
          .map((row) => row.transaction.sourceId),
      ),
    ];
    const originals =
      reversalIds.length === 0
        ? []
        : await this.prisma.ledgerTransaction.findMany({
            where: { id: { in: reversalIds } },
            select: { id: true, sourceType: true, sourceId: true },
          });
    for (const original of originals) {
      if (original.sourceType === 'BOOKING') bookingIds.push(original.sourceId);
    }
    const bookings =
      bookingIds.length === 0
        ? []
        : await this.prisma.booking.findMany({
            where: { id: { in: bookingIds } },
            select: { id: true, trackingId: true },
          });
    const trackingByBooking = new Map(
      bookings.map((row) => [row.id, row.trackingId] as const),
    );
    const bookingByReversal = new Map<string, string>(
      originals
        .filter((row) => row.sourceType === 'BOOKING')
        .map((row) => [row.id, row.sourceId] as const),
    );

    const data = rows.map((row) => {
      let bookingId: string | null = null;
      if (row.transaction.sourceType === 'BOOKING') {
        bookingId = row.transaction.sourceId;
      } else if (row.transaction.sourceType === 'REVERSAL') {
        bookingId = bookingByReversal.get(row.transaction.sourceId) ?? null;
      }
      return {
        id: row.id,
        amountCents: row.amountCents,
        createdAt: row.createdAt.toISOString(),
        transaction: {
          id: row.transaction.id,
          kind: row.transaction.kind,
          sourceType: row.transaction.sourceType,
          sourceId: row.transaction.sourceId,
          description: row.transaction.description,
          createdAt: row.transaction.createdAt.toISOString(),
        },
        bookingTrackingId: bookingId
          ? (trackingByBooking.get(bookingId) ?? null)
          : null,
      };
    });

    return paginate(data, total, { page, pageSize });
  }

  async driverEarnings(user: AuthUser, query: DriverEarningsQuery) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
      select: { id: true },
    });
    if (!driver) throw new NotFoundException();

    const from = new Date(query.from);
    const to = new Date(query.to);
    if (!(from.getTime() <= to.getTime())) {
      throw new BadRequestException('from must be on or before to');
    }

    const trips = await this.prisma.booking.findMany({
      where: {
        driverId: driver.id,
        status: 'CLOSED',
        completedAt: { gte: from, lte: to },
      },
      orderBy: { completedAt: 'desc' },
      select: {
        id: true,
        trackingId: true,
        completedAt: true,
        paymentMethod: true,
        paymentStatus: true,
        finalSubtotalCents: true,
        commissionCents: true,
        driverEarningCents: true,
        finalFareCents: true,
      },
    });

    let grossSubtotalCents = 0;
    let commissionCents = 0;
    let netEarningsCents = 0;
    const rows = trips.map((trip) => {
      const subtotal = trip.finalSubtotalCents ?? 0;
      const commission = trip.commissionCents ?? 0;
      const net = trip.driverEarningCents ?? 0;
      grossSubtotalCents += subtotal;
      commissionCents += commission;
      netEarningsCents += net;
      return {
        id: trip.id,
        trackingId: trip.trackingId,
        completedAt: trip.completedAt?.toISOString() ?? null,
        paymentMethod: trip.paymentMethod,
        paymentStatus: trip.paymentStatus,
        finalSubtotalCents: trip.finalSubtotalCents,
        commissionCents: trip.commissionCents,
        driverEarningCents: trip.driverEarningCents,
        finalFareCents: trip.finalFareCents,
      };
    });

    const asOf = new Date();
    return {
      from: from.toISOString(),
      to: to.toISOString(),
      trips: rows,
      grossSubtotalCents,
      commissionCents,
      netEarningsCents,
      balanceCents: await this.balanceForDriver(driver.id, asOf),
      asOf: asOf.toISOString(),
    };
  }

  private async balanceForDriver(driverId: string, asOf: Date) {
    const account = await this.prisma.financialAccount.findUnique({
      where: { key: driverBalanceKey(driverId) },
      select: { id: true },
    });
    if (!account) return 0;
    const agg = await this.prisma.ledgerEntry.aggregate({
      where: {
        accountId: account.id,
        createdAt: { lte: asOf },
      },
      _sum: { amountCents: true },
    });
    return driverBalanceFromEntries([agg._sum.amountCents ?? 0]);
  }

  private async requirePayout(user: AuthUser, id: string) {
    const payout = await this.prisma.driverPayout.findUnique({
      where: { id },
      include: {
        driver: {
          select: { id: true, firstName: true, lastName: true },
        },
      },
    });
    if (!payout) throw new NotFoundException();
    this.assertBranch(user, payout.branchId);
    return payout;
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

  private presentPayout(row: {
    id: string;
    driverId: string;
    branchId: string;
    amountCents: number;
    status: string;
    method: string;
    reference: string | null;
    requestedById: string | null;
    requestedAt: Date;
    sentAt: Date | null;
    sentById: string | null;
    failureNote: string | null;
    driver: { id: string; firstName: string; lastName: string };
  }) {
    return {
      id: row.id,
      driverId: row.driverId,
      branchId: row.branchId,
      amountCents: row.amountCents,
      status: row.status,
      method: row.method,
      reference: row.reference,
      requestedById: row.requestedById,
      requestedAt: row.requestedAt.toISOString(),
      sentAt: row.sentAt?.toISOString() ?? null,
      sentById: row.sentById,
      failureNote: row.failureNote,
      driver: row.driver,
    };
  }

  private assertFinanceRead(user: AuthUser) {
    if (!FINANCE_READ_ROLES.includes(user.role as (typeof FINANCE_READ_ROLES)[number])) {
      throw new ForbiddenException();
    }
  }

  private assertPayoutWrite(user: AuthUser) {
    if (!PAYOUT_WRITE_ROLES.includes(user.role as (typeof PAYOUT_WRITE_ROLES)[number])) {
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
