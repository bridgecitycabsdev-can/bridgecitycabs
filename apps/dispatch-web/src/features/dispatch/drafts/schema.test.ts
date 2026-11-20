import { DateTime } from 'luxon'
import { describe, expect, it } from 'vitest'
import {
  bookingPayload,
  blankForm,
  branchInstant,
  canonicalJson,
  dollarsToCents,
  metersApart,
  phoneToE164,
  sha256,
  validateJob,
  type DispatchConfig,
  type FareQuote,
} from './schema'

const config: DispatchConfig = {
  scheduleMinLeadMinutes: 15,
  scheduleMaxDays: 30,
  offerTimeoutSeconds: 15,
  fixedFareMaxCents: 50_000,
  paymentPendingAlertCount: 0,
  timezone: 'America/Edmonton',
  autoDispatchDefault: true,
  branchCenter: { lat: 49.6935, lng: -112.8418 },
}

const place = (lat: number, lng: number, id: string) => ({
  address: id,
  placeId: id,
  lat,
  lng,
})

describe('job form helpers', () => {
  it('parses dollars to cents without floating-point multiply', () => {
    expect(dollarsToCents('25')).toBe(2500)
    expect(dollarsToCents('25.5')).toBe(2550)
    expect(dollarsToCents('25.50')).toBe(2550)
    expect(dollarsToCents('12.10')).toBe(1210)
    expect(dollarsToCents('0.1')).toBe(10)
    expect(Number.isNaN(dollarsToCents('12.345'))).toBe(true)
  })

  it('requires a selected place and keeps pickup far from drop-off', () => {
    const form = {
      ...blankForm(),
      pickup: place(49.6935, -112.8418, 'a'),
      dropoff: place(49.6935, -112.8418, 'b'),
      vehicleTypeId: 'suv',
      phone: '403-555-0100',
      name: 'Amira',
    }
    expect(validateJob(form, config).errors.dropoff).toMatch(/50 m/)
    expect(metersApart(place(0, 0, 'a'), place(0.001, 0, 'b'))).toBeGreaterThan(50)
  })

  it('rejects an invalid phone, an out-of-bounds schedule, and a fare above the cap', () => {
    const base = {
      ...blankForm(),
      pickup: place(49.69, -112.84, 'p'),
      dropoff: place(49.63, -112.8, 'd'),
      vehicleTypeId: 'suv',
      name: 'Amira',
      phone: 'not-a-phone',
      when: 'LATER' as const,
      scheduledLocal: '2026-01-15T10:30',
      fixedFare: '600.00',
    }
    const now = DateTime.fromISO('2026-01-15T17:00:00.000Z', { zone: 'utc' }) as DateTime<true>
    expect(validateJob(base, config, now).errors.phone).toMatch(/valid phone/i)
    expect(
      validateJob({ ...base, phone: '403-555-0100', scheduledLocal: '2026-01-15T09:50' }, config, now)
        .errors.scheduledAt,
    ).toMatch(/15 minutes/)
    expect(
      validateJob(
        { ...base, phone: '403-555-0100', scheduledLocal: '2026-03-20T10:30' },
        config,
        now,
      ).errors.scheduledAt,
    ).toMatch(/30 days/)
    expect(validateJob({ ...base, phone: '403-555-0100' }, config, now).errors.fixedFare).toMatch(
      /maximum/,
    )
  })

  it('flags a Later booking in the spring-forward gap', () => {
    const form = {
      ...blankForm(),
      pickup: place(49.69, -112.84, 'p'),
      dropoff: place(49.63, -112.8, 'd'),
      vehicleTypeId: 'suv',
      phone: '403-555-0100',
      name: 'Amira',
      when: 'LATER' as const,
      scheduledLocal: '2026-03-08T02:30',
    }
    const now = DateTime.fromISO('2026-03-07T12:00:00.000Z', { zone: 'utc' }) as DateTime<true>
    expect(branchInstant('2026-03-08T02:30', 'America/Edmonton')).toBeNull()
    expect(validateJob(form, config, now).errors.scheduledAt).toMatch(/does not exist/i)
  })

  it('normalises Canadian phones and schedules in branch time', () => {
    expect(phoneToE164('403-555-0100')).toBe('+14035550100')
    const winter = branchInstant('2026-01-15T10:30', 'America/Edmonton')
    expect(winter).toBe('2026-01-15T17:30:00.000Z')
  })

  it('keeps an idempotency hash stable until the payload changes', async () => {
    const form = {
      ...blankForm(),
      pickup: place(49.69, -112.84, 'p'),
      dropoff: place(49.63, -112.8, 'd'),
      vehicleTypeId: 'suv',
      phone: '+14035550100',
      name: 'Amira',
    }
    const quote: FareQuote = {
      distanceM: 8100,
      durationS: 1020,
      source: 'ROUTES',
      zone: 'INSIDE_TOWN',
      priceChanged: false,
      options: [
        {
          vehicleTypeId: 'suv',
          name: 'SUV',
          subtotalCents: 2500,
          taxCents: 125,
          totalCents: 2625,
          quoteToken: 'token',
          expiresAt: '2026-10-02T12:00:00.000Z',
        },
      ],
    }
    const first = bookingPayload(form, quote, config, 'branch-1')
    const second = bookingPayload(form, quote, config, 'branch-1')
    expect('payload' in first && 'payload' in second).toBe(true)
    if (!('payload' in first) || !('payload' in second)) return
    expect(await sha256(canonicalJson(first.payload))).toBe(
      await sha256(canonicalJson(second.payload)),
    )
    const changed = bookingPayload({ ...form, notes: 'Gate' }, quote, config, 'branch-1')
    expect('payload' in changed).toBe(true)
    if (!('payload' in changed)) return
    expect(await sha256(canonicalJson(changed.payload))).not.toBe(
      await sha256(canonicalJson(first.payload)),
    )
  })

  it('builds a booking payload with a stable hash body', () => {
    const form = {
      ...blankForm(),
      pickup: place(49.69, -112.84, 'p'),
      dropoff: place(49.63, -112.8, 'd'),
      vehicleTypeId: 'suv',
      phone: '+14035550100',
      name: 'Amira',
      assignMode: 'MANUAL' as const,
    }
    const quote: FareQuote = {
      distanceM: 8100,
      durationS: 1020,
      source: 'ROUTES',
      zone: 'INSIDE_TOWN',
      priceChanged: false,
      options: [
        {
          vehicleTypeId: 'suv',
          name: 'SUV',
          subtotalCents: 2500,
          taxCents: 125,
          totalCents: 2625,
          quoteToken: 'token',
          expiresAt: '2026-10-02T12:00:00.000Z',
        },
      ],
    }
    const built = bookingPayload(form, quote, config, 'branch-1')
    expect('payload' in built).toBe(true)
    if (!('payload' in built)) return
    expect(built.payload.assignMode).toBe('MANUAL')
    expect(built.payload.paymentMethod).toBe('CASH')
    expect(canonicalJson({ b: 1, a: 2 })).toBe('{"a":2,"b":1}')
  })
})
