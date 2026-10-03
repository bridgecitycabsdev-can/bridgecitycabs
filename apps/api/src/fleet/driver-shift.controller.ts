import { Body, Controller, Get, HttpCode, HttpStatus, Post } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { DriverConsentDto } from './dto/driver-consent.dto.js';
import { LocationBatchDto } from './dto/location-batch.dto.js';
import { LocationConsentDto } from './dto/location-consent.dto.js';
import { StartShiftDto } from './dto/start-shift.dto.js';
import { FleetStateService } from './fleet-state.service.js';
import { LocationConsentService } from './location-consent.service.js';

@Controller('driver')
@Roles('driver')
export class DriverShiftController {
  constructor(
    private readonly fleet: FleetStateService,
    private readonly consent: LocationConsentService,
  ) {}

  @Get('location-notice')
  locationNotice() {
    return this.consent.notice();
  }

  @Post('location-consent')
  @HttpCode(HttpStatus.OK)
  locationConsent(@CurrentUser() user: AuthUser, @Body() dto: LocationConsentDto) {
    return this.consent.accept(user, dto.version);
  }

  @Post('consents')
  @HttpCode(HttpStatus.OK)
  consents(@CurrentUser() user: AuthUser, @Body() dto: DriverConsentDto) {
    return this.consent.acceptTyped(user, dto);
  }

  @Post('location/batch')
  @HttpCode(HttpStatus.OK)
  locationBatch(@CurrentUser() user: AuthUser, @Body() dto: LocationBatchDto) {
    return this.fleet.recordLocationBatch(user, dto.points);
  }

  @Post('shift/start')
  @HttpCode(HttpStatus.OK)
  start(@CurrentUser() user: AuthUser, @Body() dto: StartShiftDto) {
    return this.fleet.startShift(user, dto?.vehicleId);
  }

  @Post('shift/end')
  @HttpCode(HttpStatus.OK)
  end(@CurrentUser() user: AuthUser) {
    return this.fleet.endShift(user);
  }

  @Post('away')
  @HttpCode(HttpStatus.OK)
  away(@CurrentUser() user: AuthUser) {
    return this.fleet.away(user);
  }

  @Post('back')
  @HttpCode(HttpStatus.OK)
  back(@CurrentUser() user: AuthUser) {
    return this.fleet.back(user);
  }

  @Get('me/state')
  state(@CurrentUser() user: AuthUser) {
    return this.fleet.state(user);
  }
}
