import { Inject, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Redis } from 'ioredis';
import { PrismaService } from '../prisma/prisma.service.js';
import { REDIS } from '../redis/redis.constants.js';
import { paymentPendingAlertKey } from '../redis/redis.keys.js';

/** Counts stuck PAYMENT_PENDING bookings. Never auto-confirms money. */
@Injectable()
export class PaymentPendingAlertService {
  private readonly logger = new Logger(PaymentPendingAlertService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  async sweep(now = new Date()) {
    const hours = readInt(this.config, 'PAYMENT_PENDING_ALERT_HOURS', 12);
    const cutoff = new Date(now.getTime() - hours * 3_600_000);
    const branches = await this.prisma.branch.findMany({
      select: { id: true },
    });
    const grouped = await this.prisma.booking.groupBy({
      by: ['branchId'],
      where: {
        status: 'PAYMENT_PENDING',
        completedAt: { lt: cutoff },
      },
      _count: { _all: true },
    });
    const counts = new Map(
      grouped.map((row) => [row.branchId, row._count._all] as const),
    );
    let total = 0;
    for (const branch of branches) {
      const count = counts.get(branch.id) ?? 0;
      total += count;
      await this.redis.set(paymentPendingAlertKey(branch.id), String(count));
    }
    this.logger.log(
      `Payment-pending alert: ${total} booking(s) older than ${hours}h across ${branches.length} branch(es)`,
    );
    return { total, hours, cutoff };
  }
}

function readInt(config: ConfigService, key: string, fallback: number) {
  const raw = config.get<string | number>(key);
  if (raw === undefined || raw === '') return fallback;
  const value = typeof raw === 'number' ? raw : Number(raw);
  if (!Number.isFinite(value) || value < 0) return fallback;
  return Math.floor(value);
}
