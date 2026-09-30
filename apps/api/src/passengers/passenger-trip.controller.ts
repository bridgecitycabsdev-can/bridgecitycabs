import { Controller, Get, Param, ParseUUIDPipe } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { PassengerTripService } from './passenger-trip.service.js';

@Controller('passenger/bookings')
@Roles('passenger')
export class PassengerTripController {
  constructor(private readonly trips: PassengerTripService) {}

  @Get(':id/driver-location')
  driverLocation(@CurrentUser() user: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.trips.driverLocation(user, id);
  }
}
