import { z } from 'zod';

/**
 * Socket contract shared by the API and the React apps.
 * Flutter clients mirror these JSON shapes.
 *
 * Telemetry (client → server): driver:location, driver:heartbeat, offer:received.
 * Driver pushes: driver:state, offer:new, offer:cancelled, offer:expired.
 * Dispatch pushes: booking:created, booking:status_changed, offer:created, offer:resolved.
 * Passenger pushes: trip:update. A disconnected passenger app gets the same facts as a push.
 * driver:state is a full snapshot. Clients keep the highest version.
 * offer:new carries the offer card. The lock-screen push does not.
 */

export const DRIVER_PRESENCE_STATES = [
  'OFFLINE',
  'AVAILABLE',
  'OFFERED',
  'ASSIGNED',
  'EN_ROUTE_PICKUP',
  'ARRIVED',
  'ON_TRIP',
  'AWAY',
] as const;

export const driverPresenceStateSchema = z.enum(DRIVER_PRESENCE_STATES);

/** Dispatch console filters. OFFLINE drivers are omitted from these chips. */
export const FLEET_CHIPS = ['ALL', 'BUSY', 'FREE', 'ASSIGN', 'WAIT', 'AWAY'] as const;

export type FleetChip = (typeof FLEET_CHIPS)[number];

export const FLEET_CHIP_BY_STATUS = {
  AVAILABLE: 'FREE',
  OFFERED: 'ASSIGN',
  ASSIGNED: 'ASSIGN',
  EN_ROUTE_PICKUP: 'ASSIGN',
  ARRIVED: 'WAIT',
  ON_TRIP: 'BUSY',
  AWAY: 'AWAY',
} as const satisfies Partial<Record<DriverPresenceState, Exclude<FleetChip, 'ALL'>>>;

export function fleetChipForStatus(status: DriverPresenceState): Exclude<FleetChip, 'ALL'> | null {
  if (!(status in FLEET_CHIP_BY_STATUS)) return null;
  return FLEET_CHIP_BY_STATUS[status as keyof typeof FLEET_CHIP_BY_STATUS];
}

export const driverLocationSchema = z.object({
  lat: z.number().gte(-90).lte(90),
  lng: z.number().gte(-180).lte(180),
  heading: z.number().gte(0).lte(360).optional(),
  speedMps: z.number().gte(0).optional(),
  accuracyM: z.number().gte(0).optional(),
  recordedAt: z.iso.datetime(),
});

export const driverHeartbeatSchema = z.object({
  sentAt: z.iso.datetime(),
});

export const driverSnapshotStopSchema = z.object({
  id: z.uuid(),
  sequence: z.number().int(),
  type: z.enum(['PICKUP', 'DROPOFF', 'STOP']),
  address: z.string(),
  lat: z.number(),
  lng: z.number(),
});

/** REST GET /driver/me/state and the driver:state socket push. */
export const driverStateSchema = z
  .object({
    v: z.number().int().nonnegative(),
    status: driverPresenceStateSchema,
    shift: z
      .object({
        startedAt: z.iso.datetime(),
        vehicle: z
          .object({
            id: z.uuid(),
            unitNumber: z.string().nullable(),
            plate: z.string(),
          })
          .strict(),
      })
      .strict()
      .nullable(),
    booking: z
      .object({
        id: z.uuid(),
        trackingId: z.string(),
        status: z.string(),
        stops: z.array(driverSnapshotStopSchema.strict()),
        passengerFirstName: z.string(),
        scheduledAt: z.iso.datetime().nullable(),
        notes: z.string().nullable(),
        quotedFareCents: z.number().int(),
      })
      .strict()
      .nullable(),
    offer: z
      .object({
        id: z.uuid(),
        expiresAt: z.iso.datetime(),
        serverNow: z.iso.datetime(),
        pickup: z
          .object({
            address: z.string(),
            lat: z.number(),
            lng: z.number(),
          })
          .strict(),
        dropoff: z
          .object({
            address: z.string(),
            lat: z.number(),
            lng: z.number(),
          })
          .strict(),
        distanceToPickupM: z.number().int().nonnegative(),
        tripDistanceM: z.number().int().nonnegative(),
        quotedFareCents: z.number().int(),
        passengerFirstName: z.string(),
        notes: z.string().nullable(),
      })
      .strict()
      .nullable(),
  })
  .strict();

export const sessionReplacedSchema = z.object({
  at: z.iso.datetime(),
}).strict();

export const authExpiringSchema = z
  .object({
    exp: z.number().int(),
  })
  .strict();

export const authTokenSchema = z
  .object({
    token: z.string().min(1),
  })
  .strict();

export const fleetSubscribeSchema = z
  .object({
    branchId: z.uuid(),
  })
  .strict();

export const fleetDriverSchema = z
  .object({
    id: z.uuid(),
    v: z.number().int().nonnegative(),
    status: driverPresenceStateSchema,
    lat: z.number().nullable(),
    lng: z.number().nullable(),
    heading: z.number().nullable(),
    speedMps: z.number().nullable(),
    accuracyM: z.number().nullable(),
    ts: z.number().int().nullable(),
    name: z.string(),
    unit: z.string(),
    vehicleType: z.string(),
    bookingId: z.uuid().nullable(),
    stale: z.boolean(),
  })
  .strict();

