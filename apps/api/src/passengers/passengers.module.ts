import { Module } from '@nestjs/common';
import { BookingsModule } from '../bookings/bookings.module.js';
import { FaresModule } from '../fares/fares.module.js';
import { FleetModule } from '../fleet/fleet.module.js';
import { PaymentsModule } from '../payments/payments.module.js';
import { PassengerBookingsController } from './passenger-bookings.controller.js';
import { PassengerBookingsService } from './passenger-bookings.service.js';
import { PassengerFaresController } from './passenger-fares.controller.js';
import { PassengerPaymentMethodsController } from './passenger-payment-methods.controller.js';
import { PassengerTripController } from './passenger-trip.controller.js';
import { PassengerTripService } from './passenger-trip.service.js';
import { PassengersController } from './passengers.controller.js';
import { PassengersService } from './passengers.service.js';

@Module({
  imports: [FleetModule, FaresModule, BookingsModule, PaymentsModule],
  controllers: [
    PassengersController,
    PassengerFaresController,
    PassengerBookingsController,
    PassengerTripController,
    PassengerPaymentMethodsController,
  ],
  providers: [PassengersService, PassengerTripService, PassengerBookingsService],
  exports: [PassengerBookingsService],
})
export class PassengersModule {}
