import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { Idempotent } from '../idempotency/idempotency.decorator.js';
import { BookingsService } from './bookings.service.js';
import { AssignBookingDto } from './dto/assign-booking.dto.js';
import { BookingQuery } from './dto/booking-query.dto.js';
import { BookingStatusDto } from './dto/booking-status.dto.js';
import { CancelBookingDto } from './dto/cancel-booking.dto.js';
import { CreateBookingDto } from './dto/create-booking.dto.js';
import { LookupBookingQuery } from './dto/lookup-booking.dto.js';
import { UnassignBookingDto } from './dto/unassign-booking.dto.js';

@Controller('bookings')
@Roles(...STAFF_ROLES)
export class BookingsController {
  constructor(private readonly bookings: BookingsService) {}

  @Post()
  @Idempotent()
  @Roles('dispatcher', 'customer_care', 'branch_admin', 'super_admin')
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateBookingDto) {
    return this.bookings.create(dto, user);
  }

  @Get()
  findAll(@CurrentUser() user: AuthUser, @Query() query: BookingQuery) {
    return this.bookings.findAll(user, query);
  }

  @Get('lookup')
  lookup(@CurrentUser() user: AuthUser, @Query() query: LookupBookingQuery) {
    return this.bookings.lookup(query.trackingId, user);
  }

  @Get(':id')
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.bookings.findOne(id, user);
  }

  @Post(':id/assign')
  @HttpCode(HttpStatus.OK)
  @Roles('dispatcher', 'branch_admin', 'super_admin')
  assign(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: AssignBookingDto,
  ) {
    return this.bookings.assign(id, dto, user);
  }

  @Post(':id/unassign')
  @HttpCode(HttpStatus.OK)
  @Roles('dispatcher', 'branch_admin', 'super_admin')
  unassign(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UnassignBookingDto,
  ) {
    return this.bookings.unassign(id, dto, user);
  }

  @Post(':id/cancel')
  @HttpCode(HttpStatus.OK)
  cancel(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: CancelBookingDto,
  ) {
    return this.bookings.cancel(id, dto, user);
  }

  @Post(':id/status')
  @HttpCode(HttpStatus.OK)
  @Roles('branch_admin', 'super_admin')
  setStatus(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: BookingStatusDto,
  ) {
    return this.bookings.setStatus(id, dto, user);
  }
}