export const fleetSnapshotSchema = z
  .object({
    branchId: z.uuid(),
    drivers: z.array(fleetDriverSchema),
  })
  .strict();

export const fleetDriverUpdatedSchema = fleetSnapshotSchema;

export const bookingStatusChangedSchema = z
  .object({
    bookingId: z.uuid(),
    from: z.string().min(1),
    to: z.string().min(1),
    prevDriverId: z.uuid().nullable(),
    driverId: z.uuid().nullable(),
  })
  .strict();

const offerPlaceSchema = z
  .object({
    address: z.string(),
    lat: z.number(),
    lng: z.number(),
  })
  .strict();

/** Driver room. The open app uses this card; the lock-screen push stays generic. */
export const offerNewSchema = z
  .object({
    offerId: z.uuid(),
    bookingId: z.uuid(),
    expiresAt: z.iso.datetime(),
    serverNow: z.iso.datetime(),
    pickup: offerPlaceSchema,
    dropoff: offerPlaceSchema,
    distanceToPickupM: z.number().int().nonnegative(),
    tripDistanceM: z.number().int().nonnegative(),
    quotedFareCents: z.number().int(),
    passengerFirstName: z.string(),
    notes: z.string().nullable(),
  })
  .strict();

export const offerEndedSchema = z
  .object({
    offerId: z.uuid(),
    bookingId: z.uuid(),
  })
  .strict();

export const offerReceivedSchema = z
  .object({
    offerId: z.uuid(),
  })
  .strict();

export const offerCreatedSchema = z
  .object({
    bookingId: z.uuid(),
    offerId: z.uuid(),
    driverId: z.uuid(),
    driverName: z.string(),
    expiresAt: z.iso.datetime(),
  })
  .strict();

export const OFFER_OUTCOMES = ['ACCEPTED', 'DECLINED', 'EXPIRED', 'CANCELLED'] as const;

export const offerResolvedSchema = z
  .object({
    bookingId: z.uuid(),
    offerId: z.uuid(),
    driverId: z.uuid(),
    outcome: z.enum(OFFER_OUTCOMES),
  })
  .strict();

/** Lock-screen data for a driver offer. No address and no passenger name. */
export const offerPushSchema = z
  .object({
    type: z.literal('offer'),
    offerId: z.uuid(),
    expiresAt: z.iso.datetime(),
  })
  .strict();

export const PASSENGER_TRIP_TYPES = [
  'driver_assigned',
  'driver_arrived',
  'no_driver_found',
] as const;

/** Passenger socket. The same facts go out as a push when the app is disconnected. */
export const passengerTripSchema = z
  .object({
    bookingId: z.uuid(),
    type: z.enum(PASSENGER_TRIP_TYPES),
  })
  .strict();

/**
 * Live booking card on /passenger. Driver contact details stay off this payload.
 * ETA is seconds, or null when we do not have a position to estimate from.
 */
export const passengerBookingSchema = z
  .object({
    id: z.uuid(),
    trackingId: z.string().min(1),
    status: z.string().min(1),
    etaSeconds: z.number().int().nonnegative().nullable(),
    scheduledAt: z.iso.datetime().nullable(),
    quotedFareCents: z.number().int(),
    quotedTaxCents: z.number().int(),
    notes: z.string().nullable(),
    passengerName: z.string(),
    vehicleType: z
      .object({
        id: z.uuid(),
        name: z.string(),
      })
      .strict(),
    stops: z.array(
      z
        .object({
          sequence: z.number().int(),
          type: z.enum(['PICKUP', 'DROPOFF', 'STOP']),
          address: z.string(),
          lat: z.number(),
          lng: z.number(),
        })
        .strict(),
    ),
    driver: z
      .object({
        firstName: z.string(),
        rating: z.number(),
        vehicle: z
          .object({
            make: z.string(),
            model: z.string(),
            colour: z.string().nullable(),
            plate: z.string(),
            unitNumber: z.string().nullable(),
          })
          .strict()
          .nullable(),
      })
      .strict()
      .nullable(),
  })
  .strict();

/**
 * Server push of the assigned driver's latest point on /passenger.
 * The event name matches driver telemetry. This payload is not a subscribe request,
 * and it is only sent to the passenger on that booking.
 */
export const passengerDriverLocationSchema = z
  .object({
    bookingId: z.uuid(),
    lat: z.number(),
    lng: z.number(),
    heading: z.number().nullable(),
    ts: z.number().int().nullable(),
  })
  .strict();

export const bookingCreatedSchema = z
  .object({
    id: z.uuid(),
    branchId: z.uuid(),
    trackingId: z.string(),
    status: z.string().min(1),
    passengerName: z.string(),
    scheduledAt: z.iso.datetime().nullable(),
    quotedFareCents: z.number().int(),
    vehicleType: z
      .object({
        id: z.uuid(),
        name: z.string(),
      })
      .strict(),
    pickupAddress: z.string(),
  })
  .strict();

