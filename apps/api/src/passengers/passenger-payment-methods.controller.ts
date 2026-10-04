import {
  Controller,
  Delete,
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
import { PassengerPaymentMethodsService } from '../payments/passenger-payment-methods.service.js';

@Controller('passenger/payment-methods')
@Roles('passenger')
export class PassengerPaymentMethodsController {
  constructor(private readonly methods: PassengerPaymentMethodsService) {}

  /** Creates (or reuses) StripeCustomer and returns a SetupIntent client secret. */
  @Post('setup-intent')
  @HttpCode(HttpStatus.OK)
  setupIntent(@CurrentUser() user: AuthUser) {
    return this.methods.createSetupIntent(user);
  }

  @Get()
  list(@CurrentUser() user: AuthUser) {
    return this.methods.list(user);
  }

  @Post(':id/default')
  @HttpCode(HttpStatus.OK)
  setDefault(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.methods.setDefault(user, id);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.methods.remove(user, id);
  }
}
