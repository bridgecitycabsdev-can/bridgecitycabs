import {
  Body,
  Controller,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { AssignmentsService } from './assignments.service.js';
import { AssignVehicleDto } from './dto/assign-vehicle.dto.js';

@Controller('drivers')
@Roles(...STAFF_ROLES)
export class AssignmentsController {
  constructor(private readonly assignments: AssignmentsService) {}

  @Post(':id/assign-vehicle')
  assign(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: AssignVehicleDto,
  ) {
    return this.assignments.assign(id, dto, user);
  }

  @Post(':id/unassign-vehicle')
  @HttpCode(HttpStatus.OK)
  unassign(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.assignments.unassign(id, user);
  }
}
