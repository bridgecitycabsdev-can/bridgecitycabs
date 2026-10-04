import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { CreateLeaseAgreementDto } from './dto/create-lease-agreement.dto.js';
import { LeaseAgreementQuery } from './dto/lease-agreement-query.dto.js';
import { UpdateLeaseAgreementDto } from './dto/update-lease-agreement.dto.js';
import { LeaseAgreementsService } from './lease-agreements.service.js';

@Controller('lease-agreements')
@Roles('super_admin', 'branch_admin')
export class LeaseAgreementsController {
  constructor(private readonly leases: LeaseAgreementsService) {}

  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateLeaseAgreementDto) {
    return this.leases.create(dto, user);
  }

  @Get()
  findAll(@CurrentUser() user: AuthUser, @Query() query: LeaseAgreementQuery) {
    return this.leases.findAll(user, query);
  }

  @Get(':id')
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.leases.findOne(id, user);
  }

  @Patch(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateLeaseAgreementDto,
  ) {
    return this.leases.update(id, dto, user);
  }
}
