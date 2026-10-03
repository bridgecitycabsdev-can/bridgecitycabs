import { DateTime } from 'luxon'
import { z } from 'zod'

export const bookingStopSchema = z.object({
  sequence: z.number(),
  type: z.string(),
  address: z.string(),
  lat: z.number(),
  lng: z.number(),
  placeId: z.string().nullable().optional(),
})

export const bookingHistorySchema = z.object({
  id: z.string(),
  fromStatus: z.string().nullable(),
  toStatus: z.string(),
  actorType: z.string(),
  reason: z.string().nullable().optional(),
  createdAt: z.union([z.string(), z.date()]).transform((value) =>
    typeof value === 'string' ? value : value.toISOString(),
  ),
})

export const bookingDetailSchema = z.object({
  id: z.string(),
  trackingId: z.string(),
  version: z.number(),
  status: z.string(),
  source: z.string(),
  assignMode: z.enum(['AUTO', 'MANUAL']),
  passengerName: z.string(),
  passengerPhone: z.string(),
  scheduledAt: z.string().nullable(),
  createdAt: z.string(),
  distanceMeters: z.number(),
  durationSeconds: z.number(),
  quotedFareCents: z.number(),
  quotedTaxCents: z.number(),
  fixedFareCents: z.number().nullable(),
  finalFareCents: z.number().nullable().optional(),
  paymentMethod: z.string(),
  notes: z.string().nullable(),
  vanOnly: z.boolean(),
  ladyDriverOnly: z.boolean(),
  zone: z.enum(['INSIDE_TOWN', 'OUT_OF_TOWN']),
  vehicleTypeId: z.string(),
  vehicleType: z.object({ id: z.string(), name: z.string() }).nullish(),
  driver: z
    .object({
      id: z.string(),
      firstName: z.string(),
      lastName: z.string(),
    })
    .nullish(),
  vehicle: z
    .object({
      id: z.string(),
      plateNumber: z.string(),
      unitNumber: z.string().nullable(),
    })
    .nullish(),
  stops: z.array(bookingStopSchema),
  history: z.array(bookingHistorySchema).default([]),
  createdBy: z.string(),
  assignedBy: z.string().nullable(),
  driverName: z.string().nullable(),
  driverUnit: z.string().nullable(),
  openOffer: z
    .object({
      id: z.string(),
      driverId: z.string(),
      vehicleId: z.string(),
      expiresAt: z.union([z.string(), z.date()]).transform((value) =>
        typeof value === 'string' ? value : value.toISOString(),
      ),
      distanceToPickupM: z.number(),
    })
    .nullable(),
  editableFields: z.array(z.string()),
})

export type BookingDetail = z.infer<typeof bookingDetailSchema>

export const candidateSchema = z.object({
  driverId: z.string(),
  name: z.string(),
  unit: z.string(),
  vehicleId: z.string(),
  distanceM: z.number(),
  eligible: z.boolean(),
  reasons: z.array(z.string()),
})

export type Candidate = z.infer<typeof candidateSchema>

export const CANCEL_REASONS = [
  { id: 'PASSENGER_REQUEST', label: 'Passenger request' },
  { id: 'DRIVER_NO_SHOW', label: 'Driver no-show' },
  { id: 'PASSENGER_NO_SHOW', label: 'Passenger no-show' },
  { id: 'DUPLICATE', label: 'Duplicate' },
  { id: 'OPERATIONAL', label: 'Operational' },
  { id: 'OTHER', label: 'Other' },
] as const

export const BOOKING_STATUSES = [
  'SCHEDULED',
  'CREATED',
  'SEARCHING_DRIVER',
  'MATCHED',
  'DRIVER_ASSIGNED',
  'DRIVER_ARRIVING',
  'DRIVER_ARRIVED',
  'TRIP_STARTED',
  'TRIP_COMPLETED',
  'NO_DRIVER_FOUND',
  'CANCELLED',
  'CLOSED',
] as const

const money = new Intl.NumberFormat('en-CA', { style: 'currency', currency: 'CAD' })

export function formatMoney(cents: number | null | undefined) {
  if (cents == null) return '—'
  return money.format(cents / 100)
}

export function formatBranchTime(iso: string | null | undefined, zone: string) {
  if (!iso) return '—'
  const when = DateTime.fromISO(iso, { zone: 'utc' }).setZone(zone)
  if (!when.isValid) return '—'
  return when.toFormat('dd LLL yyyy, h:mm a')
}

export function formatDuration(seconds: number) {
  const minutes = Math.round(seconds / 60)
  if (minutes < 60) return `${minutes} min`
  const hours = Math.floor(minutes / 60)
  return `${hours} h ${minutes % 60} min`
}

export function formatDistance(meters: number) {
  if (meters < 1000) return `${meters} m`
  return `${(meters / 1000).toFixed(1)} km`
}

export function pickupStop(stops: BookingDetail['stops']) {
  return (
    stops.find((stop) => stop.type === 'PICKUP') ??
    [...stops].sort((left, right) => left.sequence - right.sequence)[0] ??
    null
  )
}

export function dropoffStop(stops: BookingDetail['stops']) {
  return (
    stops.find((stop) => stop.type === 'DROPOFF') ??
    [...stops].sort((left, right) => left.sequence - right.sequence).at(-1) ??
    null
  )
}

export function metersBetween(
  from: { lat: number; lng: number },
  to: { lat: number; lng: number },
) {
  const radius = 6_371_000
  const lat1 = (from.lat * Math.PI) / 180
  const lat2 = (to.lat * Math.PI) / 180
  const dLat = ((to.lat - from.lat) * Math.PI) / 180
  const dLng = ((to.lng - from.lng) * Math.PI) / 180
  const chord =
    Math.sin(dLat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2
  return 2 * radius * Math.asin(Math.min(1, Math.sqrt(chord)))
}

export function reasonLabel(code: string) {
  return (
    {
      VEHICLE_TYPE_MISMATCH: 'Wrong vehicle type',
      NOT_VAN: 'Not a van',
      NOT_LADY_ELIGIBLE: 'Not lady-eligible',
      STALE_LOCATION: 'Stale location',
    }[code] ?? code
  )
}

export function canAssign(role: string | undefined, status: string) {
  if (!role || !['dispatcher', 'branch_admin', 'super_admin'].includes(role)) return false
  return ['SEARCHING_DRIVER', 'NO_DRIVER_FOUND', 'MATCHED', 'CREATED'].includes(status)
}

export function canUnassign(role: string | undefined, status: string) {
  if (!role || !['dispatcher', 'branch_admin', 'super_admin'].includes(role)) return false
  return ['DRIVER_ASSIGNED', 'DRIVER_ARRIVING', 'DRIVER_ARRIVED', 'MATCHED'].includes(status)
}

export function canSwitchMode(role: string | undefined, status: string) {
  if (!role || !['dispatcher', 'branch_admin', 'super_admin'].includes(role)) return false
  return ![
    'TRIP_STARTED',
    'TRIP_COMPLETED',
    'PAYMENT_PENDING',
    'PAYMENT_COMPLETED',
    'CLOSED',
    'CANCELLED',
  ].includes(status)
}

export function canCancel(status: string) {
  return ![
    'TRIP_STARTED',
    'TRIP_COMPLETED',
    'PAYMENT_PENDING',
    'PAYMENT_COMPLETED',
    'CLOSED',
    'CANCELLED',
  ].includes(status)
}

export function secondsLeft(expiresAt: string, now = Date.now()) {
  return Math.max(0, Math.ceil((new Date(expiresAt).getTime() - now) / 1000))
}
