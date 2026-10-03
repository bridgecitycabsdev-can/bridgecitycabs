import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  NotFoundException,
  Param,
  ParseUUIDPipe,
  Post,
} from '@nestjs/common';
import type { BookingStatus } from '@prisma/client';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { BookingStateService } from './booking-state.service.js';
import { BookingsService } from './bookings.service.js';
import { ReleaseBookingDto } from './dto/release-booking.dto.js';

@Controller('driver/bookings')
@Roles('driver')
export class DriverBookingController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly state: BookingStateService,
    private readonly bookings: BookingsService,
  ) {}

  @Post(':id/arriving')
  @HttpCode(HttpStatus.OK)
  arriving(@CurrentUser() user: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.move(user, id, 'DRIVER_ARRIVING');
  }

  @Post(':id/arrived')
  @HttpCode(HttpStatus.OK)
  arrived(@CurrentUser() user: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.move(user, id, 'DRIVER_ARRIVED');
  }

  @Post(':id/start')
  @HttpCode(HttpStatus.OK)
  start(@CurrentUser() user: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.move(user, id, 'TRIP_STARTED');
  }

  @Post(':id/complete')
  @HttpCode(HttpStatus.OK)
  complete(@CurrentUser() user: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.move(user, id, 'TRIP_COMPLETED');
  }

  @Post(':id/release')
  @HttpCode(HttpStatus.OK)
  release(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReleaseBookingDto,
  ) {
    return this.bookings.release(user, id, dto);
  }

  private async move(user: AuthUser, bookingId: string, to: BookingStatus) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
      select: { id: true },
    });
    if (!driver) throw new NotFoundException();
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { driverId: true },
    });
    if (!booking || booking.driverId !== driver.id) throw new NotFoundException();
    return this.state.transition(bookingId, to, { type: 'DRIVER', userId: user.userId });
  }
}
