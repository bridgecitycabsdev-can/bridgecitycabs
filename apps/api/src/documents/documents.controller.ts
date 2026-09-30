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
import { DocumentsService } from './documents.service.js';
import { ExpiringDocumentsQuery } from './dto/expiring-documents-query.dto.js';
import { ReviewDocumentDto } from './dto/review-document.dto.js';

@Controller('documents')
@Roles(...STAFF_ROLES)
export class DocumentsController {
  constructor(private readonly documents: DocumentsService) {}

  @Get('expiring')
  expiring(@CurrentUser() user: AuthUser, @Query() query: ExpiringDocumentsQuery) {
    return this.documents.expiring(user, query);
  }

  @Post(':id/review')
  @HttpCode(HttpStatus.OK)
  @Roles('super_admin', 'branch_admin', 'hr_admin')
  review(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: ReviewDocumentDto,
  ) {
    return this.documents.review(id, dto, user);
  }
}
