import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { Idempotent } from '../idempotency/idempotency.decorator.js';
import {
  PassengerCancelBookingDto,
  PassengerCreateBookingDto,
} from './dto/passenger-booking.dto.js';
import { PassengerBookingsService } from './passenger-bookings.service.js';

@Controller('passenger/bookings')
@Roles('passenger')
export class PassengerBookingsController {
  constructor(private readonly bookings: PassengerBookingsService) {}

  @Post()
  @Idempotent()
  @HttpCode(HttpStatus.CREATED)
  create(@CurrentUser() user: AuthUser, @Body() dto: PassengerCreateBookingDto) {
    return this.bookings.create(dto, user);
  }

  @Get('active')
  active(@CurrentUser() user: AuthUser) {
    return this.bookings.active(user);
  }

  @Get(':id')
  get(@CurrentUser() user: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.bookings.get(user, id);
  }

  @Post(':id/cancel')
  @HttpCode(HttpStatus.OK)
  cancel(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: PassengerCancelBookingDto,
  ) {
    return this.bookings.cancel(user, id, dto);
  }

  @Post(':id/retry')
  @HttpCode(HttpStatus.OK)
  retry(@CurrentUser() user: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.bookings.retry(user, id);
  }
}
