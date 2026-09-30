import { z } from 'zod';

/**
 * Socket contract shared by the API and the React apps.
 * Flutter clients mirror these JSON shapes.
 *
 * Telemetry (client → server): driver:location, driver:heartbeat.
 * Pushes (server → client): driver:state, session:replaced, booking:status_changed.
 * driver:state is a full snapshot. Clients keep the highest version.
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
} as const;
