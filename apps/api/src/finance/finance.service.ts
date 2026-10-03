import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { normalizePage, paginate } from '../common/pagination.js';
import { driverBalanceKey } from '../ledger/account-keys.js';
import { LedgerService } from '../ledger/ledger.service.js';
import { driverBalanceFromEntries } from '../ledger/trip-postings.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { AccountEntriesQuery } from './dto/account-entries-query.dto.js';
import type { DriverEarningsQuery } from './dto/driver-earnings-query.dto.js';

const FINANCE_READ_ROLES = [
  'accounts_admin',
  'branch_admin',
  'super_admin',
] as const;

@Injectable()
export class FinanceService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: LedgerService,
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
    const bookingByReversal = new Map(
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

  private assertFinanceRead(user: AuthUser) {
    if (!FINANCE_READ_ROLES.includes(user.role as (typeof FINANCE_READ_ROLES)[number])) {
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
