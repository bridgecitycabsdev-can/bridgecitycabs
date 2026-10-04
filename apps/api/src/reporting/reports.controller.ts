import {
  Controller,
  Get,
  Header,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Query,
  Res,
  StreamableFile,
} from '@nestjs/common';
import type { Response } from 'express';
import { readFile } from 'node:fs/promises';
import { Audited } from '../audit/audited.decorator.js';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Public } from '../common/public.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { LocalObjectStorage } from '../storage/local-object-storage.js';
import { BookingReportService } from './booking-report.service.js';
import { ReportFilterDto } from './dto/report-filter.dto.js';
import { rowsToCsv } from './report-row.js';

@Controller('reports')
export class ReportsController {
  constructor(
    private readonly reports: BookingReportService,
    private readonly localStorage: LocalObjectStorage,
  ) {}

  @Get('booking-report')
  @Roles('super_admin', 'branch_admin', 'accounts_admin')
  @Audited('generated_report', 'generated')
  async bookingReport(
    @CurrentUser() user: AuthUser,
    @Query() dto: ReportFilterDto,
    @Res({ passthrough: true }) res: Response,
  ) {
    const result = await this.reports.buildReport(dto, user);
    if (result.async) {
      res.status(HttpStatus.ACCEPTED);
      return {
        async: true,
        reportId: result.reportId,
        rowCount: result.rowCount,
      };
    }

    const format = result.format ?? 'json';
    if (format === 'csv') {
      const csv = rowsToCsv(result.rows);
      res.setHeader('Content-Type', 'text/csv; charset=utf-8');
      res.setHeader(
        'Content-Disposition',
        'attachment; filename="booking-report.csv"',
      );
      return new StreamableFile(Buffer.from(csv, 'utf8'));
    }

    if (format === 'pdf') {
      const { body } = await this.reports.renderArtifact(result.rows, 'pdf', {
        branch: dto.branchId ?? user.branchId ?? 'All branches',
        from: dto.from,
        to: dto.to,
      });
      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader(
        'Content-Disposition',
        'attachment; filename="booking-report.pdf"',
      );
      return new StreamableFile(body);
    }

    return {
      async: false,
      rowCount: result.rowCount,
      rows: result.rows,
    };
  }

  /** Local-storage signed download (dev when R2 is unset). Must stay above :id. */
  @Public()
  @Get('files')
  @HttpCode(HttpStatus.OK)
  @Header('Cache-Control', 'private, no-store')
  async localFile(
    @Query('key') key: string,
    @Query('exp') expRaw: string,
    @Query('sig') sig: string,
    @Res({ passthrough: true }) res: Response,
  ) {
    const exp = Number.parseInt(expRaw, 10);
    if (
      !key ||
      !sig ||
      key.includes('..') ||
      !this.localStorage.verifySignature(key, exp, sig)
    ) {
      res.status(HttpStatus.NOT_FOUND);
      return { message: 'Not found' };
    }
    const path = this.localStorage.absolutePath(key);
    const body = await readFile(path);
    let contentType = 'application/octet-stream';
    try {
      contentType = (await readFile(`${path}.ctype`, 'utf8')).trim();
    } catch {
      // ignore missing ctype sidecar
    }
    res.setHeader('Content-Type', contentType);
    const filename = key.split('/').pop() ?? 'report';
    res.setHeader(
      'Content-Disposition',
      `attachment; filename="${filename}"`,
    );
    return new StreamableFile(body);
  }

  @Get(':id/download')
  @Roles(...STAFF_ROLES)
  download(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.reports.download(user, id);
  }

  @Get(':id')
  @Roles(...STAFF_ROLES)
  getReport(
    @CurrentUser() user: AuthUser,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.reports.getReport(user, id);
  }
}
