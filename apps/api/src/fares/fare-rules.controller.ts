import {
  Body,
  Controller,
  Delete,
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
import { STAFF_ROLES } from '../common/staff-roles.js';
import { CreateFareRuleDto } from './dto/create-fare-rule.dto.js';
import { FareRuleQuery } from './dto/fare-rule-query.dto.js';
import { UpdateFareRuleDto } from './dto/update-fare-rule.dto.js';
import { FareRulesService } from './fare-rules.service.js';

@Controller('fare-rules')
@Roles(...STAFF_ROLES)
export class FareRulesController {
  constructor(private readonly fareRules: FareRulesService) {}

  @Post()
  @Roles('super_admin', 'branch_admin')
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateFareRuleDto) {
    return this.fareRules.create(dto, user);
  }

  @Get()
  findAll(@CurrentUser() user: AuthUser, @Query() query: FareRuleQuery) {
    return this.fareRules.findAll(user, query);
  }

  @Get(':id')
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.fareRules.findOne(id, user);
  }

  @Patch(':id')
  @Roles('super_admin', 'branch_admin')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateFareRuleDto,
  ) {
    return this.fareRules.update(id, dto, user);
  }

  @Delete(':id')
  @Roles('super_admin', 'branch_admin')
  remove(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.fareRules.remove(id, user);
  }
}
