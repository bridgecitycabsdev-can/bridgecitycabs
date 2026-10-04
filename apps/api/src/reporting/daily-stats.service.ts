import { Injectable, Logger } from '@nestjs/common';
import type { BookingStatus } from '@prisma/client';
import {
  branchDayWindow,
  branchLocalDateStart,
  previousBranchDayWindow,
} from '../fleet/fleet-day.js';
import { PrismaService } from '../prisma/prisma.service.js';

/**
 * In-progress (non-terminal) statuses for the Daily Statistics "active" bucket.
 * CLOSED / CANCELLED / NO_DRIVER_FOUND are counted separately.
 */
export const ACTIVE_STATUSES: BookingStatus[] = [
  'SCHEDULED',
  'CREATED',
  'SEARCHING_DRIVER',
  'MATCHED',
  'DRIVER_ASSIGNED',
  'DRIVER_ARRIVING',
  'DRIVER_ARRIVED',
  'TRIP_STARTED',
  'TRIP_COMPLETED',
  'PAYMENT_PENDING',
  'PAYMENT_COMPLETED',
];

/** Above this daily volume, switch findMany + in-memory aggregate to grouped SQL. */
const FIND_MANY_VOLUME_REVISIT = 10_000;

export type DailyStatTotals = {
  totalRides: number;
  completedRides: number;
  activeRides: number;
  cancelledRides: number;
  unpaidRides: number;
  prepaidRides: number;
  postpaidRides: number;
  accountCalls: number;
  sourceDispatch: number;
  sourceDriverApp: number;
  sourcePassengerApp: number;
  grossSubtotalCents: number;
};

