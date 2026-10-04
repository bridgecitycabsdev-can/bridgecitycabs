import { fmtCents } from '../pdf/pdf.service.js';
import type { BookingReportPdfRow } from '../pdf/pdf.service.js';

export type ReportBookingRow = {
  id: string;
  trackingId: string;
  createdAt: string;
  status: string;
  source: string;
  paymentMethod: string;
  paymentStatus: string;
  passengerName: string;
  passengerPhone: string;
  driverName: string | null;
  vehiclePlate: string | null;
  vehicleTypeId: string;
  corporateAccountId: string | null;
  quotedFareCents: number;
  finalSubtotalCents: number | null;
  finalFareCents: number | null;
  branchId: string;
  pickup: string;
  dropoff: string;
  fareDisplay: string;
};

export function toReportRow(booking: {
  id: string;
  trackingId: string;
  createdAt: Date;
  status: string;
  source: string;
  paymentMethod: string;
  paymentStatus: string;
  passengerName: string;
  passengerPhone: string;
  driver: { firstName: string; lastName: string | null } | null;
  vehicle: { plateNumber: string } | null;
  vehicleTypeId: string;
  corporateAccountId: string | null;
  quotedFareCents: number;
  finalSubtotalCents: number | null;
  finalFareCents: number | null;
  branchId: string;
  stops?: Array<{ type: string; address: string; sequence: number }>;
}): ReportBookingRow {
  const stops = [...(booking.stops ?? [])].sort(
    (a, b) => a.sequence - b.sequence,
  );
  const pickup =
    stops.find((s) => s.type === 'PICKUP')?.address ??
    stops[0]?.address ??
    '—';
  const dropoff =
    [...stops].reverse().find((s) => s.type === 'DROPOFF')?.address ??
    stops[stops.length - 1]?.address ??
    '—';
  const fareCents = booking.finalFareCents ?? booking.quotedFareCents;
  const driverName = booking.driver
    ? [booking.driver.firstName, booking.driver.lastName]
        .filter(Boolean)
        .join(' ')
    : null;

  return {
    id: booking.id,
    trackingId: booking.trackingId,
    createdAt: booking.createdAt.toISOString(),
    status: booking.status,
    source: booking.source,
    paymentMethod: booking.paymentMethod,
    paymentStatus: booking.paymentStatus,
    passengerName: booking.passengerName,
    passengerPhone: booking.passengerPhone,
    driverName,
    vehiclePlate: booking.vehicle?.plateNumber ?? null,
    vehicleTypeId: booking.vehicleTypeId,
    corporateAccountId: booking.corporateAccountId,
    quotedFareCents: booking.quotedFareCents,
    finalSubtotalCents: booking.finalSubtotalCents,
    finalFareCents: booking.finalFareCents,
    branchId: booking.branchId,
    pickup,
    dropoff,
    fareDisplay: fmtCents(fareCents),
  };
}

export function toBookingReportPdfRows(
  rows: ReportBookingRow[],
): BookingReportPdfRow[] {
  return rows.map((r) => ({
    trackingId: r.trackingId,
    date: r.createdAt.slice(0, 10),
    pickup: r.pickup,
    dropoff: r.dropoff,
    driver: r.driverName,
    fareDisplay: r.fareDisplay,
    status: r.status,
  }));
}

const CSV_HEADERS: (keyof ReportBookingRow)[] = [
  'id',
  'trackingId',
  'createdAt',
  'status',
  'source',
  'paymentMethod',
  'paymentStatus',
  'passengerName',
  'passengerPhone',
  'driverName',
  'vehiclePlate',
  'pickup',
  'dropoff',
  'vehicleTypeId',
  'corporateAccountId',
  'quotedFareCents',
  'finalSubtotalCents',
  'finalFareCents',
  'fareDisplay',
  'branchId',
];

export function rowsToCsv(rows: ReportBookingRow[]): string {
  const lines = [CSV_HEADERS.join(',')];
  for (const row of rows) {
    lines.push(CSV_HEADERS.map((h) => csvCell(row[h])).join(','));
  }
  return `${lines.join('\n')}\n`;
}

function csvCell(value: string | number | null | undefined) {
  if (value == null) return '';
  const raw = String(value);
  if (/[",\n\r]/.test(raw)) {
    return `"${raw.replace(/"/g, '""')}"`;
  }
  return raw;
}
