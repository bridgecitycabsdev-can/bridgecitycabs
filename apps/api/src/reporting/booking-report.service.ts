import {
  ConflictException,
  ForbiddenException,
  Inject,
  Injectable,
  Logger,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Prisma } from '@prisma/client';
import { ApiCode } from '../common/api-code.js';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere, canAccessBranch } from '../common/branch-scope.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import {
  REPORT_QUEUE,
  type ReportQueue,
} from '../jobs/report-queue.js';
import { NotificationsService } from '../notifications/notifications.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { PdfService } from '../pdf/pdf.service.js';
import {
  OBJECT_STORAGE,
  type ObjectStorage,
} from '../storage/object-storage.js';
import type { ReportFilterDto } from './dto/report-filter.dto.js';
import {
  rowsToCsv,
  toBookingReportPdfRows,
  toReportRow,
  type ReportBookingRow,
} from './report-row.js';

const STAFF = new Set<string>(STAFF_ROLES);
const DEFAULT_MAX_RANGE_DAYS = 180;
const DEFAULT_ASYNC_THRESHOLD = 5000;
const DEFAULT_SIGNED_TTL = 3600;

const bookingInclude = {
  driver: { select: { firstName: true, lastName: true } },
  vehicle: { select: { plateNumber: true } },
  stops: {
    select: { type: true, address: true, sequence: true },
    orderBy: { sequence: 'asc' as const },
  },
} satisfies Prisma.BookingInclude;

@Injectable()
export class BookingReportService {
  private readonly logger = new Logger(BookingReportService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly notifications: NotificationsService,
    private readonly pdf: PdfService,
    @Inject(REPORT_QUEUE) private readonly reportQueue: ReportQueue,
    @Inject(OBJECT_STORAGE) private readonly storage: ObjectStorage,
  ) {}

  async buildReport(dto: ReportFilterDto, actor: AuthUser) {
    this.assertStaff(actor);
    this.assertRange(dto.from, dto.to);

    const where = this.buildWhere(dto, actor);
    const count = await this.prisma.booking.count({ where });
    const format = dto.format ?? 'json';
    const asyncThreshold = this.asyncThreshold();

    if (count > asyncThreshold) {
      const scope = branchWhere(actor, dto.branchId);
      const report = await this.prisma.generatedReport.create({
        data: {
          type: 'CUSTOM_BOOKING_REPORT',
          status: 'QUEUED',
          branchId: (scope.branchId as string | undefined) ?? null,
          paramsJson: dto as unknown as Prisma.InputJsonValue,
          requestedById: actor.userId,
          rowCount: count,
        },
      });
      await this.reportQueue.enqueueBookingReport({
        reportId: report.id,
        where: serializeWhere(where),
        format,
      });
      return { async: true as const, reportId: report.id, rowCount: count };
    }

    const rows = await this.loadRows(where);
    return { async: false as const, rows, format, rowCount: rows.length };
  }

  async getReport(actor: AuthUser, id: string) {
    this.assertStaff(actor);
    const report = await this.requireAccessibleReport(actor, id);

    return {
      id: report.id,
      type: report.type,
      status: report.status,
      branchId: report.branchId,
      rowCount: report.rowCount,
      format: (report.paramsJson as { format?: string } | null)?.format ?? null,
      createdAt: report.createdAt.toISOString(),
      completedAt: report.completedAt?.toISOString() ?? null,
      failureNote: report.failureNote,
      /** Prefer GET /reports/:id/download for a fresh signed URL. */
      downloadAvailable: report.status === 'READY' && Boolean(report.storageKey),
    };
  }

  /**
   * Private-bucket signed download — same pattern as Day 3 document keys.
   * Never return a public/unauthenticated link; reports hold PII and fares.
   */
  async download(actor: AuthUser, id: string) {
    this.assertStaff(actor);
    const report = await this.requireAccessibleReport(actor, id);
    if (report.status !== 'READY' || !report.storageKey) {
      throw new ConflictException({
        code: ApiCode.REPORT_NOT_READY,
        status: report.status,
      });
    }
    const expiresIn = this.signedTtl();
    const url = await this.storage.signedUrl(report.storageKey, expiresIn);
    return { url, expiresIn };
  }

