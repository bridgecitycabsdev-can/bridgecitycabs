import { Module } from '@nestjs/common';
import { BookingsModule } from '../bookings/bookings.module.js';
import { FleetModule } from '../fleet/fleet.module.js';
import { QueueModule } from '../jobs/queue.module.js';
import { DispatchJobsService } from './dispatch-jobs.service.js';
import { DispatchListener } from './dispatch.listener.js';
import { DriverOffersController } from './driver-offers.controller.js';
import { DriverOffersService } from './driver-offers.service.js';
import { MatchingService } from './matching.service.js';
import { OfferCloseListener } from './offer-close.listener.js';

@Module({
  imports: [BookingsModule, FleetModule, QueueModule],
  controllers: [DriverOffersController],
  providers: [
    MatchingService,
    DispatchJobsService,
    DispatchListener,
    DriverOffersService,
    OfferCloseListener,
  ],
  exports: [MatchingService, DispatchJobsService],
})
export class DispatchModule {}
