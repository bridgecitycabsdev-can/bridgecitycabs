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
import { ResolveSosDto } from './dto/resolve-sos.dto.js';
import { SosQuery } from './dto/sos-query.dto.js';
import { TriggerSosDto } from './dto/trigger-sos.dto.js';
import { SosService } from './sos.service.js';

@Controller()
export class SosController {
  constructor(private readonly sos: SosService) {}

  @Post('driver/sos')
  @HttpCode(HttpStatus.CREATED)
  @Roles('driver')
  driverTrigger(@CurrentUser() user: AuthUser, @Body() dto: TriggerSosDto) {
    return this.sos.triggerAsDriver(user, dto);
  }

  @Post('passenger/sos')
  @HttpCode(HttpStatus.CREATED)
  @Roles('passenger')
  passengerTrigger(@CurrentUser() user: AuthUser, @Body() dto: TriggerSosDto) {
    return this.sos.triggerAsPassenger(user, dto);
  }

  @Get('dispatch/sos')
  @Roles(...STAFF_ROLES)
  list(@CurrentUser() user: AuthUser, @Query() query: SosQuery) {
    return this.sos.list(user, query);
  }

  @Post('sos/:id/acknowledge')
  @HttpCode(HttpStatus.OK)
  @Roles(...STAFF_ROLES)
  acknowledge(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.sos.acknowledge(user, id);
  }

  @Post('sos/:id/resolve')
  @HttpCode(HttpStatus.OK)
  @Roles(...STAFF_ROLES)
  resolve(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: ResolveSosDto,
  ) {
    return this.sos.resolve(user, id, dto);
  }
}
