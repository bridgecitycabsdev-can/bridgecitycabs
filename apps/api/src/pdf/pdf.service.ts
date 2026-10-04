import { Injectable } from '@nestjs/common';
import { createRequire } from 'node:module';
import type { Content, TableCell, TDocumentDefinitions } from 'pdfmake/interfaces.js';

const require = createRequire(import.meta.url);

type PdfMakeInstance = {
  setFonts(fonts: Record<string, unknown>): void;
  setUrlAccessPolicy(cb: (url: string) => boolean): void;
  setLocalAccessPolicy(cb: (path: string) => boolean): void;
  createPdf(
    docDefinition: TDocumentDefinitions,
  ): { getBuffer(): Promise<Buffer> };
};

/** Canadian-friendly default (Helvetica). Swap branded fonts via setFonts later. */
const FONTS = {
  Helvetica: {
    normal: 'Helvetica',
    bold: 'Helvetica-Bold',
    italics: 'Helvetica-Oblique',
    bolditalics: 'Helvetica-BoldOblique',
  },
};

export type BookingReportPdfRow = {
  trackingId: string;
  date: string;
  pickup: string;
  dropoff: string;
  driver: string | null;
  fareDisplay: string;
  status: string;
};

export type InvoicePdfLine = {
  completedAt: Date | null;
  trackingId: string;
  subtotalCents: number;
  taxCents: number;
};

export type InvoicePdfInput = {
  number: string;
  createdAt: Date;
  dueAt: Date | null;
  subtotalCents: number;
  taxCents: number;
  totalCents: number;
  lines: InvoicePdfLine[];
};

export type DailySummaryPdfStat = {
  branchName: string;
  dateLocal: string;
  totalRides: number;
  completedRides: number;
  cancelledRides: number;
  unpaidRides: number;
  prepaidRides: number;
  postpaidRides: number;
  accountCalls: number;
  sourceDispatch: number;
  sourceDriverApp: number;
  sourcePassengerApp: number;
  grossSubtotalCents: number;
};

@Injectable()
export class PdfService {
  private readonly pdfmake: PdfMakeInstance;

  constructor() {
    this.pdfmake = require('pdfmake') as PdfMakeInstance;
    this.pdfmake.setFonts(FONTS);
    // No external URL fetches; standard PDF fonts are allowed locally.
    this.pdfmake.setUrlAccessPolicy(() => false);
    this.pdfmake.setLocalAccessPolicy(() => true);
  }

  buildBookingReportPdf(
    rows: BookingReportPdfRow[],
    meta: { branch: string; from: string; to: string },
  ): Promise<Buffer> {
    const body: TableCell[][] = [
      [
        'Tracking ID',
        'Date',
        'Pickup',
        'Drop-off',
        'Driver',
        'Fare',
        'Status',
      ].map((text) => ({ text, style: 'th' })),
      ...rows.map((r) => [
        r.trackingId,
        r.date,
        r.pickup,
        r.dropoff,
        r.driver ?? '—',
        r.fareDisplay,
        r.status,
      ]),
    ];

    return this.render({
      pageOrientation: 'landscape',
      pageMargins: [28, 40, 28, 40],
      defaultStyle: { font: 'Helvetica', fontSize: 8 },
      content: [
        { text: 'BridgeCabs — Booking Report', style: 'header' },
        {
          text: `${meta.branch}  |  ${meta.from} to ${meta.to}`,
          style: 'subheader',
        },
        {
          table: {
            headerRows: 1,
            widths: ['auto', 'auto', '*', '*', 'auto', 'auto', 'auto'],
            body,
          },
          layout: 'lightHorizontalLines',
        },
      ],
      styles: {
        header: { fontSize: 16, bold: true },
        subheader: {
          fontSize: 10,
          color: '#666',
          margin: [0, 2, 0, 12],
        },
        th: { bold: true, fillColor: '#f0f0f0' },
      },
    });
  }

