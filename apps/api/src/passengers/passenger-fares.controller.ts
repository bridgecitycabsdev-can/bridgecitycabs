import { Body, Controller, Post } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { QuoteBatchDto } from '../fares/dto/quote-batch.dto.js';
import { QuoteFareDto } from '../fares/dto/quote-fare.dto.js';
import { FaresService } from '../fares/fares.service.js';

@Controller('passenger/fares')
@Roles('passenger')
export class PassengerFaresController {
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
