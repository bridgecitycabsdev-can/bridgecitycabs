import { Module } from '@nestjs/common';
import { DriverShiftController } from './driver-shift.controller.js';
import { FleetController } from './fleet.controller.js';
import { FleetQueryService } from './fleet-query.service.js';
import { FleetStateService } from './fleet-state.service.js';
import { LocationConsentService } from './location-consent.service.js';
import { LocationHistoryService } from './location-history.service.js';

@Module({
  controllers: [DriverShiftController, FleetController],
  providers: [FleetStateService, FleetQueryService, LocationConsentService, LocationHistoryService],
  exports: [FleetStateService, LocationHistoryService],
})
export class FleetModule {}
