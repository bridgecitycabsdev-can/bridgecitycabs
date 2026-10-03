import { BookingStatus } from '@prisma/client';

export const BOOKING_TABS = {
  // Manual dispatch waits in SEARCHING_DRIVER. NO_DRIVER_FOUND stays here too.
  // MATCHED is an open auto offer, so it sits on the assigned tab until that offer is cancelled.
  unassigned: ['SCHEDULED', 'CREATED', 'SEARCHING_DRIVER', 'NO_DRIVER_FOUND'],
  assigned: ['MATCHED', 'DRIVER_ASSIGNED', 'DRIVER_ARRIVING', 'DRIVER_ARRIVED'],
  active: ['TRIP_STARTED'],
  /** Completed trips waiting on cash (or Day 10 card) confirmation. */
  payment_pending: ['PAYMENT_PENDING'],
  closed: ['TRIP_COMPLETED', 'PAYMENT_COMPLETED', 'CLOSED', 'CANCELLED'],
} as const satisfies Record<string, readonly BookingStatus[]>;

export type BookingTab = keyof typeof BOOKING_TABS;
