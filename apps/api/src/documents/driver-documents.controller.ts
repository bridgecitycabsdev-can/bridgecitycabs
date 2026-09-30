import { Body, Controller, Param, ParseUUIDPipe, Post } from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { DocumentsService } from './documents.service.js';
import { CreateDocumentDto } from './dto/create-document.dto.js';

@Controller('drivers')
@Roles(...STAFF_ROLES)
export class DriverDocumentsController {
  constructor(private readonly documents: DocumentsService) {}

  @Post(':id/documents')
  create(
    @Param('id', ParseUUIDPipe) id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateDocumentDto,
  ) {
    return this.documents.createForDriver(id, dto, user);
  }
}
