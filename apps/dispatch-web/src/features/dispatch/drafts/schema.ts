import { parsePhoneNumberFromString } from 'libphonenumber-js'
import { DateTime } from 'luxon'
import { z } from 'zod'

export const MAX_STOPS_BETWEEN = 3
export const MIN_STOP_METERS = 50

export type PlaceValue = {
  address: string
  placeId: string
  lat: number
  lng: number
}

export type AssignMode = 'AUTO' | 'MANUAL'
export type FareZone = 'INSIDE_TOWN' | 'OUT_OF_TOWN'

export type JobForm = {
  pickup: PlaceValue | null
  vias: PlaceValue[]
  dropoff: PlaceValue | null
  vehicleTypeId: string
  vanOnly: boolean
  ladyOnly: boolean
  when: 'NOW' | 'LATER'
  scheduledLocal: string
  phone: string
  name: string
  notes: string
  fixedFare: string
  assignMode: AssignMode | null
  zone: FareZone | null
}

export type DispatchConfig = {
  scheduleMinLeadMinutes: number
  scheduleMaxDays: number
  offerTimeoutSeconds: number
  fixedFareMaxCents: number
  timezone: string
  autoDispatchDefault: boolean
  branchCenter: { lat: number; lng: number } | null
}

export const dispatchConfigSchema = z.object({
  scheduleMinLeadMinutes: z.number(),
  scheduleMaxDays: z.number(),
  offerTimeoutSeconds: z.number(),
  fixedFareMaxCents: z.number(),
  timezone: z.string().min(1),
  autoDispatchDefault: z.boolean(),
  branchCenter: z.object({ lat: z.number(), lng: z.number() }).nullable(),
})

export const quoteSchema = z.object({
  distanceM: z.number(),
  durationS: z.number(),
  source: z.enum(['ROUTES', 'ESTIMATE']),
  zone: z.enum(['INSIDE_TOWN', 'OUT_OF_TOWN']),
  options: z.array(
    z.object({
      vehicleTypeId: z.string(),
      name: z.string(),
      subtotalCents: z.number(),
      taxCents: z.number(),
      totalCents: z.number(),
      quoteToken: z.string(),
      expiresAt: z.string(),
      etaMinutes: z.number().nullable().optional(),
    }),
  ),
})

export type FareQuote = z.infer<typeof quoteSchema> & { priceChanged: boolean }

export function blankForm(): JobForm {
  return {
    pickup: null,
    vias: [],
    dropoff: null,
    vehicleTypeId: '',
    vanOnly: false,
    ladyOnly: false,
    when: 'NOW',
    scheduledLocal: '',
    phone: '',
    name: '',
    notes: '',
    fixedFare: '',
    assignMode: null,
    zone: null,
  }
}

/** Integer cents from a dollar string. No binary fraction from a float multiply. */
export function dollarsToCents(value: string): number | null {
  const trimmed = value.trim()
  if (!trimmed) return null
  const match = /^(\d+)(?:\.(\d{1,2}))?$/.exec(trimmed)
  if (!match?.[1]) return Number.NaN
  const dollars = Number(match[1])
  const cents = Number((match[2] ?? '').padEnd(2, '0'))
  return dollars * 100 + cents
}

