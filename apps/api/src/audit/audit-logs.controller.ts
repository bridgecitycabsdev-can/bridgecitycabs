import { Controller, Get, Query } from '@nestjs/common';
import { Roles } from '../common/roles.decorator.js';
import { AuditLogsService } from './audit-logs.service.js';
import { AuditLogQuery } from './dto/audit-log-query.dto.js';

@Controller('audit-logs')
export class AuditLogsController {
  constructor(private readonly auditLogs: AuditLogsService) {}

  @Get()
  @Roles('super_admin')
  list(@Query() query: AuditLogQuery) {
    return this.auditLogs.list(query);
  }
}
