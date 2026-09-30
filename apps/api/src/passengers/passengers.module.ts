import { Module } from '@nestjs/common';
import { FleetModule } from '../fleet/fleet.module.js';
import { PassengerTripController } from './passenger-trip.controller.js';
import { PassengerTripService } from './passenger-trip.service.js';
import { PassengersController } from './passengers.controller.js';
import { PassengersService } from './passengers.service.js';

@Module({
  imports: [FleetModule],
  controllers: [PassengersController, PassengerTripController],
  providers: [PassengersService, PassengerTripService],
})
export class PassengersModule {}
