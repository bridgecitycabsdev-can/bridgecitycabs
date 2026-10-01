import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { DeclineOfferDto } from './dto/decline-offer.dto.js';
import { DriverOffersService } from './driver-offers.service.js';

@Controller('driver/offers')
@Roles('driver')
export class DriverOffersController {
  constructor(private readonly offers: DriverOffersService) {}

  @Post(':id/accept')
  @HttpCode(HttpStatus.OK)
  accept(@CurrentUser() user: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.offers.accept(user, id);
  }

  @Post(':id/decline')
  @HttpCode(HttpStatus.OK)
  decline(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: DeclineOfferDto,
  ) {
    return this.offers.decline(user, id, dto.reason);
  }
}
