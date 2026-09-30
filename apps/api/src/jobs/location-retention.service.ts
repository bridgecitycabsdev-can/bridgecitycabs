import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service.js';

/**
 * LOCATION_RETENTION_DAYS defaults to 90. That period is a placeholder:
 * confirm it with the insurer and legal counsel before treating it as final.
 */
@Injectable()
export class LocationRetentionService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  async purge(now = new Date()) {
    const days = this.retentionDays();
    const cutoff = new Date(now.getTime() - days * 24 * 60 * 60 * 1000);
    const result = await this.prisma.driverLocationLog.deleteMany({
      where: { recordedAt: { lt: cutoff } },
    });
    return result.count;
  }

  private retentionDays() {
    const raw = Number(this.config.get('LOCATION_RETENTION_DAYS') ?? 90);
    return Number.isFinite(raw) && raw > 0 ? Math.floor(raw) : 90;
  }
}
