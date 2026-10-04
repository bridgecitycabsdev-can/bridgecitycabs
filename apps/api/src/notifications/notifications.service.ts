import {
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import type { Prisma } from '@prisma/client';
import { normalizePage, paginate } from '../common/pagination.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { PushService } from '../push/push.service.js';
import type { NotificationQuery } from './dto/notification-query.dto.js';
import { NOTIFICATION_CREATED } from './notifications.events.js';

function pushData(
  type: string,
  data?: object,
): Record<string, string> {
  const out: Record<string, string> = { type };
  if (!data) return out;
  for (const [key, value] of Object.entries(data)) {
    if (value == null) continue;
    out[key] = typeof value === 'string' ? value : JSON.stringify(value);
  }
  return out;
}

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly events: EventEmitter2,
    private readonly push: PushService,
  ) {}

  async notify(
    userId: string,
    type: string,
    title: string,
    body: string,
    data?: object,
  ) {
    const n = await this.prisma.notification.create({
      data: {
        userId,
        type,
        title,
        body,
        data: (data as Prisma.InputJsonValue) ?? undefined,
      },
    });
    this.events.emit(NOTIFICATION_CREATED, n);
    try {
      await this.push.sendToUser(userId, {
        title,
        body,
        data: pushData(type, data),
        highPriority: false,
        timeSensitive: false,
      });
    } catch (error) {
      // PushService already swallows provider failures; this is belt-and-suspenders.
      this.logger.warn(
        `Push for notification ${n.id} failed: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
    return this.present(n);
  }

  async list(userId: string, query: NotificationQuery) {
    const { page, pageSize, skip, take } = normalizePage(query);
    const where = {
      userId,
      ...(query.unreadOnly ? { readAt: null } : {}),
    };
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.notification.count({ where }),
      this.prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
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

  async unreadCount(userId: string) {
    const count = await this.prisma.notification.count({
      where: { userId, readAt: null },
    });
    return { count };
  }

  async markRead(userId: string, id: string) {
    const result = await this.prisma.notification.updateMany({
      where: { id, userId },
      data: { readAt: new Date() },
    });
    if (result.count === 0) throw new NotFoundException();
    const row = await this.prisma.notification.findUniqueOrThrow({
      where: { id },
    });
    return this.present(row);
  }

  async markAllRead(userId: string) {
    const result = await this.prisma.notification.updateMany({
      where: { userId, readAt: null },
      data: { readAt: new Date() },
    });
    return { updated: result.count };
  }

  private present(row: {
    id: string;
    userId: string;
    type: string;
    title: string;
    body: string;
    data: Prisma.JsonValue;
    readAt: Date | null;
    createdAt: Date;
  }) {
    return {
      id: row.id,
      userId: row.userId,
      type: row.type,
      title: row.title,
      body: row.body,
      data: row.data,
      readAt: row.readAt?.toISOString() ?? null,
      createdAt: row.createdAt.toISOString(),
    };
  }
}
