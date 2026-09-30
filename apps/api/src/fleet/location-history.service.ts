import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import { normalizePage, paginate, type PageQuery } from '../common/pagination.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { locationHistoryWindow } from './location-history-window.js';

@Injectable()
export class LocationHistoryService {
  constructor(private readonly prisma: PrismaService) {}

  async read(
    user: AuthUser,
    driverId: string,
    query: PageQuery & { from?: string; to?: string },
  ) {
    if (user.role !== 'super_admin' && !user.branchId) throw new NotFoundException();
    const driver = await this.prisma.driver.findFirst({
      where: { id: driverId, ...branchWhere(user) },
      select: { id: true, branchId: true },
    });
    if (!driver) throw new NotFoundException();
    const window = locationHistoryWindow(query);
    if ('error' in window) throw new BadRequestException(window.error);

    await this.prisma.locationAccessLog.create({
      data: {
        actorUserId: user.userId,
        driverId: driver.id,
        branchId: driver.branchId,
        from: window.from,
        to: window.to,
      },
    });

    const page = normalizePage(query);
    const where = {
      driverId: driver.id,
      recordedAt: { gte: window.from, lt: window.to },
    };
    const [rows, total] = await Promise.all([
      this.prisma.driverLocationLog.findMany({
        where,
        orderBy: { recordedAt: 'asc' },
        skip: page.skip,
        take: page.take,
      }),
      this.prisma.driverLocationLog.count({ where }),
    ]);
    return paginate(
      rows.map((row) => ({
        id: row.id.toString(),
        lat: row.lat,
        lng: row.lng,
        speedMps: row.speedMps,
        heading: row.heading,
        accuracyM: row.accuracyM,
        bookingId: row.bookingId,
        recordedAt: row.recordedAt.toISOString(),
      })),
      total,
      page,
    );
  }
}
