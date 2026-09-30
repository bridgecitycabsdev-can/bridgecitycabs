import { Body, Controller, Param, ParseUUIDPipe, Patch, Post } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { CatalogService } from './catalog.service.js';
import { CreateVehicleModelDto } from './dto/create-vehicle-model.dto.js';
import { UpdateVehicleModelDto } from './dto/update-vehicle-model.dto.js';

@Controller('vehicle-models')
export class VehicleModelsController {
  constructor(private readonly catalog: CatalogService) {}

  @Post()
  @Roles('super_admin')
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateVehicleModelDto) {
    return this.catalog.createModel(dto, user);
  }

  @Patch(':id')
  @Roles('super_admin')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateVehicleModelDto,
  ) {
    return this.catalog.updateModel(id, dto, user);
  }
}
