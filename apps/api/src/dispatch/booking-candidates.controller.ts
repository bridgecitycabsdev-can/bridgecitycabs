import {
  Controller,
  Get,
  NotFoundException,
  Param,
  ParseUUIDPipe,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { MatchingService } from './matching.service.js';

@Controller('bookings')
@Roles(...STAFF_ROLES)
export class BookingCandidatesController {
  constructor(
    private readonly matching: MatchingService,
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  @Get(':id/candidates')
  async candidates(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    if (user.role !== 'super_admin' && !user.branchId) throw new NotFoundException();
    const booking = await this.prisma.booking.findFirst({
      where: { id, ...branchWhere(user) },
      select: { id: true },
    });
    if (!booking) throw new NotFoundException();
    const radiusKm = readPositive(this.config, 'CANDIDATE_RADIUS_KM', 10);
    return this.matching.listNearby(booking.id, radiusKm);
  }
}

function readPositive(config: ConfigService, key: string, fallback: number) {
  const raw = config.get<string | number>(key);
  if (raw === undefined || raw === '') return fallback;
  const value = typeof raw === 'number' ? raw : Number(raw);
  if (!Number.isFinite(value) || value <= 0) return fallback;
  return value;
}
