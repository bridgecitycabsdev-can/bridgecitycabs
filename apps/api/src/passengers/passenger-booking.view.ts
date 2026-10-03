import type { PassengerBooking } from '@bridgecabs/shared-types';
import { passengerBookingSchema } from '@bridgecabs/shared-types';
import { BookingStatus, Prisma, StopType } from '@prisma/client';

/** Statuses that still occupy the passenger, so a second booking is refused. */
export const PASSENGER_ACTIVE_STATUSES: BookingStatus[] = [
  'SCHEDULED',
  'CREATED',
  'SEARCHING_DRIVER',
  'MATCHED',
  'DRIVER_ASSIGNED',
  'DRIVER_ARRIVING',
  'DRIVER_ARRIVED',
  'TRIP_STARTED',
  'TRIP_COMPLETED',
  'PAYMENT_PENDING',
  'PAYMENT_COMPLETED',
  'NO_DRIVER_FOUND',
];

/** The passenger may see the driver's point only while the driver is on their trip. */
export const PASSENGER_SHARE_LOCATION_STATUSES: BookingStatus[] = [
  'DRIVER_ASSIGNED',
  'DRIVER_ARRIVING',
  'DRIVER_ARRIVED',
  'TRIP_STARTED',
];

const DRIVER_VISIBLE = new Set<BookingStatus>([
  'DRIVER_ASSIGNED',
  'DRIVER_ARRIVING',
  'DRIVER_ARRIVED',
  'TRIP_STARTED',
  'TRIP_COMPLETED',
  'PAYMENT_PENDING',
  'PAYMENT_COMPLETED',
  'CLOSED',
  'CANCELLED',
]);

export const passengerBookingInclude = {
  vehicleType: { select: { id: true, name: true } },
  stops: { orderBy: { sequence: 'asc' as const } },
  driver: { select: { firstName: true, ratingAvg: true } },
  vehicle: {
    select: {
      plateNumber: true,
      unitNumber: true,
      color: true,
      model: { select: { name: true, make: { select: { name: true } } } },
    },
  },
} satisfies Prisma.BookingInclude;

export type PassengerBookingRow = Prisma.BookingGetPayload<{
  include: typeof passengerBookingInclude;
}>;

export function toPassengerBooking(
  row: PassengerBookingRow,
  etaSeconds: number | null,
): PassengerBooking {
  const stops = [...row.stops].sort((left, right) => left.sequence - right.sequence);
  return passengerBookingSchema.parse({
    id: row.id,
    trackingId: row.trackingId,
    status: row.status,
    etaSeconds,
    scheduledAt: row.scheduledAt ? row.scheduledAt.toISOString() : null,
    quotedFareCents: row.quotedFareCents,
    quotedTaxCents: row.quotedTaxCents,
    finalSubtotalCents: row.finalSubtotalCents,
    finalTaxCents: row.finalTaxCents,
    finalFareCents: row.finalFareCents,
    notes: row.notes,
    passengerName: row.passengerName,
    vehicleType: { id: row.vehicleType.id, name: row.vehicleType.name },
    stops: stops.map((stop) => ({
      sequence: stop.sequence,
      type: stop.type,
      address: stop.address,
      lat: stop.lat,
      lng: stop.lng,
    })),
    driver: driverCard(row),
  });
}

function driverCard(row: PassengerBookingRow) {
  if (!DRIVER_VISIBLE.has(row.status) || !row.driver) return null;
  const vehicle = row.vehicle;
  return {
    firstName: row.driver.firstName,
    rating: Number(row.driver.ratingAvg),
    vehicle: vehicle
      ? {
          make: vehicle.model.make.name,
          model: vehicle.model.name,
          colour: vehicle.color,
          plate: vehicle.plateNumber,
          unitNumber: vehicle.unitNumber,
        }
      : null,
  };
}

export function stopType(index: number, count: number): StopType {
  if (index === 0) return 'PICKUP';
  if (index === count - 1) return 'DROPOFF';
  return 'STOP';
}