  private async requireAccessibleReport(actor: AuthUser, id: string) {
    const report = await this.prisma.generatedReport.findUnique({
      where: { id },
    });
    if (!report) throw new NotFoundException();
    if (report.branchId && !canAccessBranch(actor, report.branchId)) {
      throw new ForbiddenException();
    }
    return report;
  }

  /** BullMQ processor: same query, no row-count cap; upload + notify. */
  async processBookingReportJob(input: {
    reportId: string;
    where: Record<string, unknown>;
    format: 'csv' | 'pdf' | 'json';
  }) {
    const report = await this.prisma.generatedReport.findUnique({
      where: { id: input.reportId },
    });
    if (!report) return;

    await this.prisma.generatedReport.update({
      where: { id: report.id },
      data: { status: 'GENERATING' },
    });

    try {
      const where = deserializeWhere(input.where) as Prisma.BookingWhereInput;
      const rows = await this.loadRows(where);
      const format = input.format === 'pdf' ? 'pdf' : 'csv';
      const params = report.paramsJson as {
        from?: string;
        to?: string;
      } | null;
      const { body, contentType, ext } = await this.renderArtifact(
        rows,
        format,
        {
          branch: report.branchId ?? 'All branches',
          from: params?.from ?? '',
          to: params?.to ?? '',
        },
      );
      const branchSegment = report.branchId ?? 'company';
      const storageKey = `reports/${branchSegment}/${report.id}.${ext}`;
      await this.storage.putObject(storageKey, body, contentType);

      await this.prisma.generatedReport.update({
        where: { id: report.id },
        data: {
          status: 'READY',
          storageKey,
          rowCount: rows.length,
          completedAt: new Date(),
          failureNote: null,
        },
      });

      if (report.requestedById) {
        await this.notifications.notify(
          report.requestedById,
          'REPORT_READY',
          'Report ready',
          `Your booking report (${rows.length} rows) is ready to download.`,
          { reportId: report.id, rowCount: rows.length },
        );
      }
    } catch (error) {
      const note =
        error instanceof Error ? error.message : 'Report generation failed';
      this.logger.error(`Report ${report.id} failed: ${note}`);
      await this.prisma.generatedReport.update({
        where: { id: report.id },
        data: {
          status: 'FAILED',
          failureNote: note.slice(0, 500),
          completedAt: new Date(),
        },
      });
      throw error;
    }
  }

  async renderArtifact(
    rows: ReportBookingRow[],
    format: 'csv' | 'pdf' | 'json',
    meta?: { branch: string; from: string; to: string },
  ): Promise<{ body: Buffer; contentType: string; ext: string }> {
    if (format === 'pdf') {
      const body = await this.pdf.buildBookingReportPdf(
        toBookingReportPdfRows(rows),
        meta ?? {
          branch: 'All branches',
          from: rows[0]?.createdAt.slice(0, 10) ?? '',
          to: rows[rows.length - 1]?.createdAt.slice(0, 10) ?? '',
        },
      );
      return { body, contentType: 'application/pdf', ext: 'pdf' };
    }
    if (format === 'csv') {
      return {
        body: Buffer.from(rowsToCsv(rows), 'utf8'),
        contentType: 'text/csv; charset=utf-8',
        ext: 'csv',
      };
    }
    return {
      body: Buffer.from(JSON.stringify({ rows }, null, 2), 'utf8'),
      contentType: 'application/json',
      ext: 'json',
    };
  }

  private async loadRows(where: Prisma.BookingWhereInput) {
    const bookings = await this.prisma.booking.findMany({
      where,
      include: bookingInclude,
      orderBy: { createdAt: 'asc' },
    });
    return bookings.map(toReportRow);
  }

