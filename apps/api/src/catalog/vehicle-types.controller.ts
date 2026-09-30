import { Body, Controller, Get, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { PageQuery } from '../common/pagination.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { CatalogService } from './catalog.service.js';
import { CreateVehicleTypeDto } from './dto/create-vehicle-type.dto.js';
import { UpdateVehicleTypeDto } from './dto/update-vehicle-type.dto.js';

@Controller('vehicle-types')
export class VehicleTypesController {
  constructor(private readonly catalog: CatalogService) {}

  @Get()
  @Roles(...STAFF_ROLES)
  findAll(@Query() query: PageQuery) {
    return this.catalog.listTypes(query);
  }

  @Post()
  @Roles('super_admin')
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateVehicleTypeDto) {
    return this.catalog.createType(dto, user);
  }

  @Patch(':id')
  @Roles('super_admin')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateVehicleTypeDto,
  ) {
    return this.catalog.updateType(id, dto, user);
  }
}
