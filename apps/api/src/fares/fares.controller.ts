import { Body, Controller, Post } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { QuoteBatchDto } from './dto/quote-batch.dto.js';
import { QuoteFareDto } from './dto/quote-fare.dto.js';
import { FaresService } from './fares.service.js';

@Controller('fares')
@Roles(...STAFF_ROLES)
export class FaresController {
  constructor(private readonly fares: FaresService) {}

  @Post('quote')
  quote(@CurrentUser() user: AuthUser, @Body() dto: QuoteFareDto) {
    return this.fares.quote(dto, user);
  }

  @Post('quotes')
  quotes(@CurrentUser() user: AuthUser, @Body() dto: QuoteBatchDto) {
    return this.fares.quotes(dto, user);
  }
}
