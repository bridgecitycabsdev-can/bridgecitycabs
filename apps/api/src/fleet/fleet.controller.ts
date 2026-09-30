import { Controller, Get, Query } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { FleetQuery } from './dto/fleet-query.dto.js';
import { FleetQueryService } from './fleet-query.service.js';

const FLEET_ROLES = ['super_admin', 'branch_admin', 'dispatcher', 'customer_care'] as const;

@Controller('fleet')
@Roles(...FLEET_ROLES)
export class FleetController {
  constructor(private readonly fleet: FleetQueryService) {}

  @Get('drivers')
  drivers(@CurrentUser() user: AuthUser, @Query() query: FleetQuery) {
    return this.fleet.drivers(user, query.branchId);
  }

  @Get('summary')
  summary(@CurrentUser() user: AuthUser, @Query() query: FleetQuery) {
    return this.fleet.summary(user, query.branchId);
  }
}
