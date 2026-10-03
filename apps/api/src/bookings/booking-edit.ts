import { ConflictException } from '@nestjs/common';
import type { BookingStatus } from '@prisma/client';

/** Notes stay editable while a driver is on the way. The trip itself can still change only before anyone is matched. */
const NOTES_LOCKED: readonly BookingStatus[] = [
  'TRIP_STARTED',
  'TRIP_COMPLETED',
  'PAYMENT_PENDING',
  'PAYMENT_COMPLETED',
  'CLOSED',
  'CANCELLED',
];

const TRIP_OPEN: readonly BookingStatus[] = [
  'SCHEDULED',
  'CREATED',
  'SEARCHING_DRIVER',
  'NO_DRIVER_FOUND',
];

export const TRIP_EDIT_FIELDS = [
  'passengerName',
  'passengerPhone',
  'scheduledAt',
  'vanOnly',
  'ladyDriverOnly',
  'vehicleTypeId',
  'zone',
  'stops',
  'fixedFareCents',
  'paymentMethod',
] as const;

export function editableFields(status: BookingStatus) {
  const fields: string[] = [];
  if (!NOTES_LOCKED.includes(status)) fields.push('notes');
  if (TRIP_OPEN.includes(status)) fields.push(...TRIP_EDIT_FIELDS);
  return fields;
}

export function assertEditable(status: BookingStatus, fields: readonly string[]) {
  const allowed = new Set(editableFields(status));
  const blocked = fields.filter((field) => !allowed.has(field));
  if (blocked.length === 0) return;
  if (status === 'MATCHED') {
    throw new ConflictException('An offer is open');
  }
  throw new ConflictException('This booking can no longer be edited');
}