export const SOCKET_EVENTS = {
  driverLocation: 'driver:location',
  driverHeartbeat: 'driver:heartbeat',
  driverState: 'driver:state',
  sessionReplaced: 'session:replaced',
  authExpiring: 'auth:expiring',
  authToken: 'auth:token',
  fleetSubscribe: 'fleet:subscribe',
  fleetSnapshot: 'fleet:snapshot',
  fleetDriverUpdated: 'fleet:driver_updated',
  bookingStatusChanged: 'booking:status_changed',
  bookingCreated: 'booking:created',
  offerNew: 'offer:new',
  offerCancelled: 'offer:cancelled',
  offerExpired: 'offer:expired',
  offerReceived: 'offer:received',
  offerCreated: 'offer:created',
  offerResolved: 'offer:resolved',
  tripUpdate: 'trip:update',
  bookingUpdated: 'booking:updated',
} as const;

export type SocketEventName = (typeof SOCKET_EVENTS)[keyof typeof SOCKET_EVENTS];
export type DriverPresenceState = z.infer<typeof driverPresenceStateSchema>;
export type DriverLocation = z.infer<typeof driverLocationSchema>;
export type DriverHeartbeat = z.infer<typeof driverHeartbeatSchema>;
export type DriverStateSnapshot = z.infer<typeof driverStateSchema>;
export type SessionReplaced = z.infer<typeof sessionReplacedSchema>;
export type AuthExpiring = z.infer<typeof authExpiringSchema>;
export type AuthToken = z.infer<typeof authTokenSchema>;
export type FleetSubscribe = z.infer<typeof fleetSubscribeSchema>;
export type FleetDriver = z.infer<typeof fleetDriverSchema>;
export type FleetSnapshot = z.infer<typeof fleetSnapshotSchema>;
export type BookingStatusChanged = z.infer<typeof bookingStatusChangedSchema>;
export type BookingCreated = z.infer<typeof bookingCreatedSchema>;
export type OfferNew = z.infer<typeof offerNewSchema>;
export type OfferEnded = z.infer<typeof offerEndedSchema>;
export type OfferReceived = z.infer<typeof offerReceivedSchema>;
export type OfferCreated = z.infer<typeof offerCreatedSchema>;
export type OfferResolved = z.infer<typeof offerResolvedSchema>;
export type OfferOutcome = (typeof OFFER_OUTCOMES)[number];
export type OfferPush = z.infer<typeof offerPushSchema>;
export type PassengerTrip = z.infer<typeof passengerTripSchema>;
export type PassengerTripType = (typeof PASSENGER_TRIP_TYPES)[number];
export type PassengerBooking = z.infer<typeof passengerBookingSchema>;
export type PassengerDriverLocation = z.infer<typeof passengerDriverLocationSchema>;

/** On a trip or heading to one. Idle drivers (available or away) ping more slowly. */
export const LOCATION_PING_ACTIVE_MS = 5_000;
export const LOCATION_PING_IDLE_MS = 15_000;

export function locationPingIntervalMs(state: DriverPresenceState) {
  if (state === 'OFFLINE') return null;
  if (state === 'AVAILABLE' || state === 'AWAY') return LOCATION_PING_IDLE_MS;
  return LOCATION_PING_ACTIVE_MS;
}

export const socketPayloads = {
  [SOCKET_EVENTS.driverLocation]: driverLocationSchema,
  [SOCKET_EVENTS.driverHeartbeat]: driverHeartbeatSchema,
  [SOCKET_EVENTS.driverState]: driverStateSchema,
  [SOCKET_EVENTS.sessionReplaced]: sessionReplacedSchema,
  [SOCKET_EVENTS.authExpiring]: authExpiringSchema,
  [SOCKET_EVENTS.authToken]: authTokenSchema,
  [SOCKET_EVENTS.fleetSubscribe]: fleetSubscribeSchema,
  [SOCKET_EVENTS.fleetSnapshot]: fleetSnapshotSchema,
  [SOCKET_EVENTS.fleetDriverUpdated]: fleetDriverUpdatedSchema,
  [SOCKET_EVENTS.bookingStatusChanged]: bookingStatusChangedSchema,
  [SOCKET_EVENTS.bookingCreated]: bookingCreatedSchema,
  [SOCKET_EVENTS.offerNew]: offerNewSchema,
  [SOCKET_EVENTS.offerCancelled]: offerEndedSchema,
  [SOCKET_EVENTS.offerExpired]: offerEndedSchema,
  [SOCKET_EVENTS.offerReceived]: offerReceivedSchema,
  [SOCKET_EVENTS.offerCreated]: offerCreatedSchema,
  [SOCKET_EVENTS.offerResolved]: offerResolvedSchema,
  [SOCKET_EVENTS.tripUpdate]: passengerTripSchema,
  [SOCKET_EVENTS.bookingUpdated]: passengerBookingSchema,
} as const;
