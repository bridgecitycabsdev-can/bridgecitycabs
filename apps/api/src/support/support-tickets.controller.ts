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
import { STAFF_ROLES } from '../common/staff-roles.js';
import { AddTicketMessageDto } from './dto/add-ticket-message.dto.js';
import { AssignTicketDto } from './dto/assign-ticket.dto.js';
import { CreateTicketDto } from './dto/create-ticket.dto.js';
import { TicketQuery } from './dto/ticket-query.dto.js';
import { UpdateTicketStatusDto } from './dto/update-ticket-status.dto.js';
import { SupportTicketsService } from './support-tickets.service.js';

@Controller('support/tickets')
export class SupportTicketsController {
  constructor(private readonly tickets: SupportTicketsService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @Roles('passenger', 'driver', ...STAFF_ROLES)
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateTicketDto) {
    return this.tickets.create(user, dto);
  }

  @Get('mine')
  @Roles('passenger', 'driver', ...STAFF_ROLES)
  mine(@CurrentUser() user: AuthUser, @Query() query: TicketQuery) {
    return this.tickets.mine(user, query);
  }

  @Get('pending-count')
  @Roles(...STAFF_ROLES)
  pendingCount(
    @CurrentUser() user: AuthUser,
    @Query('branchId') branchId?: string,
  ) {
    return this.tickets.pendingCount(user, branchId);
  }

  @Get()
  @Roles(...STAFF_ROLES)
  list(@CurrentUser() user: AuthUser, @Query() query: TicketQuery) {
    return this.tickets.list(user, query);
  }

  @Get(':id')
  @Roles('passenger', 'driver', ...STAFF_ROLES)
  get(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.tickets.get(user, id);
  }

  @Post(':id/messages')
  @HttpCode(HttpStatus.OK)
  @Roles('passenger', 'driver', ...STAFF_ROLES)
  addMessage(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: AddTicketMessageDto,
  ) {
    return this.tickets.addMessage(user, id, dto);
  }

  @Post(':id/assign')
  @HttpCode(HttpStatus.OK)
  @Roles('super_admin', 'branch_admin')
  assign(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: AssignTicketDto,
  ) {
    return this.tickets.assign(user, id, dto.assignedToId);
  }

  @Post(':id/status')
  @HttpCode(HttpStatus.OK)
  @Roles(...STAFF_ROLES)
  setStatus(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateTicketStatusDto,
  ) {
    return this.tickets.setStatus(user, id, dto.status);
  }
}
