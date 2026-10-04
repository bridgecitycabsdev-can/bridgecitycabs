/**
 * Day 13 Step 10 checklist — ten scenarios for dashboard rollups,
 * booking reports, PDFs, and audit completeness.
 */
import {
  ConflictException,
  ForbiddenException,
  type CallHandler,
  type ExecutionContext,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { lastValueFrom, of } from 'rxjs';
import { describe, expect, it, vi } from 'vitest';
import { AuditInterceptor } from './audit/audit.interceptor.js';
import { AUDIT_KEY } from './audit/audited.decorator.js';
import { AuditLogsService } from './audit/audit-logs.service.js';
import { ApiCode } from './common/api-code.js';
import { RolesGuard } from './common/roles.guard.js';
import { DocumentsController } from './documents/documents.controller.js';
import { DriversController } from './drivers/drivers.controller.js';
import { LeaseAgreementsController } from './lease/lease-agreements.controller.js';
import { PdfService } from './pdf/pdf.service.js';
import { PromosController } from './promos/promos.controller.js';
import { BookingReportService } from './reporting/booking-report.service.js';
import { DashboardService } from './reporting/dashboard.service.js';
import {
  DailyStatsService,
  totalsFromBookings,
} from './reporting/daily-stats.service.js';
import { rowsToCsv, toReportRow } from './reporting/report-row.js';
import type { ReportFilterDto } from './reporting/dto/report-filter.dto.js';

const admin = {
  userId: 'admin-1',
  role: 'branch_admin',
  branchId: 'branch-1',
};

const superAdmin = {
  userId: 'super-1',
  role: 'super_admin',
  branchId: null,
};

const emptyTotals = {
  totalRides: 0,
  completedRides: 0,
  activeRides: 0,
  cancelledRides: 0,
  unpaidRides: 0,
  prepaidRides: 0,
  postpaidRides: 0,
  accountCalls: 0,
  sourceDispatch: 0,
  sourceDriverApp: 0,
  sourcePassengerApp: 0,
  grossSubtotalCents: 0,
};

function dto(overrides: Partial<ReportFilterDto> = {}): ReportFilterDto {
  return {
    from: '2026-09-01',
    to: '2026-09-30',
    format: 'json',
    ...overrides,
  };
}

describe('Day 13 reporting, PDFs & audit (10)', () => {
  it('1. computeDailyStat buckets match a hand-counted fixture set', () => {
    const bookings = [
      {
        status: 'CLOSED',
        paymentMethod: 'CARD',
        paymentStatus: 'PAID',
        source: 'PASSENGER_APP',
        corporateAccountId: null,
        finalSubtotalCents: 1500,
      },
      {
        status: 'CLOSED',
        paymentMethod: 'CASH',
        paymentStatus: 'PAID',
        source: 'DISPATCH',
        corporateAccountId: null,
        finalSubtotalCents: 2000,
      },
      {
        status: 'TRIP_STARTED',
        paymentMethod: 'ACCOUNT',
        paymentStatus: 'UNPAID',
        source: 'DISPATCH',
        corporateAccountId: 'ca-1',
        finalSubtotalCents: 3000,
      },
      {
        status: 'CANCELLED',
        paymentMethod: 'CARD',
        paymentStatus: 'UNPAID',
        source: 'DRIVER_APP',
        corporateAccountId: null,
        finalSubtotalCents: null,
      },
      {
        status: 'NO_DRIVER_FOUND',
        paymentMethod: 'CASH',
        paymentStatus: 'UNPAID',
        source: 'PASSENGER_APP',
        corporateAccountId: null,
        finalSubtotalCents: 0,
      },
    ];
    // Hand count: prepaid=CARD(2), postpaid=CASH|ACCOUNT(3), unpaid=UNPAID(3)
    expect(totalsFromBookings(bookings)).toEqual({
      totalRides: 5,
      completedRides: 2,
      activeRides: 1,
      cancelledRides: 1,
      unpaidRides: 3,
      prepaidRides: 2,
      postpaidRides: 3,
      accountCalls: 1,
      sourceDispatch: 2,
      sourceDriverApp: 1,
      sourcePassengerApp: 2,
      grossSubtotalCents: 6500,
    });
  });

  it('2. today is always live; past rollup ignores post-rollup booking changes', async () => {
    const pastDate = new Date('2026-09-25T06:00:00.000Z');
    const todayStart = new Date('2026-10-04T06:00:00.000Z');
    const now = new Date('2026-10-04T18:00:00.000Z');

    let liveCount = 2;
    const aggregateDailyStat = vi.fn(async () => ({
      ...emptyTotals,
      totalRides: liveCount,
      completedRides: liveCount,
    }));
    const rollup = {
      ...emptyTotals,
      totalRides: 4,
      completedRides: 3,
      cancelledRides: 1,
    };
    const findUnique = vi.fn(async () => rollup);
    const computeDailyStat = vi.fn();
    const service = new DashboardService(
      { dailyBranchStat: { findUnique } } as never,
      { aggregateDailyStat, computeDailyStat } as never,
    );

    await expect(
      service.getDailyStats('branch-1', todayStart, 'America/Edmonton', now),
    ).resolves.toMatchObject({ totalRides: 2, live: true });

    liveCount = 5; // booking created after first request
    await expect(
      service.getDailyStats('branch-1', todayStart, 'America/Edmonton', now),
    ).resolves.toMatchObject({ totalRides: 5, live: true });

    await expect(
      service.getDailyStats('branch-1', pastDate, 'America/Edmonton', now),
    ).resolves.toMatchObject({ totalRides: 4, live: false });
    expect(computeDailyStat).not.toHaveBeenCalled();
    // even if live aggregate would differ, past still returns frozen rollup
    expect(aggregateDailyStat).not.toHaveBeenCalledWith(
      'branch-1',
      pastDate,
      expect.anything(),
    );
  });

  it('3. missing historical rollup self-heals via computeDailyStat upsert', async () => {
    const pastDate = new Date('2026-09-25T06:00:00.000Z');
    const now = new Date('2026-10-04T18:00:00.000Z');
    const healed = {
      ...emptyTotals,
      totalRides: 7,
      completedRides: 6,
      cancelledRides: 1,
      grossSubtotalCents: 12_000,
    };
    const computeDailyStat = vi.fn(async () => healed);
    const findUnique = vi.fn().mockResolvedValueOnce(null);
    const service = new DashboardService(
      { dailyBranchStat: { findUnique } } as never,
      { aggregateDailyStat: vi.fn(), computeDailyStat } as never,
    );

    await expect(
      service.getDailyStats('branch-1', pastDate, 'America/Edmonton', now),
    ).resolves.toMatchObject({ totalRides: 7, live: false });
    expect(computeDailyStat).toHaveBeenCalledWith('branch-1', pastDate);

    // DailyStatsService.computeDailyStat itself upserts
    const upsert = vi.fn(async ({ create }) => create);
    const stats = new DailyStatsService({
      branch: {
        findUnique: vi.fn(async () => ({ timezone: 'America/Edmonton' })),
      },
      booking: { findMany: vi.fn(async () => []) },
      dailyBranchStat: { upsert },
    } as never);
    await stats.computeDailyStat('branch-1', pastDate);
    expect(upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { branchId_date: { branchId: 'branch-1', date: pastDate } },
      }),
    );
  });

  it('4. rides-chart mixes rollup history with a live today point', async () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-10-04T18:00:00.000Z'));
    try {
      const prisma = {
        branch: {
          findUnique: vi.fn(async () => ({
            id: 'branch-1',
            timezone: 'America/Edmonton',
          })),
        },
        dailyBranchStat: {
          findMany: vi.fn(async () => [
            {
              date: new Date('2026-10-02T06:00:00.000Z'),
              totalRides: 10,
              completedRides: 8,
              cancelledRides: 2,
            },
            {
              date: new Date('2026-10-03T06:00:00.000Z'),
              totalRides: 5,
              completedRides: 4,
              cancelledRides: 1,
            },
            // stale today row must be ignored in favour of live aggregate
            {
              date: new Date('2026-10-04T06:00:00.000Z'),
              totalRides: 999,
              completedRides: 999,
              cancelledRides: 0,
            },
          ]),
        },
      };
      const aggregateDailyStat = vi.fn(async () => ({
        ...emptyTotals,
        totalRides: 3,
        completedRides: 2,
        cancelledRides: 1,
      }));
      const service = new DashboardService(prisma as never, {
        aggregateDailyStat,
        computeDailyStat: vi.fn(),
      } as never);

      const chart = await service.ridesChart(admin, {
        from: '2026-10-02',
        to: '2026-10-04',
        branchId: 'branch-1',
      });
      expect(chart).toEqual([
        { date: '2026-10-02', total: 10, completed: 8, cancelled: 2 },
        { date: '2026-10-03', total: 5, completed: 4, cancelled: 1 },
        { date: '2026-10-04', total: 3, completed: 2, cancelled: 1 },
      ]);
      expect(aggregateDailyStat).toHaveBeenCalled();
    } finally {
      vi.useRealTimers();
    }
  });

  it('5. sync under threshold; async over threshold yields READY + signed URL', async () => {
    const bookings = [
      {
        id: 'b1',
        trackingId: 'BC-1',
        createdAt: new Date('2026-09-10T12:00:00.000Z'),
        status: 'CLOSED',
        source: 'DISPATCH',
        paymentMethod: 'CASH',
        paymentStatus: 'PAID',
        passengerName: 'Pat',
        passengerPhone: '+14035550100',
        driver: { firstName: 'Priya', lastName: 'Shah' },
        vehicle: { plateNumber: 'LTH111' },
        vehicleTypeId: 'vt-1',
        corporateAccountId: null,
        quotedFareCents: 1000,
        finalSubtotalCents: 1000,
        finalFareCents: 1050,
        branchId: 'branch-1',
        stops: [],
      },
    ];
    const syncPrisma = {
      booking: {
        count: vi.fn(async () => 1),
        findMany: vi.fn(async () => bookings),
      },
      generatedReport: { create: vi.fn() },
    };
    const sync = new BookingReportService(
      syncPrisma as never,
      {
        get: (k: string) =>
          k === 'REPORT_ASYNC_THRESHOLD_ROWS' ? '5000' : '180',
      } as never,
      { notify: vi.fn() } as never,
      { buildBookingReportPdf: vi.fn() } as never,
      { enqueueBookingReport: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    );
    await expect(sync.buildReport(dto(), admin)).resolves.toMatchObject({
      async: false,
      rowCount: 1,
    });

    const enqueue = vi.fn(async () => undefined);
    const asyncPrisma = {
      booking: {
        count: vi.fn(async () => 5001),
        findMany: vi.fn(async () => []),
      },
      generatedReport: {
        create: vi.fn(async ({ data }) => ({ id: 'rep-1', ...data })),
        findUnique: vi
          .fn()
          .mockResolvedValueOnce({
            id: 'rep-1',
            branchId: 'branch-1',
            requestedById: 'admin-1',
            status: 'QUEUED',
          })
          .mockResolvedValueOnce({
            id: 'rep-1',
            branchId: 'branch-1',
            status: 'READY',
            storageKey: 'reports/branch-1/rep-1.csv',
          }),
        update: vi.fn(async ({ data }) => data),
      },
    };
    const signedUrl = vi.fn(async () => 'https://r2.example/rep-1.csv?sig=1');
    const putObject = vi.fn(async () => undefined);
    const service = new BookingReportService(
      asyncPrisma as never,
      {
        get: (k: string) =>
          k === 'REPORT_ASYNC_THRESHOLD_ROWS'
            ? '5000'
            : k === 'REPORT_SIGNED_URL_TTL_SECONDS'
              ? '3600'
              : '180',
      } as never,
      { notify: vi.fn() } as never,
      { buildBookingReportPdf: vi.fn() } as never,
      { enqueueBookingReport: enqueue } as never,
      { putObject, signedUrl } as never,
    );

    await expect(service.buildReport(dto({ format: 'csv' }), admin)).resolves.toEqual({
      async: true,
      reportId: 'rep-1',
      rowCount: 5001,
    });
    expect(enqueue).toHaveBeenCalled();

    await service.processBookingReportJob({
      reportId: 'rep-1',
      where: {
        branchId: 'branch-1',
        createdAt: {
          gte: '2026-09-01T00:00:00.000Z',
          lt: '2026-10-01T00:00:00.000Z',
        },
      },
      format: 'csv',
    });
    expect(putObject).toHaveBeenCalled();
    expect(asyncPrisma.generatedReport.update).toHaveBeenCalledWith({
      where: { id: 'rep-1' },
      data: expect.objectContaining({ status: 'READY' }),
    });

    await expect(service.download(admin, 'rep-1')).resolves.toEqual({
      url: 'https://r2.example/rep-1.csv?sig=1',
      expiresIn: 3600,
    });
  });

  it('6. CSV round-trips to the expected row count and values', () => {
    const row = toReportRow({
      id: 'b1',
      trackingId: 'BC-42',
      createdAt: new Date('2026-09-10T12:00:00.000Z'),
      status: 'CLOSED',
      source: 'DISPATCH',
      paymentMethod: 'CASH',
      paymentStatus: 'PAID',
      passengerName: 'Pat Lee',
      passengerPhone: '+14035550100',
      driver: { firstName: 'Priya', lastName: 'Shah' },
      vehicle: { plateNumber: 'LTH111' },
      vehicleTypeId: 'vt-1',
      corporateAccountId: null,
      quotedFareCents: 1000,
      finalSubtotalCents: 1000,
      finalFareCents: 1050,
      branchId: 'branch-1',
      stops: [
        { type: 'PICKUP', address: '100 Main', sequence: 0 },
        { type: 'DROPOFF', address: '200 Center', sequence: 1 },
      ],
    });
    const csv = rowsToCsv([row]);
    const lines = csv.trimEnd().split('\n');
    expect(lines).toHaveLength(2);
    expect(lines[1]).toContain('BC-42');
    expect(lines[1]).toContain('Pat Lee');
    expect(lines[1]).toContain('Priya Shah');
    expect(lines[1]).toContain('100 Main');
    expect(lines[1]).toContain('1050');
  });

  it('7. invoice PDF builder returns a non-empty reasonable buffer', async () => {
    const pdf = new PdfService();
    const buf = await pdf.buildInvoicePdf(
      {
        number: 'INV-2026-0001',
        createdAt: new Date('2026-10-01T00:00:00.000Z'),
        dueAt: new Date('2026-10-31T00:00:00.000Z'),
        subtotalCents: 10_000,
        taxCents: 500,
        totalCents: 10_500,
        lines: [
          {
            completedAt: new Date('2026-09-15T00:00:00.000Z'),
            trackingId: 'BC-9',
            subtotalCents: 10_000,
            taxCents: 500,
          },
        ],
      },
      { name: 'Prairie Hotel', billingAddress: '500 Scenic Dr S' },
      { name: 'Lethbridge', city: 'Lethbridge' },
    );
    expect(buf.subarray(0, 4).toString('utf8')).toBe('%PDF');
    expect(buf.byteLength).toBeGreaterThan(500);
    expect(buf.byteLength).toBeLessThan(500_000);
  });

  it('8. report download refuses foreign branch and QUEUED status', async () => {
    const findUnique = vi.fn();
    const service = new BookingReportService(
      { generatedReport: { findUnique } } as never,
      { get: () => '3600' } as never,
      { notify: vi.fn() } as never,
      { buildBookingReportPdf: vi.fn() } as never,
      { enqueueBookingReport: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    );

    findUnique.mockResolvedValueOnce({
      id: 'rep-1',
      branchId: 'branch-1',
      status: 'QUEUED',
      storageKey: null,
    });
    const queued = service.download(admin, 'rep-1');
    await expect(queued).rejects.toBeInstanceOf(ConflictException);
    await expect(queued).rejects.toMatchObject({
      response: { code: ApiCode.REPORT_NOT_READY, status: 'QUEUED' },
    });

    findUnique.mockResolvedValueOnce({
      id: 'rep-1',
      branchId: 'branch-2',
      status: 'READY',
      storageKey: 'reports/branch-2/rep-1.csv',
    });
    await expect(service.download(admin, 'rep-1')).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });

  it('9. closed Step 8 audit gaps each produce an AuditLog row', async () => {
    const create = vi.fn(async () => ({}));
    const interceptor = new AuditInterceptor(
      {
        get: (_key: string, handler: (...args: unknown[]) => unknown) =>
          Reflect.getMetadata(AUDIT_KEY, handler),
      } as unknown as Reflector,
      { auditLog: { create } } as never,
    );

    const cases: Array<{
      meta: { entity: string; action: string };
      result: { id: string };
      label: string;
    }> = [
      {
        label: 'approve driver',
        meta: { entity: 'driver', action: 'approved' },
        result: { id: 'drv-1' },
      },
      {
        label: 'reject document',
        meta: { entity: 'document', action: 'reviewed' },
        result: { id: 'doc-1' },
      },
      {
        label: 'edit lease',
        meta: { entity: 'lease_agreement', action: 'updated' },
        result: { id: 'lease-1' },
      },
      {
        label: 'create promo',
        meta: { entity: 'promo_code', action: 'created' },
        result: { id: 'promo-1' },
      },
    ];

    // Controllers carry the decorator metadata the interceptor reads
    expect(
      Reflect.getMetadata(AUDIT_KEY, DriversController.prototype.approve),
    ).toEqual({ entity: 'driver', action: 'approved' });
    expect(
      Reflect.getMetadata(AUDIT_KEY, DocumentsController.prototype.review),
    ).toEqual({ entity: 'document', action: 'reviewed' });
    expect(
      Reflect.getMetadata(AUDIT_KEY, LeaseAgreementsController.prototype.update),
    ).toEqual({ entity: 'lease_agreement', action: 'updated' });
    expect(
      Reflect.getMetadata(AUDIT_KEY, PromosController.prototype.create),
    ).toEqual({ entity: 'promo_code', action: 'created' });

    for (const c of cases) {
      create.mockClear();
      const handler = Object.assign(() => undefined, {});
      Reflect.defineMetadata(AUDIT_KEY, c.meta, handler);
      const ctx = {
        getHandler: () => handler,
        switchToHttp: () => ({
          getRequest: () => ({
            user: admin,
            params: { id: c.result.id },
          }),
        }),
      } as unknown as ExecutionContext;
      const next: CallHandler = { handle: () => of(c.result) };
      await lastValueFrom(interceptor.intercept(ctx, next));
      await vi.waitFor(() => expect(create).toHaveBeenCalled());
      expect(create).toHaveBeenCalledWith({
        data: expect.objectContaining({
          entity: c.meta.entity,
          action: c.meta.action,
          entityId: c.result.id,
          actorUserId: admin.userId,
          actorType: 'STAFF',
        }),
      });
    }
  });

  it('10. GET /audit-logs filters by entity/date and refuses non-super-admins', async () => {
    const findMany = vi.fn(async () => [
      {
        id: 'a1',
        entity: 'promo_code',
        action: 'created',
        entityId: 'p1',
        createdAt: new Date('2026-10-03T12:00:00.000Z'),
      },
    ]);
    const count = vi.fn(async () => 1);
    const service = new AuditLogsService({
      $transaction: vi.fn(async (ops: Promise<unknown>[]) => Promise.all(ops)),
      auditLog: { count, findMany },
    } as never);

    const from = new Date('2026-10-01T00:00:00.000Z');
    const to = new Date('2026-10-04T23:59:59.000Z');
    const page = await service.list({
      entity: 'promo_code',
      from,
      to,
      page: 1,
      pageSize: 20,
    });
    expect(page.meta.total).toBe(1);
    expect(page.data[0]?.entity).toBe('promo_code');
    expect(findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: {
          entity: 'promo_code',
          createdAt: { gte: from, lte: to },
        },
        orderBy: { createdAt: 'desc' },
      }),
    );

    const { AuditLogsController } = await import(
      './audit/audit-logs.controller.js'
    );
    expect(
      Reflect.getMetadata('roles', AuditLogsController.prototype.list),
    ).toEqual(['super_admin']);

    const guard = new RolesGuard(new Reflector());
    const ctxFor = (role: string) =>
      ({
        getType: () => 'http',
        getHandler: () => AuditLogsController.prototype.list,
        getClass: () => AuditLogsController,
        switchToHttp: () => ({
          getRequest: () => ({
            user: { userId: 'u1', role, branchId: 'branch-1' },
          }),
        }),
      }) as unknown as ExecutionContext;

    expect(guard.canActivate(ctxFor('super_admin'))).toBe(true);
    expect(() => guard.canActivate(ctxFor('branch_admin'))).toThrow(
      ForbiddenException,
    );
    expect(() => guard.canActivate(ctxFor(superAdmin.role))).not.toThrow();
  });
});
