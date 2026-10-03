import { describe, expect, it } from 'vitest'
import {
  canAssign,
  canCancel,
  canUnassign,
  formatDistance,
  metersBetween,
  secondsLeft,
} from '@/features/bookings/booking-detail'

describe('booking detail helpers', () => {
  it('allows assign on searching / no-driver statuses for dispatch roles', () => {
    expect(canAssign('dispatcher', 'SEARCHING_DRIVER')).toBe(true)
    expect(canAssign('dispatcher', 'NO_DRIVER_FOUND')).toBe(true)
    expect(canAssign('viewer', 'SEARCHING_DRIVER')).toBe(false)
    expect(canAssign('dispatcher', 'TRIP_STARTED')).toBe(false)
  })

  it('allows unassign while a driver is assigned or arriving', () => {
    expect(canUnassign('dispatcher', 'DRIVER_ASSIGNED')).toBe(true)
    expect(canUnassign('dispatcher', 'SEARCHING_DRIVER')).toBe(false)
  })

  it('blocks cancel once the trip has started', () => {
    expect(canCancel('SEARCHING_DRIVER')).toBe(true)
    expect(canCancel('TRIP_STARTED')).toBe(false)
  })

  it('formats distance and offer countdown', () => {
    expect(formatDistance(800)).toBe('800 m')
    expect(formatDistance(1800)).toBe('1.8 km')
    expect(secondsLeft(new Date(Date.now() + 12_500).toISOString(), Date.now())).toBe(13)
  })

  it('measures map distance for assign prompts', () => {
    const meters = metersBetween(
      { lat: 49.6935, lng: -112.8418 },
      { lat: 49.7, lng: -112.84 },
    )
    expect(meters).toBeGreaterThan(500)
    expect(meters).toBeLessThan(2000)
  })
})
