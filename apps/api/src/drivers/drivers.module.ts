import { Module } from '@nestjs/common';
import { FleetModule } from '../fleet/fleet.module.js';
import { DriversController } from './drivers.controller.js';
import { DriversService } from './drivers.service.js';

@Module({
  imports: [FleetModule],
  controllers: [DriversController],
  providers: [DriversService],
})
export class DriversModule {}
