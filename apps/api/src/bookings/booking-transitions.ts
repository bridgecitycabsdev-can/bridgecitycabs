import { BookingStatus, Prisma } from '@prisma/client';

export type Actor = 'SYSTEM' | 'STAFF' | 'PASSENGER' | 'DRIVER';

type Map = Partial<Record<BookingStatus, Actor[]>>;

export const TRANSITIONS: Partial<Record<BookingStatus, Map>> = {
  SCHEDULED: {
    CREATED: ['SYSTEM'],
    CANCELLED: ['PASSENGER', 'STAFF'],
  },
  CREATED: {
    SEARCHING_DRIVER: ['SYSTEM', 'STAFF'],
    CANCELLED: ['PASSENGER', 'STAFF'],
  },
  SEARCHING_DRIVER: {
    MATCHED: ['SYSTEM'],
    DRIVER_ASSIGNED: ['STAFF'],
    NO_DRIVER_FOUND: ['SYSTEM'],
    CANCELLED: ['PASSENGER', 'STAFF'],
  },
  MATCHED: {
    DRIVER_ASSIGNED: ['DRIVER', 'SYSTEM'],
    SEARCHING_DRIVER: ['SYSTEM'],
    CANCELLED: ['PASSENGER', 'STAFF'],
  },
  DRIVER_ASSIGNED: {
    DRIVER_ARRIVING: ['DRIVER', 'SYSTEM'],
    SEARCHING_DRIVER: ['DRIVER', 'STAFF', 'SYSTEM'],
    CANCELLED: ['PASSENGER', 'STAFF'],
  },
  DRIVER_ARRIVING: {
    DRIVER_ARRIVED: ['DRIVER', 'SYSTEM'],
    SEARCHING_DRIVER: ['DRIVER', 'STAFF'],
    CANCELLED: ['PASSENGER', 'STAFF'],
  },
  DRIVER_ARRIVED: {
    TRIP_STARTED: ['DRIVER', 'STAFF'],
    SEARCHING_DRIVER: ['DRIVER', 'STAFF'],
    CANCELLED: ['PASSENGER', 'STAFF', 'DRIVER'],
  },
  TRIP_STARTED: { TRIP_COMPLETED: ['DRIVER', 'STAFF'] },
  TRIP_COMPLETED: { PAYMENT_PENDING: ['SYSTEM'] },
  PAYMENT_PENDING: { PAYMENT_COMPLETED: ['SYSTEM', 'STAFF', 'DRIVER'] },
  PAYMENT_COMPLETED: { CLOSED: ['SYSTEM'] },
  NO_DRIVER_FOUND: {
    SEARCHING_DRIVER: ['STAFF', 'PASSENGER'],
    CANCELLED: ['PASSENGER', 'STAFF'],
  },
  // CLOSED and CANCELLED are terminal
};

/** Statuses covered by one_active_booking_per_driver. */
export const LIVE_BOOKING_STATUSES = [
  'MATCHED',
  'DRIVER_ASSIGNED',
  'DRIVER_ARRIVING',
  'DRIVER_ARRIVED',
  'TRIP_STARTED',
] as const satisfies readonly BookingStatus[];

/** Statuses that hold a driver snapshot. Search clears it, including a MATCHED reservation. */
const ASSIGNED_STATUSES: readonly BookingStatus[] = [
  'MATCHED',
  'DRIVER_ASSIGNED',
  'DRIVER_ARRIVING',
  'DRIVER_ARRIVED',
];

export function stampFor(
  to: BookingStatus,
  now = new Date(),
): Prisma.BookingUncheckedUpdateManyInput {
  switch (to) {
    case 'DRIVER_ARRIVED':
      return { arrivedAt: now };
    case 'TRIP_STARTED':
      return { startedAt: now };
    case 'TRIP_COMPLETED':
      return { completedAt: now };
    case 'CLOSED':
      return { closedAt: now };
    case 'CANCELLED':
      return { cancelledAt: now };
    default:
      return {};
  }
}

export function driverRelease(
  from: BookingStatus,
  to: BookingStatus,
): Prisma.BookingUncheckedUpdateManyInput {
  if (to !== 'SEARCHING_DRIVER' || !ASSIGNED_STATUSES.includes(from)) {
    return {};
  }
  return { driverId: null, vehicleId: null };
}
