import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { PageQuery } from '../common/pagination.js';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { LocationHistoryService } from '../fleet/location-history.service.js';
import { RatingsService } from '../ratings/ratings.service.js';
import { DriversService } from './drivers.service.js';
import { CreateDriverDto } from './dto/create-driver.dto.js';
import { DriverOptionsQuery } from './dto/driver-options-query.dto.js';
import { DriverQuery } from './dto/driver-query.dto.js';
import { ForceOfflineDto } from './dto/force-offline.dto.js';
import { LocationHistoryQuery } from './dto/location-history-query.dto.js';
import { SuspendDriverDto } from './dto/suspend-driver.dto.js';
import { UpdateDriverDto } from './dto/update-driver.dto.js';

@Controller('drivers')
@Roles(...STAFF_ROLES)
export class DriversController {
  constructor(
    private readonly drivers: DriversService,
    private readonly fleet: FleetStateService,
    private readonly locations: LocationHistoryService,
    private readonly ratings: RatingsService,
  ) {}

  @Get(':id/locations')
  @Roles('super_admin', 'branch_admin')
  locationsHistory(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Query() query: LocationHistoryQuery,
  ) {
    return this.locations.read(user, id, query);
  }

  @Get(':id/ratings')
  listRatings(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Query() query: PageQuery,
  ) {
    return this.ratings.listForDriver(id, query, user);
  }

  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateDriverDto) {
    return this.drivers.create(dto, user);
  }

  @Get()
  findAll(@CurrentUser() user: AuthUser, @Query() query: DriverQuery) {
    return this.drivers.findAll(user, query);
  }

  @Get('options')
  options(@CurrentUser() user: AuthUser, @Query() query: DriverOptionsQuery) {
    return this.drivers.options(user, query);
  }

  @Get(':id')
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.drivers.findOne(id, user);
  }

  @Patch(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateDriverDto,
  ) {
    return this.drivers.update(id, dto, user);
  }

  @Post(':id/approve')
  @HttpCode(HttpStatus.OK)
  @Roles('super_admin', 'branch_admin', 'hr_admin')
  approve(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.drivers.approve(id, user);
  }

  @Post(':id/force-offline')
  @HttpCode(HttpStatus.OK)
  forceOffline(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: ForceOfflineDto,
  ) {
    return this.fleet.forceOffline(id, user, dto.reason);
  }

  @Post(':id/suspend')
  @HttpCode(HttpStatus.OK)
  suspend(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: SuspendDriverDto,
  ) {
    return this.drivers.suspend(id, dto, user);
  }
}
