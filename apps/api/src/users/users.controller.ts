import { Body, Controller, Param, ParseUUIDPipe, Patch } from '@nestjs/common';
import { Audited } from '../audit/audited.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { UpdateUserRoleDto } from './dto/update-user-role.dto.js';
import { UsersService } from './users.service.js';

@Controller('users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Patch(':id/role')
  @Roles('super_admin')
  @Audited('user', 'role_changed')
  updateRole(
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: UpdateUserRoleDto,
  ) {
    return this.users.updateRole(id, dto.roleId);
  }
}
