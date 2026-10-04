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
import { STAFF_ROLES } from '../common/staff-roles.js';
import { CorporateAccountsService } from './corporate-accounts.service.js';
import { CorporateAccountQuery } from './dto/corporate-account-query.dto.js';
import { CreateCorporateAccountDto } from './dto/create-corporate-account.dto.js';
import { CreateCorporateContactDto } from './dto/create-corporate-contact.dto.js';
import { SearchQuery } from './dto/search-query.dto.js';
import { UpdateCorporateAccountDto } from './dto/update-corporate-account.dto.js';
import { UpdateCorporateContactDto } from './dto/update-corporate-contact.dto.js';

@Controller('corporate-accounts')
export class CorporateAccountsController {
  constructor(private readonly accounts: CorporateAccountsService) {}

  @Post()
  @Roles('super_admin', 'branch_admin')
  create(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateCorporateAccountDto,
  ) {
    return this.accounts.create(dto, user);
  }

  @Get()
  @Roles(...STAFF_ROLES)
  findAll(
    @CurrentUser() user: AuthUser,
    @Query() query: CorporateAccountQuery,
  ) {
    return this.accounts.findAll(user, query);
  }

  @Get('search')
  @Roles(...STAFF_ROLES)
  search(@CurrentUser() user: AuthUser, @Query() query: SearchQuery) {
    return this.accounts.search(user, query.q);
  }

  @Get(':id')
  @Roles(...STAFF_ROLES)
  findOne(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.accounts.findOne(id, user);
  }

  @Get(':id/balance')
  @Roles(...STAFF_ROLES)
  balance(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.accounts.balance(id, user);
  }

  @Patch(':id')
  @Roles('super_admin', 'branch_admin')
  update(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateCorporateAccountDto,
  ) {
    return this.accounts.update(id, dto, user);
  }

  @Post(':id/contacts')
  @Roles('super_admin', 'branch_admin')
  createContact(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateCorporateContactDto,
  ) {
    return this.accounts.createContact(id, dto, user);
  }

  @Get(':id/contacts')
  @Roles(...STAFF_ROLES)
  listContacts(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
  ) {
    return this.accounts.listContacts(id, user);
  }

  @Get(':id/contacts/search')
  @Roles(...STAFF_ROLES)
  searchContacts(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Query() query: SearchQuery,
  ) {
    return this.accounts.searchContacts(id, user, query.q);
  }

  @Patch(':id/contacts/:contactId')
  @Roles('super_admin', 'branch_admin')
  updateContact(
    @Param('id', ParseUUIDPipe) id: string,
    @Param('contactId', ParseUUIDPipe) contactId: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateCorporateContactDto,
  ) {
    return this.accounts.updateContact(id, contactId, dto, user);
  }
}
