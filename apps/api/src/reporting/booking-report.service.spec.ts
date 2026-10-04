import {
  ConflictException,
  ForbiddenException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { ApiCode } from '../common/api-code.js';
import { BookingReportService } from './booking-report.service.js';
import type { ReportFilterDto } from './dto/report-filter.dto.js';

const admin = {
  userId: 'admin-1',
  role: 'branch_admin',
  branchId: 'branch-1',
};

function dto(overrides: Partial<ReportFilterDto> = {}): ReportFilterDto {
  return {
    from: '2026-09-01',
    to: '2026-09-30',
    format: 'json',
    ...overrides,
  };
}

describe('BookingReportService', () => {
  it('rejects a range wider than REPORT_MAX_RANGE_DAYS with 422', async () => {
    const service = new BookingReportService(
      { booking: { count: vi.fn() } } as never,
      { get: () => '30' } as never,
      { notify: vi.fn() } as never,
      { buildBookingReportPdf: vi.fn() } as never,
      { enqueueBookingReport: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    );
    await expect(
      service.buildReport(dto({ from: '2026-01-01', to: '2026-06-01' }), admin),
    ).rejects.toMatchObject({
      response: { code: ApiCode.REPORT_RANGE_TOO_WIDE, maxDays: 30 },
    });
    await expect(
      service.buildReport(dto({ from: '2026-01-01', to: '2026-06-01' }), admin),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
  });

  it('returns rows synchronously under the async threshold', async () => {
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
      },
    ];
    const prisma = {
      booking: {
        count: vi.fn(async () => 1),
        findMany: vi.fn(async () => bookings),
      },
      generatedReport: { create: vi.fn() },
    };
    const enqueue = vi.fn();
    const service = new BookingReportService(
      prisma as never,
      {
        get: (k: string) =>
          k === 'REPORT_ASYNC_THRESHOLD_ROWS' ? '5000' : '180',
      } as never,
      { notify: vi.fn() } as never,
      { buildBookingReportPdf: vi.fn() } as never,
      { enqueueBookingReport: enqueue } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    );

    const result = await service.buildReport(dto(), admin);
    expect(result).toMatchObject({
      async: false,
      rowCount: 1,
      rows: [expect.objectContaining({ trackingId: 'BC-1', driverName: 'Priya Shah' })],
    });
    expect(enqueue).not.toHaveBeenCalled();
    expect(prisma.generatedReport.create).not.toHaveBeenCalled();
  });

  it('queues a GeneratedReport when count exceeds the async threshold', async () => {
    const enqueue = vi.fn(async () => undefined);
    const prisma = {
      booking: { count: vi.fn(async () => 5001) },
      generatedReport: {
        create: vi.fn(async ({ data }) => ({ id: 'rep-1', ...data })),
      },
    };
    const service = new BookingReportService(
      prisma as never,
      {
        get: (k: string) =>
          k === 'REPORT_ASYNC_THRESHOLD_ROWS' ? '5000' : '180',
      } as never,
      { notify: vi.fn() } as never,
      { buildBookingReportPdf: vi.fn() } as never,
      { enqueueBookingReport: enqueue } as never,
      { putObject: vi.fn(), signedUrl: vi.fn() } as never,
    );

    await expect(service.buildReport(dto({ format: 'csv' }), admin)).resolves.toEqual({
      async: true,
      reportId: 'rep-1',
      rowCount: 5001,
    });
    expect(prisma.generatedReport.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        type: 'CUSTOM_BOOKING_REPORT',
        status: 'QUEUED',
        branchId: 'branch-1',
        requestedById: 'admin-1',
      }),
    });
    expect(enqueue).toHaveBeenCalledWith(
      expect.objectContaining({
        reportId: 'rep-1',
        format: 'csv',
        where: expect.objectContaining({ branchId: 'branch-1' }),
      }),
    );
  });

  it('download returns a signed URL only when READY and branch-accessible', async () => {
    const signedUrl = vi.fn(async () => 'https://r2.example/report.csv?sig=1');
    const findUnique = vi.fn();
    const service = new BookingReportService(
      { generatedReport: { findUnique } } as never,
      { get: () => '3600' } as never,
      { notify: vi.fn() } as never,
      { buildBookingReportPdf: vi.fn() } as never,
      { enqueueBookingReport: vi.fn() } as never,
      { putObject: vi.fn(), signedUrl } as never,
    );

    findUnique.mockResolvedValueOnce({
      id: 'rep-1',
      branchId: 'branch-1',
      status: 'QUEUED',
      storageKey: null,
    });
    await expect(service.download(admin, 'rep-1')).rejects.toMatchObject({
      response: { code: ApiCode.REPORT_NOT_READY, status: 'QUEUED' },
    });
    findUnique.mockResolvedValueOnce({
      id: 'rep-1',
      branchId: 'branch-1',
      status: 'GENERATING',
      storageKey: null,
    });
    await expect(service.download(admin, 'rep-1')).rejects.toBeInstanceOf(
      ConflictException,
    );

    findUnique.mockResolvedValueOnce({
      id: 'rep-1',
      branchId: 'branch-2',
      status: 'READY',
      storageKey: 'reports/branch-2/rep-1.csv',
    });
    await expect(service.download(admin, 'rep-1')).rejects.toBeInstanceOf(
      ForbiddenException,
    );

    findUnique.mockResolvedValueOnce({
      id: 'rep-1',
      branchId: 'branch-1',
      status: 'READY',
      storageKey: 'reports/branch-1/rep-1.csv',
    });
    await expect(service.download(admin, 'rep-1')).resolves.toEqual({
      url: 'https://r2.example/report.csv?sig=1',
      expiresIn: 3600,
    });
    expect(signedUrl).toHaveBeenCalledWith(
      'reports/branch-1/rep-1.csv',
      3600,
    );
  });

  it('processBookingReportJob uploads, marks READY, and notifies', async () => {
    const putObject = vi.fn(async () => undefined);
    const notify = vi.fn(async () => ({}));
    const prisma = {
      generatedReport: {
        findUnique: vi.fn(async () => ({
          id: 'rep-1',
          branchId: 'branch-1',
          requestedById: 'admin-1',
          status: 'QUEUED',
        })),
        update: vi.fn(async ({ data }) => data),
      },
      booking: { findMany: vi.fn(async () => []) },
    };
    const service = new BookingReportService(
      prisma as never,
      { get: () => undefined } as never,
      { notify } as never,
      { buildBookingReportPdf: vi.fn() } as never,
      { enqueueBookingReport: vi.fn() } as never,
      { putObject, signedUrl: vi.fn() } as never,
    );

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

    expect(putObject).toHaveBeenCalledWith(
      'reports/branch-1/rep-1.csv',
      expect.any(Buffer),
      'text/csv; charset=utf-8',
    );
    expect(prisma.generatedReport.update).toHaveBeenCalledWith({
      where: { id: 'rep-1' },
      data: expect.objectContaining({
        status: 'READY',
        storageKey: 'reports/branch-1/rep-1.csv',
        rowCount: 0,
      }),
    });
    expect(notify).toHaveBeenCalledWith(
      'admin-1',
      'REPORT_READY',
      'Report ready',
      expect.any(String),
      expect.objectContaining({ reportId: 'rep-1' }),
    );
  });
});