  buildInvoicePdf(
    invoice: InvoicePdfInput,
    account: { name: string; billingAddress: string | null },
    branch: { name: string; city: string },
  ): Promise<Buffer> {
    const lineBody: TableCell[][] = [
      ['Date', 'Trip', 'Subtotal', 'GST'].map((text) => ({
        text,
        style: 'th',
      })),
      ...invoice.lines.map((l) => [
        fmtDate(l.completedAt),
        l.trackingId,
        fmtCents(l.subtotalCents),
        fmtCents(l.taxCents),
      ]),
    ];

    return this.render({
      pageMargins: [40, 48, 40, 48],
      defaultStyle: { font: 'Helvetica', fontSize: 10 },
      content: [
        { text: 'INVOICE', style: 'header' },
        {
          columns: [
            { text: `${branch.name}\n${branch.city}, AB` },
            {
              text: `Invoice #${invoice.number}\nDate: ${fmtDate(invoice.createdAt)}\nDue: ${fmtDate(invoice.dueAt)}`,
              alignment: 'right',
            },
          ],
          margin: [0, 12, 0, 0],
        },
        {
          text: `Bill to: ${account.name}\n${account.billingAddress ?? ''}`,
          margin: [0, 16, 0, 16],
        },
        {
          table: {
            headerRows: 1,
            widths: ['auto', '*', 'auto', 'auto'],
            body: lineBody,
          },
          layout: 'lightHorizontalLines',
        },
        {
          text: `Subtotal: ${fmtCents(invoice.subtotalCents)}\nGST: ${fmtCents(invoice.taxCents)}\nTotal: ${fmtCents(invoice.totalCents)}`,
          alignment: 'right',
          margin: [0, 12, 0, 0],
          bold: true,
        },
      ],
      styles: {
        header: { fontSize: 18, bold: true },
        th: { bold: true, fillColor: '#f0f0f0' },
      },
    });
  }

  /**
   * One page per branch for a calendar date — legacy "PDF Reports" daily summary.
   * Auto email after Day 14; generation is available on demand now.
   */
  buildDailySummaryPdf(
    stats: DailySummaryPdfStat[],
    meta: { dateLocal: string },
  ): Promise<Buffer> {
    const pages: Content[] = [];
    for (const [index, stat] of stats.entries()) {
      if (index > 0) pages.push({ text: '', pageBreak: 'before' });
      pages.push(
        { text: 'BridgeCabs — Daily Summary', style: 'header' },
        {
          text: `${stat.branchName}  |  ${stat.dateLocal || meta.dateLocal}`,
          style: 'subheader',
        },
        {
          table: {
            widths: ['*', 'auto'],
            body: [
              ['Total rides', String(stat.totalRides)],
              ['Completed', String(stat.completedRides)],
              ['Cancelled', String(stat.cancelledRides)],
              ['Unpaid', String(stat.unpaidRides)],
              ['Prepaid (CARD)', String(stat.prepaidRides)],
              ['Postpaid (CASH/ACCOUNT)', String(stat.postpaidRides)],
              ['Account calls', String(stat.accountCalls)],
              ['Source — dispatch', String(stat.sourceDispatch)],
              ['Source — driver app', String(stat.sourceDriverApp)],
              ['Source — passenger app', String(stat.sourcePassengerApp)],
              ['Gross subtotal', fmtCents(stat.grossSubtotalCents)],
            ],
          },
          layout: 'lightHorizontalLines',
        },
      );
    }

    if (pages.length === 0) {
      pages.push(
        { text: 'BridgeCabs — Daily Summary', style: 'header' },
        { text: `No branch stats for ${meta.dateLocal}`, style: 'subheader' },
      );
    }

    return this.render({
      pageMargins: [40, 48, 40, 48],
      defaultStyle: { font: 'Helvetica', fontSize: 11 },
      content: pages,
      styles: {
        header: { fontSize: 16, bold: true },
        subheader: {
          fontSize: 10,
          color: '#666',
          margin: [0, 2, 0, 16],
        },
      },
    });
  }

  private render(docDef: TDocumentDefinitions): Promise<Buffer> {
    return this.pdfmake.createPdf(docDef).getBuffer();
  }
}

export function fmtCents(cents: number) {
  const sign = cents < 0 ? '-' : '';
  const abs = Math.abs(cents);
  return `${sign}$${(abs / 100).toFixed(2)}`;
}

export function fmtDate(value: Date | string | null | undefined) {
  if (!value) return '—';
  const d = typeof value === 'string' ? new Date(value) : value;
  if (Number.isNaN(d.getTime())) return '—';
  return d.toISOString().slice(0, 10);
}
