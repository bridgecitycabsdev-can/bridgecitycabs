import { Module } from '@nestjs/common';
import { PassengersController } from './passengers.controller.js';
import { PassengersService } from './passengers.service.js';

@Module({
  controllers: [PassengersController],
  providers: [PassengersService],
})
export class PassengersModule {}
