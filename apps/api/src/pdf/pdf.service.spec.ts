import { describe, expect, it } from 'vitest';
import { fmtCents, fmtDate, PdfService } from './pdf.service.js';

describe('PdfService', () => {
  const pdf = new PdfService();

  it('formats CAD cents and dates', () => {
    expect(fmtCents(1050)).toBe('$10.50');
    expect(fmtCents(-25)).toBe('-$0.25');
    expect(fmtDate(new Date('2026-10-04T12:00:00.000Z'))).toBe('2026-10-04');
    expect(fmtDate(null)).toBe('—');
  });

  it('builds a booking report PDF buffer', async () => {
    const buf = await pdf.buildBookingReportPdf(
      [
        {
          trackingId: 'BC-1',
          date: '2026-10-01',
          pickup: 'A',
          dropoff: 'B',
          driver: 'Priya Shah',
          fareDisplay: '$10.50',
          status: 'CLOSED',
        },
      ],
      { branch: 'Lethbridge', from: '2026-10-01', to: '2026-10-01' },
    );
    expect(buf.subarray(0, 4).toString('utf8')).toBe('%PDF');
  });

  it('builds an invoice PDF buffer', async () => {
    const buf = await pdf.buildInvoicePdf(
      {
        number: 'INV-2026-0001',
        createdAt: new Date('2026-10-01T00:00:00.000Z'),
        dueAt: new Date('2026-10-31T00:00:00.000Z'),
        subtotalCents: 1000,
        taxCents: 50,
        totalCents: 1050,
        lines: [
          {
            completedAt: new Date('2026-09-15T00:00:00.000Z'),
            trackingId: 'BC-9',
            subtotalCents: 1000,
            taxCents: 50,
          },
        ],
      },
      { name: 'Prairie Hotel', billingAddress: '500 Scenic Dr S' },
      { name: 'Lethbridge', city: 'Lethbridge' },
    );
    expect(buf.subarray(0, 4).toString('utf8')).toBe('%PDF');
  });

  it('builds a daily summary PDF with one page per branch', async () => {
    const buf = await pdf.buildDailySummaryPdf(
      [
        {
          branchName: 'Lethbridge',
          dateLocal: '2026-10-03',
          totalRides: 12,
          completedRides: 10,
          cancelledRides: 2,
          unpaidRides: 1,
          prepaidRides: 4,
          postpaidRides: 8,
          accountCalls: 3,
          sourceDispatch: 6,
          sourceDriverApp: 0,
          sourcePassengerApp: 6,
          grossSubtotalCents: 50_000,
        },
      ],
      { dateLocal: '2026-10-03' },
    );
    expect(buf.subarray(0, 4).toString('utf8')).toBe('%PDF');
  });
});
