import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { PageQuery } from '../common/pagination.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { CreatePassengerDto } from './dto/create-passenger.dto.js';
import { PassengerReasonDto } from './dto/passenger-reason.dto.js';
import { UpdatePassengerDto } from './dto/update-passenger.dto.js';
import { PassengersService } from './passengers.service.js';

@Controller('passengers')
@Roles(...STAFF_ROLES)
export class PassengersController {
  constructor(private readonly passengers: PassengersService) {}

  @Post()
  create(@Body() dto: CreatePassengerDto) {
    return this.passengers.create(dto);
  }

  @Get()
  findAll(@Query() query: PageQuery) {
    return this.passengers.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.passengers.findOne(id);
  }

  @Patch(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdatePassengerDto,
  ) {
    return this.passengers.update(id, dto);
  }

  @Post(':id/block')
  @HttpCode(HttpStatus.OK)
  @Roles('super_admin', 'branch_admin', 'customer_care')
  block(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: PassengerReasonDto,
  ) {
    return this.passengers.block(id, dto, user);
  }

  @Post(':id/unblock')
  @HttpCode(HttpStatus.OK)
  @Roles('super_admin', 'branch_admin', 'customer_care')
  unblock(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: PassengerReasonDto,
  ) {
    return this.passengers.unblock(id, dto, user);
  }
}
