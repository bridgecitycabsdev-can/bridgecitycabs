import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module.js';
import { BookingsModule } from '../bookings/bookings.module.js';
import { FaresModule } from '../fares/fares.module.js';
import { FleetModule } from '../fleet/fleet.module.js';
import { PaymentsModule } from '../payments/payments.module.js';
import { PromosModule } from '../promos/promos.module.js';
import { RatingsModule } from '../ratings/ratings.module.js';
import { PassengerBookingsController } from './passenger-bookings.controller.js';
import { PassengerBookingsService } from './passenger-bookings.service.js';
import { PassengerFaresController } from './passenger-fares.controller.js';
import { PassengerPaymentMethodsController } from './passenger-payment-methods.controller.js';
import { PassengerProfileController } from './passenger-profile.controller.js';
import { PassengerProfileService } from './passenger-profile.service.js';
import { PassengerTripController } from './passenger-trip.controller.js';
import { PassengerTripService } from './passenger-trip.service.js';
import { PassengersController } from './passengers.controller.js';
import { PassengersService } from './passengers.service.js';

@Module({
  imports: [
    AuthModule,
    FleetModule,
    FaresModule,
    BookingsModule,
    PaymentsModule,
    PromosModule,
    RatingsModule,
  ],
  controllers: [
    PassengersController,
    PassengerFaresController,
    PassengerBookingsController,
    PassengerTripController,
    PassengerPaymentMethodsController,
    PassengerProfileController,
  ],
  providers: [
    PassengersService,
    PassengerTripService,
    PassengerBookingsService,
    PassengerProfileService,
  ],
  exports: [PassengerBookingsService],
})
export class PassengersModule {}