@Injectable()
export class DailyStatsService {
  private readonly logger = new Logger(DailyStatsService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Live aggregation for one branch-local day. Does not write DailyBranchStat.
   * `date` = branch-local midnight already converted to a UTC instant.
   *
   * For a 14-driver fleet this in-memory aggregation over one day's rows is
   * trivial. If a branch's daily volume grows into the tens of thousands
   * (`FIND_MANY_VOLUME_REVISIT`), switch the findMany to a single grouped SQL
   * query instead — revisit before rediscovering the slowdown.
   */
  async aggregateDailyStat(
    branchId: string,
    date: Date,
    timeZone?: string,
  ): Promise<DailyStatTotals> {
    const tz =
      timeZone?.trim() ||
      (
        await this.prisma.branch.findUnique({
          where: { id: branchId },
          select: { timezone: true },
        })
      )?.timezone?.trim() ||
      'America/Edmonton';
    const midday = new Date(date.getTime() + 12 * 60 * 60 * 1000);
    const dayEnd = branchDayWindow(tz, midday).end;

    const bookings = await this.prisma.booking.findMany({
      where: { branchId, createdAt: { gte: date, lt: dayEnd } },
      select: {
        status: true,
        paymentMethod: true,
        paymentStatus: true,
        source: true,
        corporateAccountId: true,
        finalSubtotalCents: true,
      },
    });

    if (bookings.length >= FIND_MANY_VOLUME_REVISIT) {
      this.logger.warn(
        `Branch ${branchId} day ${date.toISOString()} has ${bookings.length} bookings — ` +
          `consider replacing findMany aggregation with grouped SQL (threshold ${FIND_MANY_VOLUME_REVISIT})`,
      );
    }

    return totalsFromBookings(bookings);
  }

  /** Upsert a finished (or self-healed) day into DailyBranchStat. */
  async computeDailyStat(branchId: string, date: Date) {
    const branch = await this.prisma.branch.findUnique({
      where: { id: branchId },
      select: { timezone: true },
    });
    const timeZone = branch?.timezone?.trim() || 'America/Edmonton';
    const stat = await this.aggregateDailyStat(branchId, date, timeZone);
    return this.prisma.dailyBranchStat.upsert({
      where: { branchId_date: { branchId, date } },
      update: { ...stat, computedAt: new Date() },
      create: { branchId, date, ...stat },
    });
  }

  /** Nightly job: upsert yesterday's rollup for every branch in `timezone`. */
  async rollupYesterdayForTimezone(timezone: string, now = new Date()) {
    const { start } = previousBranchDayWindow(timezone, now);
    const branches = await this.prisma.branch.findMany({
      where: { timezone, active: true },
      select: { id: true, name: true },
    });
    for (const branch of branches) {
      const row = await this.computeDailyStat(branch.id, start);
      this.logger.log(
        `Rollup ${branch.name} ${start.toISOString().slice(0, 10)} total=${row.totalRides}`,
      );
    }
    return { timezone, date: start, branches: branches.length };
  }

  /**
   * Backfill inclusive `[fromYmd, toYmd]` branch-local calendar dates
   * (`YYYY-MM-DD`), one upsert per day. Walks calendar dates (not UTC-day
   * arithmetic) so DST transitions do not skip or double a local day.
   */
  async backfill(
    branchId: string,
    fromYmd: string,
    toYmd: string,
    timeZone: string,
  ) {
    if (fromYmd > toYmd) {
      throw new Error(`--from ${fromYmd} is after --to ${toYmd}`);
    }
    let days = 0;
    for (const ymd of eachYmd(fromYmd, toYmd)) {
      const start = branchLocalDateStart(timeZone, ymd);
      await this.computeDailyStat(branchId, start);
      days += 1;
    }
    return { branchId, days, from: fromYmd, to: toYmd };
  }
}

export function totalsFromBookings(
  bookings: Array<{
    status: string;
    paymentMethod: string;
    paymentStatus: string;
    source: string;
    corporateAccountId: string | null;
    finalSubtotalCents: number | null;
  }>,
): DailyStatTotals {
  const active = new Set<string>(ACTIVE_STATUSES);
  return {
    totalRides: bookings.length,
    completedRides: bookings.filter((b) => b.status === 'CLOSED').length,
    activeRides: bookings.filter((b) => active.has(b.status)).length,
    cancelledRides: bookings.filter((b) => b.status === 'CANCELLED').length,
    unpaidRides: bookings.filter((b) => b.paymentStatus === 'UNPAID').length,
    prepaidRides: bookings.filter((b) => b.paymentMethod === 'CARD').length,
    postpaidRides: bookings.filter((b) =>
      ['CASH', 'ACCOUNT'].includes(b.paymentMethod),
    ).length,
    accountCalls: bookings.filter((b) => b.corporateAccountId != null).length,
    sourceDispatch: bookings.filter((b) => b.source === 'DISPATCH').length,
    sourceDriverApp: bookings.filter((b) => b.source === 'DRIVER_APP').length,
    sourcePassengerApp: bookings.filter((b) => b.source === 'PASSENGER_APP')
      .length,
    grossSubtotalCents: bookings.reduce(
      (s, b) => s + (b.finalSubtotalCents ?? 0),
      0,
    ),
  };
}

export function sumDailyStatTotals(rows: DailyStatTotals[]): DailyStatTotals {
  return rows.reduce(
    (acc, row) => ({
      totalRides: acc.totalRides + row.totalRides,
      completedRides: acc.completedRides + row.completedRides,
      activeRides: acc.activeRides + row.activeRides,
      cancelledRides: acc.cancelledRides + row.cancelledRides,
      unpaidRides: acc.unpaidRides + row.unpaidRides,
      prepaidRides: acc.prepaidRides + row.prepaidRides,
      postpaidRides: acc.postpaidRides + row.postpaidRides,
      accountCalls: acc.accountCalls + row.accountCalls,
      sourceDispatch: acc.sourceDispatch + row.sourceDispatch,
      sourceDriverApp: acc.sourceDriverApp + row.sourceDriverApp,
      sourcePassengerApp: acc.sourcePassengerApp + row.sourcePassengerApp,
      grossSubtotalCents: acc.grossSubtotalCents + row.grossSubtotalCents,
    }),
    emptyTotals(),
  );
}

export function emptyTotals(): DailyStatTotals {
  return {
    totalRides: 0,
    completedRides: 0,
    activeRides: 0,
    cancelledRides: 0,
    unpaidRides: 0,
    prepaidRides: 0,
    postpaidRides: 0,
    accountCalls: 0,
    sourceDispatch: 0,
    sourceDriverApp: 0,
    sourcePassengerApp: 0,
    grossSubtotalCents: 0,
  };
}

/** Inclusive YYYY-MM-DD range using UTC calendar math on the date parts only. */
export function* eachYmd(fromYmd: string, toYmd: string) {
  const cursor = new Date(`${fromYmd}T00:00:00.000Z`);
  const end = new Date(`${toYmd}T00:00:00.000Z`);
  while (cursor.getTime() <= end.getTime()) {
    yield cursor.toISOString().slice(0, 10);
    cursor.setUTCDate(cursor.getUTCDate() + 1);
  }
}
