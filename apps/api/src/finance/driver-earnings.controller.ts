import { Controller, Get, Query } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { DriverEarningsQuery } from './dto/driver-earnings-query.dto.js';
import { FinanceService } from './finance.service.js';

@Controller('driver/earnings')
@Roles('driver')
export class DriverEarningsController {
  constructor(private readonly finance: FinanceService) {}

  @Get()
  earnings(
    @CurrentUser() user: AuthUser,
    @Query() query: DriverEarningsQuery,
  ) {
    return this.finance.driverEarnings(user, query);
  }
}
