import { Module } from '@nestjs/common';
import { CatalogService } from './catalog.service.js';
import { VehicleMakesController } from './vehicle-makes.controller.js';
import { VehicleModelsController } from './vehicle-models.controller.js';
import { VehicleTypesController } from './vehicle-types.controller.js';

@Module({
  controllers: [
    VehicleTypesController,
    VehicleMakesController,
    VehicleModelsController,
  ],
  providers: [CatalogService],
})
export class CatalogModule {}
