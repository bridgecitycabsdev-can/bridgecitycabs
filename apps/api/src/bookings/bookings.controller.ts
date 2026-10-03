import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { Idempotent } from '../idempotency/idempotency.decorator.js';
import { BookingsService } from './bookings.service.js';
import { AdjustFareDto } from './dto/adjust-fare.dto.js';
import { AssignBookingDto } from './dto/assign-booking.dto.js';
import { DispatchModeDto } from './dto/dispatch-mode.dto.js';
import { BookingQuery } from './dto/booking-query.dto.js';
import { BookingStatusDto } from './dto/booking-status.dto.js';
import { CancelBookingDto } from './dto/cancel-booking.dto.js';
import { CreateBookingDto } from './dto/create-booking.dto.js';
import { LookupBookingQuery } from './dto/lookup-booking.dto.js';
import { UnassignBookingDto } from './dto/unassign-booking.dto.js';
import { UpdateBookingDto } from './dto/update-booking.dto.js';

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

  @Patch(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateBookingDto,
  ) {
    return this.bookings.update(id, dto, user);
  }

  @Post(':id/retry-search')
  @HttpCode(HttpStatus.OK)
  @Roles('dispatcher', 'customer_care', 'branch_admin', 'super_admin')
  retrySearch(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.bookings.retrySearch(id, user);
  }

  @Post(':id/dispatch-mode')
  @HttpCode(HttpStatus.OK)
  @Roles('dispatcher', 'branch_admin', 'super_admin')
  dispatchMode(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: DispatchModeDto,
  ) {
    return this.bookings.setDispatchMode(id, dto, user);
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

  @Post(':id/payment/cash')
  @HttpCode(HttpStatus.OK)
  @Roles('branch_admin', 'accounts_admin', 'super_admin')
  collectCash(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.bookings.collectCashAsStaff(user, id);
  }

  @Post(':id/adjust-fare')
  @HttpCode(HttpStatus.OK)
  @Roles('branch_admin', 'accounts_admin')
  adjustFare(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: AdjustFareDto,
  ) {
    return this.bookings.adjustFare(user, id, dto);
  }
}
