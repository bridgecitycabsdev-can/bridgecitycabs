import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { branchDayWindow, shiftSeconds } from './fleet-day.js';
import { countFleetChips } from './fleet-chips.js';
import { FleetStateService } from './fleet-state.service.js';

@Injectable()
export class FleetQueryService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly fleet: FleetStateService,
  ) {}

  async drivers(user: AuthUser, requestedBranchId?: string) {
    const branchId = await this.branchId(user, requestedBranchId);
    return { branchId, drivers: await this.fleet.fleetDrivers(branchId) };
  }

  async summary(user: AuthUser, requestedBranchId?: string, now = new Date()) {
    const branchId = await this.branchId(user, requestedBranchId);
    const branch = await this.prisma.branch.findUnique({
      where: { id: branchId },
      select: { timezone: true },
    });
    if (!branch) throw new NotFoundException();
    const live = await this.fleet.fleetDrivers(branchId);
    const online = live.filter((driver) => driver.status !== 'OFFLINE');
    const ids = online.map((driver) => driver.id);
    const window = branchDayWindow(branch.timezone, now);
    const [shifts, jobs] = await Promise.all([
      ids.length
        ? this.prisma.driverShift.findMany({
            where: { driverId: { in: ids }, endedAt: null },
            select: { driverId: true, startedAt: true },
          })
        : [],
      ids.length
        ? this.prisma.booking.groupBy({
            by: ['driverId'],
            where: {
              driverId: { in: ids },
              completedAt: { gte: window.start, lt: window.end },
            },
            _count: { _all: true },
          })
        : [],
    ]);
    const startedAt = new Map(shifts.map((shift) => [shift.driverId, shift.startedAt]));
    const jobsToday = new Map(
      jobs.flatMap((row) => (row.driverId ? [[row.driverId, row._count._all] as const] : [])),
    );
    return {
      branchId,
      counts: countFleetChips(online.map((driver) => driver.status)),
      drivers: online.map((driver) => ({
        id: driver.id,
        shiftSeconds: startedAt.has(driver.id)
          ? shiftSeconds(startedAt.get(driver.id)!, now)
          : 0,
        jobsToday: jobsToday.get(driver.id) ?? 0,
      })),
    };
  }

  private async branchId(user: AuthUser, requestedBranchId?: string) {
    if (user.role !== 'super_admin' && !user.branchId) throw new NotFoundException();
    const scope = branchWhere(user, requestedBranchId);
    const branchId = scope.branchId;
    if (!branchId) throw new BadRequestException('branchId is required');
    const branch = await this.prisma.branch.findUnique({
      where: { id: branchId },
      select: { id: true },
    });
    if (!branch) throw new NotFoundException();
    return branch.id;
  }
}
