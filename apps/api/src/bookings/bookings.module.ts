import { Module } from '@nestjs/common';
import { FaresModule } from '../fares/fares.module.js';
import { FleetModule } from '../fleet/fleet.module.js';
import { QueueModule } from '../jobs/queue.module.js';
import { LedgerModule } from '../ledger/ledger.module.js';
import { PaymentsModule } from '../payments/payments.module.js';
import { BookingStateService } from './booking-state.service.js';
import { BookingsController } from './bookings.controller.js';
import { BookingsService } from './bookings.service.js';
import { DriverBookingController } from './driver-booking.controller.js';

@Module({
  imports: [FaresModule, FleetModule, QueueModule, LedgerModule, PaymentsModule],
  controllers: [BookingsController, DriverBookingController],
  providers: [BookingsService, BookingStateService],
  exports: [BookingsService, BookingStateService],
})
export class BookingsModule {}
