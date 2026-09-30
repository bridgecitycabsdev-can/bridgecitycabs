import { Module } from '@nestjs/common';
import {
  DISTANCE_SERVICE,
  HaversineDistanceService,
} from './distance.service.js';
import { FareRulesController } from './fare-rules.controller.js';
import { FareRulesService } from './fare-rules.service.js';
import { FaresController } from './fares.controller.js';
import { FaresService } from './fares.service.js';

@Module({
  controllers: [FareRulesController, FaresController],
  providers: [
    FareRulesService,
    FaresService,
    { provide: DISTANCE_SERVICE, useClass: HaversineDistanceService },
  ],
  exports: [FareRulesService, FaresService, DISTANCE_SERVICE],
})
export class FaresModule {}
