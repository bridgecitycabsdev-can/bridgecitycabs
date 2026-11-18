import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  NotFoundException,
  Param,
  ParseUUIDPipe,
  Post,
  UseGuards,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { UserThrottlerGuard } from '../common/user-throttler.guard.js';
import { Idempotent } from '../idempotency/idempotency.decorator.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { RateBookingDto } from '../ratings/dto/rate-booking.dto.js';
import { RatingsService } from '../ratings/ratings.service.js';
import {
  PassengerCancelBookingDto,
  PassengerCreateBookingDto,
} from './dto/passenger-booking.dto.js';
import { PassengerBookingsService } from './passenger-bookings.service.js';

@Controller('passenger/bookings')
@Roles('passenger')
export class PassengerBookingsController {
  constructor(
    private readonly bookings: PassengerBookingsService,
    private readonly ratings: RatingsService,
    private readonly prisma: PrismaService,
  ) {}

  @Post()
  @Idempotent()
  @Throttle({
    default: {
      limit: Number(process.env.BOOKING_THROTTLE_LIMIT ?? 10) || 10,
      ttl: 60_000,
    },
  })
  @UseGuards(UserThrottlerGuard)
  @HttpCode(HttpStatus.CREATED)
  create(@CurrentUser() user: AuthUser, @Body() dto: PassengerCreateBookingDto) {
    return this.bookings.create(dto, user);
  }

  @Get('active')
  active(@CurrentUser() user: AuthUser) {
    return this.bookings.active(user);
  }

  @Get('history')
  history(@CurrentUser() user: AuthUser) {
    return this.bookings.history(user);
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

  @Post(':id/rate-driver')
  @HttpCode(HttpStatus.OK)
  async rateDriver(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RateBookingDto,
  ) {
    const passenger = await this.prisma.passenger.findUnique({
      where: { userId: user.userId },
      select: { id: true },
    });
    if (!passenger) throw new NotFoundException();
    return this.ratings.rateDriver(id, passenger.id, dto.stars, dto.comment);
  }
}
