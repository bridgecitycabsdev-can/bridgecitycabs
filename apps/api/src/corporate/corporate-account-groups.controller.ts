import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Patch,
  Post,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { CorporateAccountGroupsService } from './corporate-account-groups.service.js';
import { CreateCorporateAccountGroupDto } from './dto/create-corporate-account-group.dto.js';
import { UpdateCorporateAccountGroupDto } from './dto/update-corporate-account-group.dto.js';

@Controller('corporate-account-groups')
@Roles('super_admin')
export class CorporateAccountGroupsController {
  constructor(private readonly groups: CorporateAccountGroupsService) {}

  @Post()
  create(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateCorporateAccountGroupDto,
  ) {
    return this.groups.create(dto, user);
  }

  @Get()
  findAll(@CurrentUser() user: AuthUser) {
    return this.groups.findAll(user);
  }

  @Get(':id')
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.groups.findOne(id, user);
  }

  @Patch(':id')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateCorporateAccountGroupDto,
  ) {
    return this.groups.update(id, dto, user);
  }
}
