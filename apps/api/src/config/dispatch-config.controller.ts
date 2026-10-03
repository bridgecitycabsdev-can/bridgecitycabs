import {
  BadRequestException,
  Controller,
  ForbiddenException,
  Get,
  Inject,
  NotFoundException,
  Query,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Redis } from 'ioredis';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { REDIS } from '../redis/redis.constants.js';
import { paymentPendingAlertKey } from '../redis/redis.keys.js';
import { DispatchConfigQuery } from './dto/dispatch-config-query.dto.js';

@Controller('config')
@Roles(...STAFF_ROLES)
export class DispatchConfigController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    @Inject(REDIS) private readonly redis: Redis,
  ) {}

  @Get('dispatch')
  async dispatch(@CurrentUser() user: AuthUser, @Query() query: DispatchConfigQuery) {
    const branchId = await this.branchId(user, query.branchId);
    const branch = await this.prisma.branch.findUnique({
      where: { id: branchId },
      select: {
        timezone: true,
        autoDispatchDefault: true,
        offerTimeoutSeconds: true,
        centerLat: true,
        centerLng: true,
      },
    });
    if (!branch) throw new NotFoundException();
    const rawAlert = await this.redis.get(paymentPendingAlertKey(branchId));
    const paymentPendingAlertCount = Math.max(0, Number(rawAlert) || 0);
    return {
      scheduleMinLeadMinutes: readInt(this.config, 'BOOKING_MIN_LEAD_MINUTES', 15),
      scheduleMaxDays: readInt(this.config, 'BOOKING_MAX_ADVANCE_DAYS', 30),
      offerTimeoutSeconds: branch.offerTimeoutSeconds,
      fixedFareMaxCents: readInt(this.config, 'FIXED_FARE_MAX_CENTS', 50_000),
      timezone: branch.timezone,
      autoDispatchDefault: branch.autoDispatchDefault,
      /** Stuck PAYMENT_PENDING count from the daily job. Never auto-confirms cash. */
      paymentPendingAlertCount,
      branchCenter:
        branch.centerLat == null || branch.centerLng == null
          ? null
          : { lat: branch.centerLat, lng: branch.centerLng },
    };
  }

  private async branchId(user: AuthUser, requested?: string) {
    if (user.role === 'super_admin') {
      if (!requested) throw new BadRequestException('branchId is required');
      return requested;
    }
    if (!user.branchId) throw new ForbiddenException();
    return user.branchId;
  }
}

function readInt(config: ConfigService, key: string, fallback: number) {
  const raw = config.get<string | number>(key);
  if (raw === undefined || raw === '') return fallback;
  const value = typeof raw === 'number' ? raw : Number(raw);
  if (!Number.isFinite(value) || value < 0) return fallback;
  return Math.floor(value);
}
