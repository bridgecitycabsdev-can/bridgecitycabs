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
import { Audited } from '../audit/audited.decorator.js';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { AccountEntriesQuery } from './dto/account-entries-query.dto.js';
import { ClosingPeriodQuery } from './dto/closing-period-query.dto.js';
import { GenerateInvoiceDto } from './dto/generate-invoice.dto.js';
import { GenerateInvoicePdfDto } from './dto/generate-invoice-pdf.dto.js';
import { InvoiceQuery } from './dto/invoice-query.dto.js';
import { MarkPayoutFailedDto } from './dto/mark-payout-failed.dto.js';
import { MarkPayoutSentDto } from './dto/mark-payout-sent.dto.js';
import { PayoutQuery } from './dto/payout-query.dto.js';
import { RecordInvoicePaymentDto } from './dto/record-invoice-payment.dto.js';
import { ReverseTransactionDto } from './dto/reverse-transaction.dto.js';
import { RunClosingQuery } from './dto/run-closing-query.dto.js';
import { RunPayoutsQuery } from './dto/run-payouts-query.dto.js';
import { FinanceService } from './finance.service.js';
import { InvoiceService } from './invoice.service.js';
import { WeeklyClosingService } from './weekly-closing.service.js';

@Controller('finance')
export class FinanceController {
  constructor(
    private readonly finance: FinanceService,
    private readonly closing: WeeklyClosingService,
    private readonly invoices: InvoiceService,
  ) {}

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

  @Post('payouts/run')
  @HttpCode(HttpStatus.OK)
  @Roles('accounts_admin', 'super_admin')
  runPayouts(@CurrentUser() user: AuthUser, @Query() query: RunPayoutsQuery) {
    return this.finance.runPayouts(user, query.branchId);
  }

  @Get('payouts')
  @Roles('accounts_admin', 'branch_admin', 'super_admin')
  listPayouts(@CurrentUser() user: AuthUser, @Query() query: PayoutQuery) {
    return this.finance.listPayouts(user, query);
  }

  @Post('payouts/:id/mark-sent')
  @HttpCode(HttpStatus.OK)
  @Roles('accounts_admin', 'super_admin')
  markSent(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: MarkPayoutSentDto,
  ) {
    return this.finance.markPayoutSent(user, id, dto);
  }

  @Post('payouts/:id/mark-failed')
  @HttpCode(HttpStatus.OK)
  @Roles('accounts_admin', 'super_admin')
  markFailed(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: MarkPayoutFailedDto,
  ) {
    return this.finance.markPayoutFailed(user, id, dto);
  }

  @Post('closing-periods/run')
  @HttpCode(HttpStatus.OK)
  @Roles('accounts_admin', 'super_admin')
  runClosing(@CurrentUser() user: AuthUser, @Query() query: RunClosingQuery) {
    return this.closing.runOnDemand(user, query.branchId, query.weekStart);
  }

  @Get('closing-periods')
  @Roles('accounts_admin', 'branch_admin', 'super_admin')
  listClosing(
    @CurrentUser() user: AuthUser,
    @Query() query: ClosingPeriodQuery,
  ) {
    return this.closing.list(user, query.branchId);
  }

  @Get('closing-periods/:id')
  @Roles('accounts_admin', 'branch_admin', 'super_admin')
  getClosing(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.closing.get(user, id);
  }

  @Post('closing-periods/:id/finalize')
  @HttpCode(HttpStatus.OK)
  @Roles('accounts_admin', 'super_admin')
  finalizeClosing(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.closing.finalize(user, id);
  }

  @Post('invoices/generate')
  @HttpCode(HttpStatus.OK)
  @Roles('accounts_admin', 'super_admin')
  generateInvoice(
    @CurrentUser() user: AuthUser,
    @Body() dto: GenerateInvoiceDto,
  ) {
    return this.invoices.generate(user, dto);
  }

  @Get('invoices')
  @Roles('accounts_admin', 'branch_admin', 'super_admin')
  listInvoices(@CurrentUser() user: AuthUser, @Query() query: InvoiceQuery) {
    return this.invoices.list(user, query);
  }

  @Get('invoices/:id')
  @Roles('accounts_admin', 'branch_admin', 'super_admin')
  getInvoice(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.invoices.get(user, id);
  }

  @Post('invoices/:id/generate-pdf')
  @HttpCode(HttpStatus.OK)
  @Roles('accounts_admin', 'super_admin')
  @Audited('invoice', 'pdf_generated')
  generateInvoicePdf(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: GenerateInvoicePdfDto,
  ) {
    return this.invoices.generatePdf(user, id, dto);
  }

  @Post('invoices/:id/send')
  @HttpCode(HttpStatus.OK)
  @Roles('accounts_admin', 'super_admin')
  sendInvoice(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.invoices.send(user, id);
  }

  @Post('invoices/:id/void')
  @HttpCode(HttpStatus.OK)
  @Roles('accounts_admin', 'super_admin')
  voidInvoice(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.invoices.void(user, id);
  }

  @Post('invoices/:id/record-payment')
  @HttpCode(HttpStatus.OK)
  @Roles('accounts_admin', 'super_admin')
  recordInvoicePayment(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: RecordInvoicePaymentDto,
  ) {
    return this.invoices.recordPayment(user, id, dto);
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
