import type { DriverPresenceState } from '@bridgecabs/shared-types';
import type { BookingStatus } from '@prisma/client';

const PRESENCE_BY_BOOKING: Partial<Record<BookingStatus, DriverPresenceState>> = {
  MATCHED: 'OFFERED',
  DRIVER_ASSIGNED: 'ASSIGNED',
  DRIVER_ARRIVING: 'EN_ROUTE_PICKUP',
  DRIVER_ARRIVED: 'ARRIVED',
  TRIP_STARTED: 'ON_TRIP',
};

export function presenceFromBooking(status: BookingStatus | null): DriverPresenceState {
  if (!status) return 'AVAILABLE';
  return PRESENCE_BY_BOOKING[status] ?? 'AVAILABLE';
}

/** Presence written when this booking status is committed. Payment does not move the driver. */
const PRESENCE_ON_STATUS: Partial<Record<BookingStatus, DriverPresenceState>> = {
  MATCHED: 'OFFERED',
  DRIVER_ASSIGNED: 'ASSIGNED',
  DRIVER_ARRIVING: 'EN_ROUTE_PICKUP',
  DRIVER_ARRIVED: 'ARRIVED',
  TRIP_STARTED: 'ON_TRIP',
  TRIP_COMPLETED: 'AVAILABLE',
  SEARCHING_DRIVER: 'AVAILABLE',
  CANCELLED: 'AVAILABLE',
  NO_DRIVER_FOUND: 'AVAILABLE',
};

export function presenceOnBookingStatus(status: BookingStatus): DriverPresenceState | null {
  return PRESENCE_ON_STATUS[status] ?? null;
}

/** Statuses that refresh pendingPayment without changing presence. */
export const PAYMENT_SNAPSHOT_STATUSES = new Set<BookingStatus>([
  'PAYMENT_PENDING',
  'PAYMENT_COMPLETED',
  'CLOSED',
]);

const RELEASE_STATUSES = new Set<BookingStatus>([
  'SEARCHING_DRIVER',
  'CANCELLED',
  'NO_DRIVER_FOUND',
]);

/**
 * Driver to free when a booking leaves them.
 * Assignments are newest ended first. A booking that already moved on keeps its new driver.
 */
export function driverIdReleasedBy(
  eventTo: BookingStatus,
  booking: { status: BookingStatus; driverId: string | null },
  assignmentsNewestEndedFirst: readonly string[],
) {
  if (!RELEASE_STATUSES.has(eventTo)) return null;
  const movedOn = booking.status !== eventTo && booking.driverId != null;
  if (!movedOn && booking.driverId) return booking.driverId;
  const exclude = movedOn ? booking.driverId : null;
  return assignmentsNewestEndedFirst.find((id) => id !== exclude) ?? null;
}

type OfferStop = {
  type: string;
  address: string;
  lat: number;
  lng: number;
};

/** Offer card for a driver who is OFFERED. serverNow lets a reconnect compute time remaining. */
export function driverOfferSnapshot(
  offer: { id: string; expiresAt: Date; distanceToPickupM: number },
  booking: {
    distanceMeters: number;
    quotedFareCents: number;
    paymentMethod: 'CASH' | 'CARD' | 'WALLET' | 'ACCOUNT';
    vanOnly: boolean;
    ladyDriverOnly: boolean;
    notes: string | null;
    passengerName: string;
    passengerFirstName: string | null | undefined;
    stops: readonly OfferStop[];
  },
  serverNow: Date,
) {
  const pickup = booking.stops.find((stop) => stop.type === 'PICKUP') ?? booking.stops[0];
  const dropoff =
    [...booking.stops].reverse().find((stop) => stop.type === 'DROPOFF') ??
    booking.stops[booking.stops.length - 1];
  if (!pickup || !dropoff) return null;
  return {
    id: offer.id,
    expiresAt: offer.expiresAt.toISOString(),
    serverNow: serverNow.toISOString(),
    pickup: { address: pickup.address, lat: pickup.lat, lng: pickup.lng },
    dropoff: { address: dropoff.address, lat: dropoff.lat, lng: dropoff.lng },
    distanceToPickupM: offer.distanceToPickupM,
    tripDistanceM: booking.distanceMeters,
    quotedFareCents: booking.quotedFareCents,
    paymentMethod: booking.paymentMethod,
    vanOnly: booking.vanOnly,
    ladyDriverOnly: booking.ladyDriverOnly,
    passengerFirstName: passengerFirstName(booking.passengerFirstName, booking.passengerName),
    notes: booking.notes,
  };
}

export function passengerFirstName(
  accountFirstName: string | null | undefined,
  passengerName: string,
) {
  const fromAccount = accountFirstName?.trim();
  if (fromAccount) return fromAccount;
  const token = passengerName.trim().split(/\s+/)[0];
  return token || 'Passenger';
}