  buildWhere(dto: ReportFilterDto, actor: AuthUser): Prisma.BookingWhereInput {
    const scope = branchWhere(actor, dto.branchId);
    const { gte, lt } = parseReportWindow(dto.from, dto.to);
    return {
      ...scope,
      createdAt: { gte, lt },
      ...(dto.status?.length ? { status: { in: dto.status } } : {}),
      ...(dto.source?.length ? { source: { in: dto.source } } : {}),
      ...(dto.paymentMethod?.length
        ? { paymentMethod: { in: dto.paymentMethod } }
        : {}),
      ...(dto.paymentStatus?.length
        ? { paymentStatus: { in: dto.paymentStatus } }
        : {}),
      ...(dto.driverId ? { driverId: dto.driverId } : {}),
      ...(dto.corporateAccountId
        ? { corporateAccountId: dto.corporateAccountId }
        : {}),
      ...(dto.vehicleTypeId ? { vehicleTypeId: dto.vehicleTypeId } : {}),
    };
  }

  private assertRange(from: string, to: string) {
    const { gte, lt } = parseReportWindow(from, to);
    if (!(gte.getTime() < lt.getTime())) {
      throw new UnprocessableEntityException({
        code: ApiCode.UNPROCESSABLE,
        message: 'from must be before to',
      });
    }
    const maxDays = this.maxRangeDays();
    const spanMs = lt.getTime() - gte.getTime();
    const maxMs = maxDays * 24 * 60 * 60 * 1000;
    if (spanMs > maxMs) {
      throw new UnprocessableEntityException({
        code: ApiCode.REPORT_RANGE_TOO_WIDE,
        message: `Date range cannot exceed ${maxDays} days`,
        maxDays,
      });
    }
  }

  private maxRangeDays() {
    const raw = Number.parseInt(
      this.config.get<string>('REPORT_MAX_RANGE_DAYS')?.trim() ?? '',
      10,
    );
    return Number.isFinite(raw) && raw > 0 ? raw : DEFAULT_MAX_RANGE_DAYS;
  }

  private asyncThreshold() {
    const raw = Number.parseInt(
      this.config.get<string>('REPORT_ASYNC_THRESHOLD_ROWS')?.trim() ?? '',
      10,
    );
    return Number.isFinite(raw) && raw > 0 ? raw : DEFAULT_ASYNC_THRESHOLD;
  }

  private signedTtl() {
    const raw = Number.parseInt(
      this.config.get<string>('REPORT_SIGNED_URL_TTL_SECONDS')?.trim() ?? '',
      10,
    );
    return Number.isFinite(raw) && raw > 0 ? raw : DEFAULT_SIGNED_TTL;
  }

  private assertStaff(user: AuthUser) {
    if (!STAFF.has(user.role)) throw new ForbiddenException();
  }
}

/** Inclusive date-only `to`; exclusive `lt` = next local UTC day / instant. */
export function parseReportWindow(from: string, to: string) {
  return {
    gte: parseBoundary(from, false),
    lt: parseBoundary(to, true),
  };
}

function parseBoundary(value: string, endExclusive: boolean) {
  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    if (endExclusive) {
      const next = new Date(`${value}T00:00:00.000Z`);
      next.setUTCDate(next.getUTCDate() + 1);
      return next;
    }
    return new Date(`${value}T00:00:00.000Z`);
  }
  return new Date(value);
}

function serializeWhere(where: Prisma.BookingWhereInput) {
  return JSON.parse(JSON.stringify(where)) as Record<string, unknown>;
}

function deserializeWhere(where: Record<string, unknown>) {
  const createdAt = where.createdAt as
    | { gte?: string; lt?: string }
    | undefined;
  if (createdAt) {
    return {
      ...where,
      createdAt: {
        ...(createdAt.gte ? { gte: new Date(createdAt.gte) } : {}),
        ...(createdAt.lt ? { lt: new Date(createdAt.lt) } : {}),
      },
    };
  }
  return where;
}
