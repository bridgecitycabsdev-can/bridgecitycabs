import { beforeEach, describe, expect, it } from 'vitest'
import { FLEET_CHIP_BY_STATUS, FLEET_CHIPS, type FleetChip, type FleetDriver } from '@bridgecabs/api-client'
import { formatLastSeen } from '@/features/fleet/driver'
import { chipCounts, chipForStatus, driverMarkerView, useFleet } from '@/features/fleet/store'

const socketDriver = {
  id: '11111111-1111-4111-8111-111111111111',
  v: 2,
  status: 'AVAILABLE',
  lat: 49.69,
  lng: -112.84,
  heading: null,
  speedMps: null,
  accuracyM: null,
  ts: 1_700_000_000_000,
  name: 'Priya Nair',
  unit: '11',
  vehicleType: 'SUV',
  bookingId: null,
  stale: false,
} satisfies FleetDriver

const otherDriver = {
  ...socketDriver,
  id: '22222222-2222-4222-8222-222222222222',
  name: 'Jules Hart',
  unit: '12',
  lat: 49.7,
} satisfies FleetDriver

describe('fleet store', () => {
  beforeEach(() => {
    useFleet.setState({ drivers: {}, conn: 'offline', chip: 'ALL' })
    localStorage.clear()
  })

  it('keeps drivers in a memory record keyed by id', () => {
    useFleet.getState().replace([socketDriver])
    expect(useFleet.getState().drivers[socketDriver.id]).toEqual(socketDriver)
    expect(useFleet.getState().drivers[socketDriver.id]?.unit).toBe('11')
    expect(localStorage.length).toBe(0)
  })

  it('merges one driver without replacing the others', () => {
    useFleet.getState().replace([socketDriver, otherDriver])
    const untouched = useFleet.getState().drivers[otherDriver.id]
    useFleet.getState().merge([{ id: socketDriver.id, lat: 50 }])
    expect(useFleet.getState().drivers[socketDriver.id]?.lat).toBe(50)
    expect(useFleet.getState().drivers[socketDriver.id]?.name).toBe('Priya Nair')
    expect(useFleet.getState().drivers[otherDriver.id]).toBe(untouched)
    expect(localStorage.length).toBe(0)
  })

  it('replace drops drivers who left', () => {
    useFleet.getState().replace([socketDriver, otherDriver])
    useFleet.getState().replace([otherDriver])
    expect(useFleet.getState().drivers[socketDriver.id]).toBeUndefined()
    expect(useFleet.getState().drivers[otherDriver.id]).toEqual(otherDriver)
  })

  it('counts every status on the chip from the mapping', () => {
    const mapped = Object.entries(FLEET_CHIP_BY_STATUS) as [
      FleetDriver['status'],
      Exclude<FleetChip, 'ALL'>,
    ][]
    const drivers = mapped.map(([status], index) => ({
      ...socketDriver,
      id: `00000000-0000-4000-8000-${String(index).padStart(12, '0')}`,
      status,
    }))
    const offline = {
      ...socketDriver,
      id: '00000000-0000-4000-8000-000000000099',
      status: 'OFFLINE' as const,
    }
    const counts = chipCounts([...drivers, offline])
    const expected = Object.fromEntries(FLEET_CHIPS.map((chip) => [chip, 0])) as Record<FleetChip, number>
    for (const [status, chip] of mapped) {
      expect(chipForStatus(status)).toBe(chip)
      expected.ALL += 1
      expected[chip] += 1
    }
    expect(chipForStatus('OFFLINE')).toBeNull()
    expect(counts).toEqual(expected)
    expect(counts).toEqual({ ALL: 7, FREE: 1, ASSIGN: 3, WAIT: 1, BUSY: 1, AWAY: 1 })
  })

  it('colours a marker by chip and fades a stale unit', () => {
    expect(driverMarkerView(socketDriver)).toEqual({
      unit: '11',
      color: 'var(--color-success)',
      faded: false,
    })
    expect(driverMarkerView({ ...socketDriver, status: 'ON_TRIP', stale: true })).toEqual({
      unit: '11',
      color: 'var(--color-brand)',
      faded: true,
    })
  })

  it('formats last seen as a clock time', () => {
    const ts = Date.UTC(2024, 5, 2, 15, 4)
    expect(formatLastSeen(null)).toBe('—')
    expect(formatLastSeen(ts)).toBe(
      new Intl.DateTimeFormat(undefined, { hour: 'numeric', minute: '2-digit' }).format(new Date(ts)),
    )
  })
})