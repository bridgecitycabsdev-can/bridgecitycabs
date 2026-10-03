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
import { AccountEntriesQuery } from './dto/account-entries-query.dto.js';
import { ReverseTransactionDto } from './dto/reverse-transaction.dto.js';
import { FinanceService } from './finance.service.js';

@Controller('finance')
export class FinanceController {
  constructor(private readonly finance: FinanceService) {}

  @Post('transactions/:id/reverse')
  @HttpCode(HttpStatus.OK)
  @Roles('accounts_admin', 'super_admin')
  reverse(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ReverseTransactionDto,
  ) {
    return this.finance.reverse(user, id, dto.reason);
  }

  @Get('drivers/:id/balance')
  @Roles('accounts_admin', 'branch_admin', 'super_admin')
  driverBalance(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.finance.driverBalance(user, id);
  }

  @Get('accounts/:key/entries')
  @Roles('accounts_admin', 'branch_admin', 'super_admin')
  accountEntries(
    @CurrentUser() user: AuthUser,
    @Param('key') key: string,
    @Query() query: AccountEntriesQuery,
  ) {
    return this.finance.accountEntries(user, decodeURIComponent(key), query);
  }
}
