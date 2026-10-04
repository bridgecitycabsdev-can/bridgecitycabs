import { Controller, Get, Query } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { DashboardService } from './dashboard.service.js';
import {
  DashboardBranchQuery,
  DashboardChartQuery,
  DashboardDateQuery,
} from './dto/dashboard-query.dto.js';

@Controller('dashboard')
@Roles(...STAFF_ROLES)
export class DashboardController {
  constructor(private readonly dashboard: DashboardService) {}

  @Get('metrics')
  metrics(@CurrentUser() user: AuthUser, @Query() query: DashboardBranchQuery) {
    return this.dashboard.metrics(user, query);
  }

  @Get('daily-stats')
  dailyStats(
    @CurrentUser() user: AuthUser,
    @Query() query: DashboardDateQuery,
  ) {
    return this.dashboard.dailyStats(user, query);
  }

  @Get('rides-chart')
  ridesChart(
    @CurrentUser() user: AuthUser,
    @Query() query: DashboardChartQuery,
  ) {
    return this.dashboard.ridesChart(user, query);
  }

  @Get('booking-source')
  bookingSource(
    @CurrentUser() user: AuthUser,
    @Query() query: DashboardDateQuery,
  ) {
    return this.dashboard.bookingSource(user, query);
  }
}
