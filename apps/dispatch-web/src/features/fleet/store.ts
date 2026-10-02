import { create } from 'zustand'
import {
  FLEET_CHIP_BY_STATUS,
  FLEET_CHIPS,
  type FleetChip,
  type FleetDriver,
} from '@bridgecabs/api-client'

export type FleetConn = 'live' | 'reconnecting' | 'offline'

export const FLEET_CONN_LABEL: Record<FleetConn, string> = {
  live: 'Live',
  reconnecting: 'Reconnecting',
  offline: 'Offline',
}

type FleetState = {
  drivers: Record<string, FleetDriver>
  conn: FleetConn
  chip: FleetChip
  setConn: (conn: FleetConn) => void
  setChip: (chip: FleetChip) => void
  replace: (list: FleetDriver[]) => void
  merge: (batch: (Partial<FleetDriver> & { id: string })[]) => void
}

/** Driver positions stay in this memory store. Nothing here is written to localStorage. */
export const useFleet = create<FleetState>((set) => ({
  drivers: {},
  conn: 'offline',
  chip: 'ALL',
  setConn: (conn) => set({ conn }),
  setChip: (chip) => set({ chip }),
  replace: (list) => set({ drivers: Object.fromEntries(list.map((driver) => [driver.id, driver])) }),
  merge: (batch) =>
    set((state) => {
      const next = { ...state.drivers }
      for (const driver of batch) {
        const previous = next[driver.id]
        next[driver.id] = { ...previous, ...driver } as FleetDriver
      }
      return { drivers: next }
    }),
}))

let stopSocket = () => {}

export function registerFleetStop(stop: () => void) {
  stopSocket = stop
}

export function stopFleet() {
  stopSocket()
  useFleet.setState({ conn: 'offline' })
  useFleet.getState().replace([])
}

export const CHIP_COLOR: Record<Exclude<FleetChip, 'ALL'>, string> = {
  BUSY: 'var(--color-brand)',
  FREE: 'var(--color-success)',
  ASSIGN: '#1D4E89',
  WAIT: '#B86E00',
  AWAY: '#6B6560',
}

export function chipForStatus(status: string) {
  if (!(status in FLEET_CHIP_BY_STATUS)) return null
  return FLEET_CHIP_BY_STATUS[status as keyof typeof FLEET_CHIP_BY_STATUS]
}

export function driversForChip(drivers: readonly FleetDriver[], chip: FleetChip) {
  return drivers.filter((driver) => {
    const mapped = chipForStatus(driver.status)
    if (!mapped) return false
    return chip === 'ALL' || mapped === chip
  })
}

export function chipCounts(drivers: readonly FleetDriver[]) {
  const counts = Object.fromEntries(FLEET_CHIPS.map((chip) => [chip, 0])) as Record<FleetChip, number>
  for (const driver of drivers) {
    const chip = chipForStatus(driver.status)
    if (!chip) continue
    counts.ALL += 1
    counts[chip] += 1
  }
  return counts
}

export function visibleDriverIds(drivers: Record<string, FleetDriver>, chip: FleetChip) {
  return Object.values(drivers)
    .filter((driver) => {
      if (driver.lat == null || driver.lng == null) return false
      const mapped = chipForStatus(driver.status)
      if (!mapped) return false
      return chip === 'ALL' || mapped === chip
    })
    .map((driver) => driver.id)
    .sort()
}

export function driverMarkerView(driver: FleetDriver) {
  const chip = chipForStatus(driver.status)
  return {
    unit: driver.unit,
    color: chip ? CHIP_COLOR[chip] : 'var(--color-text)',
    faded: driver.stale,
  }
}
