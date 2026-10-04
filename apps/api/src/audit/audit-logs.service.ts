import { Injectable } from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import { normalizePage, paginate } from '../common/pagination.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { AuditLogQuery } from './dto/audit-log-query.dto.js';

@Injectable()
export class AuditLogsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(query: AuditLogQuery) {
    const { page, pageSize, skip, take } = normalizePage(query);
    const where: Prisma.AuditLogWhereInput = {
      ...(query.entity ? { entity: query.entity } : {}),
      ...(query.entityId ? { entityId: query.entityId } : {}),
      ...(query.actorUserId ? { actorUserId: query.actorUserId } : {}),
      ...(query.from || query.to
        ? {
            createdAt: {
              ...(query.from ? { gte: query.from } : {}),
              ...(query.to ? { lte: query.to } : {}),
            },
          }
        : {}),
    };

    const [total, rows] = await this.prisma.$transaction([
      this.prisma.auditLog.count({ where }),
      this.prisma.auditLog.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
      }),
    ]);

    return paginate(rows, total, { page, pageSize });
  }
}
