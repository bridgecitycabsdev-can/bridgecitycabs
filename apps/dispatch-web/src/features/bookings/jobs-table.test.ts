import { DateTime } from 'luxon'
import { describe, expect, it } from 'vitest'
import {
  bookedLabel,
  branchDayRange,
  jobRowSchema,
  stopAddress,
  todayInBranch,
} from '@/features/bookings/jobs-table'

describe('jobs table helpers', () => {
  it('picks pickup and drop-off addresses as plain text', () => {
    const stops = [
      { sequence: 1, type: 'PICKUP', address: '1 Main St' },
      { sequence: 2, type: 'DROPOFF', address: '9 Oak Ave' },
    ]
    expect(stopAddress(stops, 'PICKUP')).toBe('1 Main St')
    expect(stopAddress(stops, 'DROPOFF')).toBe('9 Oak Ave')
  })

  it('formats booked time in the branch zone', () => {
    const row = jobRowSchema.parse({
      id: '1',
      trackingId: 'LB-1',
      status: 'NO_DRIVER_FOUND',
      source: 'DISPATCH',
      passengerName: 'Sam',
      passengerPhone: '+14035550100',
      createdAt: '2026-10-03T18:00:00.000Z',
      scheduledAt: null,
      stops: [],
    })
    expect(bookedLabel(row, 'America/Edmonton')).toMatch(/03 Oct/)
  })

  it('converts a branch calendar day to UTC instants', () => {
    const range = branchDayRange('2026-10-03', 'America/Edmonton')
    expect(range).not.toBeNull()
    const from = DateTime.fromISO(range!.from, { zone: 'utc' })
    const to = DateTime.fromISO(range!.to, { zone: 'utc' })
    expect(from.setZone('America/Edmonton').toFormat('yyyy-LL-dd HH:mm')).toBe(
      '2026-10-03 00:00',
    )
    expect(to.setZone('America/Edmonton').toFormat('yyyy-LL-dd')).toBe('2026-10-03')
    expect(to.setZone('America/Edmonton').hour).toBe(23)
  })

  it('defaults closed-jobs range to today in branch time', () => {
    const today = todayInBranch('America/Edmonton')
    expect(today).toMatch(/^\d{4}-\d{2}-\d{2}$/)
    expect(today).toBe(DateTime.now().setZone('America/Edmonton').toFormat('yyyy-LL-dd'))
  })
})