export function metersApart(from: { lat: number; lng: number }, to: { lat: number; lng: number }) {
  const radius = 6_371_000
  const lat1 = (from.lat * Math.PI) / 180
  const lat2 = (to.lat * Math.PI) / 180
  const dLat = ((to.lat - from.lat) * Math.PI) / 180
  const dLng = ((to.lng - from.lng) * Math.PI) / 180
  const chord =
    Math.sin(dLat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2
  return 2 * radius * Math.asin(Math.min(1, Math.sqrt(chord)))
}

export function branchInstant(local: string, zone: string) {
  const parsed = DateTime.fromISO(local, { zone })
  if (!parsed.isValid || !parsed.toUTC().toISO()) return null
  // Luxon shifts times that fall in a spring-forward gap; reject those.
  const wall = local.length >= 16 ? local.slice(0, 16) : local
  if (parsed.toFormat("yyyy-MM-dd'T'HH:mm") !== wall) return null
  return parsed.toUTC().toISO()
}

export function phoneToE164(value: string) {
  const parsed = parsePhoneNumberFromString(value, 'CA')
  if (!parsed?.isValid()) return null
  return parsed.number
}

export function resolvedAssignMode(form: JobForm, config: DispatchConfig | undefined): AssignMode {
  if (form.assignMode) return form.assignMode
  return config?.autoDispatchDefault ? 'AUTO' : 'MANUAL'
}

export function validateJob(form: JobForm, config: DispatchConfig, now = DateTime.utc()) {
  const errors: Record<string, string> = {}
  if (!form.pickup) errors.pickup = 'Choose a pickup from the suggestions'
  if (!form.dropoff) errors.dropoff = 'Choose a drop-off from the suggestions'
  if (form.pickup && form.dropoff && metersApart(form.pickup, form.dropoff) <= MIN_STOP_METERS) {
    errors.dropoff = 'Pickup and drop-off must be more than 50 m apart'
  }
  form.vias.forEach((via, index) => {
    if (!via?.placeId) errors[`via.${index}`] = 'Choose a stop from the suggestions'
  })
  if (!form.vehicleTypeId) errors.vehicleTypeId = 'Choose a vehicle type'
  const phone = phoneToE164(form.phone)
  if (!phone) errors.phone = 'Enter a valid phone number'
  const name = form.name.trim()
  if (name.length < 2 || name.length > 80) errors.name = 'Name must be 2 to 80 characters'
  if (form.notes.length > 500) errors.notes = 'Notes must be at most 500 characters'
  const fare = dollarsToCents(form.fixedFare)
  if (Number.isNaN(fare)) errors.fixedFare = 'Enter a dollar amount like 25 or 25.50'
  else if (fare != null && fare > config.fixedFareMaxCents) {
    errors.fixedFare = 'Fixed fare is above the maximum'
  }
  let scheduledAt: string | null = null
  if (form.when === 'LATER') {
    scheduledAt = form.scheduledLocal ? branchInstant(form.scheduledLocal, config.timezone) : null
    if (!scheduledAt) {
      errors.scheduledAt = 'That time does not exist in this time zone'
    } else {
      const when = DateTime.fromISO(scheduledAt, { zone: 'utc' })
      const earliest = now.plus({ minutes: config.scheduleMinLeadMinutes })
      const latest = now.plus({ days: config.scheduleMaxDays })
      if (when < earliest) errors.scheduledAt = `Book at least ${config.scheduleMinLeadMinutes} minutes ahead`
      else if (when > latest) errors.scheduledAt = `Book within ${config.scheduleMaxDays} days`
    }
  }
  return { errors, phone, scheduledAt, fare: Number.isNaN(fare) ? null : fare }
}

export type BookingPayload = {
  branchId?: string
  passengerName: string
  passengerPhone: string
  vehicleTypeId: string
  zone: FareZone
  assignMode: AssignMode
  vanOnly: boolean
  ladyDriverOnly: boolean
  scheduledAt?: string
  paymentMethod: 'CASH'
  notes?: string
  fixedFareCents?: number
  quoteToken: string
  stops: { address: string; lat: number; lng: number; placeId: string }[]
}

export function bookingPayload(
  form: JobForm,
  quote: FareQuote,
  config: DispatchConfig,
  branchId: string | null,
  now = DateTime.utc(),
): { payload: BookingPayload } | { errors: Record<string, string> } {
  const checked = validateJob(form, config, now)
  if (!form.pickup || !form.dropoff || !checked.phone || Object.keys(checked.errors).length > 0) {
    return { errors: checked.errors }
  }
  const option = quote.options.find((row) => row.vehicleTypeId === form.vehicleTypeId)
  if (!option) return { errors: { ...checked.errors, vehicleTypeId: 'No fare for this vehicle' } }
  const notes = form.notes.trim()
  const payload: BookingPayload = {
    ...(branchId ? { branchId } : {}),
    passengerName: form.name.trim(),
    passengerPhone: checked.phone,
    vehicleTypeId: form.vehicleTypeId,
    zone: quote.zone,
    assignMode: resolvedAssignMode(form, config),
    vanOnly: form.vanOnly,
    ladyDriverOnly: form.ladyOnly,
    ...(checked.scheduledAt ? { scheduledAt: checked.scheduledAt } : {}),
    paymentMethod: 'CASH',
    ...(notes ? { notes } : {}),
    ...(checked.fare != null ? { fixedFareCents: checked.fare } : {}),
    quoteToken: option.quoteToken,
    stops: [form.pickup, ...form.vias, form.dropoff],
  }
  return { payload }
}

export function canonicalJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map((item) => canonicalJson(item)).join(',')}]`
  if (value && typeof value === 'object') {
    const entries = Object.entries(value as Record<string, unknown>).sort(([left], [right]) =>
      left.localeCompare(right),
    )
    return `{${entries
      .map(([key, item]) => `${JSON.stringify(key)}:${canonicalJson(item)}`)
      .join(',')}}`
  }
  return JSON.stringify(value) ?? 'null'
}

export async function sha256(text: string) {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text))
  return [...new Uint8Array(digest)].map((byte) => byte.toString(16).padStart(2, '0')).join('')
}

export const CLOSED_STATUSES = new Set([
  'TRIP_COMPLETED',
  'PAYMENT_PENDING',
  'PAYMENT_COMPLETED',
  'CLOSED',
  'CANCELLED',
])
