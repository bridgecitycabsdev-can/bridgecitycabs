import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { CreatePromoCodeDto } from './dto/create-promo-code.dto.js';
import { PromoPreviewQuery } from './dto/promo-preview-query.dto.js';
import { UpdatePromoCodeDto } from './dto/update-promo-code.dto.js';
import { PromosService } from './promos.service.js';

@Controller('promo-codes')
@Roles('super_admin', 'branch_admin')
export class PromosController {
  constructor(private readonly promos: PromosService) {}

  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreatePromoCodeDto) {
    return this.promos.create(user, dto);
  }

  @Get()
  list(@CurrentUser() user: AuthUser) {
    return this.promos.list(user);
  }

  @Get(':code/preview')
  preview(
    @CurrentUser() user: AuthUser,
    @Param('code') code: string,
    @Query() query: PromoPreviewQuery,
  ) {
    return this.promos.preview(user, code, query.subtotalCents);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: UpdatePromoCodeDto,
  ) {
    return this.promos.update(user, id, dto);
  }
}
