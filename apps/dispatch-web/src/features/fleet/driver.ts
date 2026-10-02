import type { FleetDriver } from '@bridgecabs/api-client'
import { z } from 'zod'

export const dispatchDriverSchema = z.object({
  id: z.string(),
  name: z.string(),
  unitNumber: z.string(),
  vehicleType: z.string(),
  status: z.string(),
  lat: z.number().nullable(),
  lng: z.number().nullable(),
  ts: z.number().nullable(),
  stale: z.boolean(),
})

export type DispatchDriver = z.infer<typeof dispatchDriverSchema>

export const fleetDriversSchema = z.object({
  branchId: z.string(),
  drivers: z.array(dispatchDriverSchema),
})

const PRESENCE = new Set<FleetDriver['status']>([
  'OFFLINE',
  'AVAILABLE',
  'OFFERED',
  'ASSIGNED',
  'EN_ROUTE_PICKUP',
  'ARRIVED',
  'ON_TRIP',
  'AWAY',
])

export function toFleetDriver(driver: DispatchDriver): FleetDriver | null {
  if (!PRESENCE.has(driver.status as FleetDriver['status'])) return null
  return {
    id: driver.id,
    v: 0,
    status: driver.status as FleetDriver['status'],
    lat: driver.lat,
    lng: driver.lng,
    heading: null,
    speedMps: null,
    accuracyM: null,
    ts: driver.ts,
    name: driver.name,
    unit: driver.unitNumber,
    vehicleType: driver.vehicleType,
    bookingId: null,
    stale: driver.stale,
  }
}

export function formatLastSeen(ts: number | null) {
  if (ts == null) return '—'
  const ms = ts < 1_000_000_000_000 ? ts * 1000 : ts
  const date = new Date(ms)
  if (Number.isNaN(date.getTime())) return '—'
  return new Intl.DateTimeFormat(undefined, {
    hour: 'numeric',
    minute: '2-digit',
  }).format(date)
}
