import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import {
  branchLocalDateStart,
  calendarDate,
  isSameLocalDay,
} from '../fleet/fleet-day.js';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  DailyStatsService,
  eachYmd,
  emptyTotals,
  sumDailyStatTotals,
  type DailyStatTotals,
} from './daily-stats.service.js';
import type {
  DashboardBranchQuery,
  DashboardChartQuery,
  DashboardDateQuery,
} from './dto/dashboard-query.dto.js';

const STAFF = new Set<string>(STAFF_ROLES);
const DEFAULT_TZ = 'America/Edmonton';

@Injectable()
export class DashboardService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly stats: DailyStatsService,
  ) {}

  async metrics(user: AuthUser, query: DashboardBranchQuery) {
    this.assertStaff(user);
    const scope = branchWhere(user, query.branchId);
    const branchId = scope.branchId as string | undefined;

    const [registeredPassengers, registeredVehicles, completedRides, registeredUsers] =
      await Promise.all([
        this.prisma.passenger.count({
          where: branchId
            ? { bookings: { some: { branchId } } }
            : undefined,
        }),
        this.prisma.vehicle.count({
          where: branchId ? { branchId } : undefined,
        }),
        this.prisma.booking.count({
          where: {
            status: 'CLOSED',
            ...(branchId ? { branchId } : {}),
          },
        }),
        this.prisma.user.count({
          where: branchId ? { branchId } : undefined,
        }),
      ]);

    return {
      registeredPassengers,
      registeredVehicles,
      completedRides,
      registeredUsers,
    };
  }

  async dailyStats(user: AuthUser, query: DashboardDateQuery) {
    this.assertStaff(user);
    const branches = await this.resolveBranches(user, query.branchId);
    const now = new Date();

    if (branches.length === 0) {
      return this.presentDaily({
        branchId: null,
        date: now,
        dateLocal: query.date ?? calendarDate(DEFAULT_TZ, now),
        live: false,
        ...emptyTotals(),
      });
    }

    const rows = await Promise.all(
      branches.map(async (branch) => {
        const tz = branch.timezone?.trim() || DEFAULT_TZ;
        const ymd = query.date ?? calendarDate(tz, now);
        const date = branchLocalDateStart(tz, ymd);
        const totals = await this.getDailyStats(branch.id, date, tz, now);
        return { branchId: branch.id, date, dateLocal: ymd, ...totals };
      }),
    );

    if (rows.length === 1) {
      return this.presentDaily(rows[0]!);
    }
    const summed = sumDailyStatTotals(rows);
    return this.presentDaily({
      branchId: null,
      date: rows[0]!.date,
      dateLocal: query.date ?? calendarDate(DEFAULT_TZ, now),
      ...summed,
      live: rows.some((r) => r.live),
    });
  }

  async ridesChart(user: AuthUser, query: DashboardChartQuery) {
    this.assertStaff(user);
    if (query.from > query.to) {
      throw new BadRequestException('from must be on or before to');
    }
    const branches = await this.resolveBranches(user, query.branchId);
    const now = new Date();
    const points = new Map<
      string,
      { date: string; total: number; completed: number; cancelled: number }
    >();

    for (const ymd of eachYmd(query.from, query.to)) {
      points.set(ymd, { date: ymd, total: 0, completed: 0, cancelled: 0 });
    }

    for (const branch of branches) {
      const tz = branch.timezone?.trim() || DEFAULT_TZ;
      const fromDate = branchLocalDateStart(tz, query.from);
      const toDate = branchLocalDateStart(tz, query.to);
      const todayYmd = calendarDate(tz, now);

      const stored = await this.prisma.dailyBranchStat.findMany({
        where: {
          branchId: branch.id,
          date: { gte: fromDate, lte: toDate },
        },
        select: {
          date: true,
          totalRides: true,
          completedRides: true,
          cancelledRides: true,
        },
      });

      for (const row of stored) {
        const ymd = calendarDate(tz, row.date);
        if (ymd === todayYmd) continue; // today always live below
        const point = points.get(ymd);
        if (!point) continue;
        point.total += row.totalRides;
        point.completed += row.completedRides;
        point.cancelled += row.cancelledRides;
      }

      if (
        points.has(todayYmd) &&
        query.from <= todayYmd &&
        todayYmd <= query.to
      ) {
        const live = await this.stats.aggregateDailyStat(
          branch.id,
          branchLocalDateStart(tz, todayYmd),
          tz,
        );
        const point = points.get(todayYmd)!;
        point.total += live.totalRides;
        point.completed += live.completedRides;
        point.cancelled += live.cancelledRides;
      }
    }

    return [...points.values()];
  }

  async bookingSource(user: AuthUser, query: DashboardDateQuery) {
    this.assertStaff(user);
    const stats = await this.dailyStats(user, query);
    return {
      dispatch: stats.sourceDispatch,
      driverApp: stats.sourceDriverApp,
      passengerApp: stats.sourcePassengerApp,
      date: stats.dateLocal,
      branchId: stats.branchId,
      live: stats.live,
    };
  }

  /**
   * Today → live aggregate (not persisted). Past → rollup row, self-healing
   * with computeDailyStat (upsert) when the historical row is missing.
   */
  async getDailyStats(
    branchId: string,
    date: Date,
    branchTz: string,
    now = new Date(),
  ): Promise<DailyStatTotals & { live: boolean }> {
    const isToday = isSameLocalDay(date, now, branchTz);
    if (isToday) {
      const live = await this.stats.aggregateDailyStat(
        branchId,
        date,
        branchTz,
      );
      return { ...live, live: true };
    }

    const stat = await this.prisma.dailyBranchStat.findUnique({
      where: { branchId_date: { branchId, date } },
    });
    if (stat) {
      return { ...pickTotals(stat), live: false };
    }

    const healed = await this.stats.computeDailyStat(branchId, date);
    return { ...pickTotals(healed), live: false };
  }

  private async resolveBranches(user: AuthUser, requestedBranchId?: string) {
    const scope = branchWhere(user, requestedBranchId);
    if (scope.branchId) {
      const branch = await this.prisma.branch.findUnique({
        where: { id: scope.branchId },
        select: { id: true, timezone: true },
      });
      if (!branch) throw new NotFoundException('Branch not found');
      return [branch];
    }

    return this.prisma.branch.findMany({
      where: { active: true },
      select: { id: true, timezone: true },
      orderBy: { name: 'asc' },
    });
  }

  private presentDaily(row: {
    branchId: string | null;
    date: Date;
    dateLocal: string;
    live?: boolean;
  } & DailyStatTotals) {
    return {
      branchId: row.branchId || null,
      date: row.date.toISOString(),
      dateLocal: row.dateLocal,
      live: row.live ?? false,
      ...pickTotals(row),
    };
  }

  private assertStaff(user: AuthUser) {
    if (!STAFF.has(user.role)) throw new ForbiddenException();
  }
}

function pickTotals(row: DailyStatTotals): DailyStatTotals {
  return {
    totalRides: row.totalRides,
    completedRides: row.completedRides,
    activeRides: row.activeRides,
    cancelledRides: row.cancelledRides,
    unpaidRides: row.unpaidRides,
    prepaidRides: row.prepaidRides,
    postpaidRides: row.postpaidRides,
    accountCalls: row.accountCalls,
    sourceDispatch: row.sourceDispatch,
    sourceDriverApp: row.sourceDriverApp,
    sourcePassengerApp: row.sourcePassengerApp,
    grossSubtotalCents: row.grossSubtotalCents,
  };
}
