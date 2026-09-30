import { Module } from '@nestjs/common';
import { FaresModule } from '../fares/fares.module.js';
import { BookingStateService } from './booking-state.service.js';
import { BookingsController } from './bookings.controller.js';
import { BookingsService } from './bookings.service.js';

@Module({
  imports: [FaresModule],
  controllers: [BookingsController],
  providers: [BookingsService, BookingStateService],
  exports: [BookingsService, BookingStateService],
})
export class BookingsModule {}
