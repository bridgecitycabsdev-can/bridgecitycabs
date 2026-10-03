import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { UserThrottlerGuard } from '../common/user-throttler.guard.js';
import { AutocompleteQuery } from './dto/autocomplete-query.dto.js';
import { ReverseQuery } from './dto/reverse-query.dto.js';
import { SessionQuery } from './dto/session-query.dto.js';
import { PlacesService } from './places.service.js';

@Controller('places')
@Roles(...STAFF_ROLES, 'passenger')
@Throttle({ default: { limit: 40, ttl: 60_000 } })
@UseGuards(UserThrottlerGuard)
export class PlacesController {
  constructor(private readonly places: PlacesService) {}

  @Get('autocomplete')
  autocomplete(
    @CurrentUser() user: AuthUser,
    @Query() query: AutocompleteQuery,
  ) {
    return this.places.autocomplete(user, query.q, query.session);
  }

  @Get('reverse')
  reverse(@Query() query: ReverseQuery) {
    return this.places.reverse(query.lat, query.lng);
  }

  @Get(':placeId')
  details(@Param('placeId') placeId: string, @Query() query: SessionQuery) {
    return this.places.details(placeId, query.session);
  }
}
