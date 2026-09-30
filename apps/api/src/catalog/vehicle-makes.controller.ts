import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { PageQuery } from '../common/pagination.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { CatalogService } from './catalog.service.js';
import { CreateVehicleMakeDto } from './dto/create-vehicle-make.dto.js';
import { UpdateVehicleMakeDto } from './dto/update-vehicle-make.dto.js';

@Controller('vehicle-makes')
export class VehicleMakesController {
  constructor(private readonly catalog: CatalogService) {}

  @Get()
  @Roles(...STAFF_ROLES)
  findAll(@Query() query: PageQuery) {
    return this.catalog.listMakes(query);
  }

  @Get(':id/models')
  @Roles(...STAFF_ROLES)
  findModels(@Param('id', ParseUUIDPipe) id: string, @Query() query: PageQuery) {
    return this.catalog.listModels(id, query);
  }

  @Post()
  @Roles('super_admin')
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateVehicleMakeDto) {
    return this.catalog.createMake(dto, user);
  }

  @Patch(':id')
  @Roles('super_admin')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateVehicleMakeDto,
  ) {
    return this.catalog.updateMake(id, dto, user);
  }
}
