import { DateTime } from 'luxon'
import { z } from 'zod'

export const jobRowSchema = z.object({
  id: z.string(),
  trackingId: z.string(),
  status: z.string(),
  source: z.string(),
  passengerName: z.string(),
  passengerPhone: z.string(),
  notes: z.string().nullable().optional(),
  createdAt: z.union([z.string(), z.date()]).transform((value) =>
    typeof value === 'string' ? value : value.toISOString(),
  ),
  scheduledAt: z
    .union([z.string(), z.date(), z.null()])
    .nullable()
    .optional()
    .transform((value) => {
      if (value == null) return null
      return typeof value === 'string' ? value : value.toISOString()
    }),
  stops: z
    .array(
      z.object({
        sequence: z.number(),
        address: z.string(),
        type: z.string().optional(),
      }),
    )
    .default([]),
})

export type JobRow = z.infer<typeof jobRowSchema>

export const jobsPageSchema = z.object({
  data: z.array(jobRowSchema),
  meta: z.object({
    page: z.number(),
    pageSize: z.number(),
    total: z.number(),
    totalPages: z.number(),
  }),
})

export type JobsPage = z.infer<typeof jobsPageSchema>

export const CLOSED_STATUSES = [
  'TRIP_COMPLETED',
  'PAYMENT_PENDING',
  'PAYMENT_COMPLETED',
  'CLOSED',
  'CANCELLED',
] as const

export function stopAddress(
  stops: JobRow['stops'],
  kind: 'PICKUP' | 'DROPOFF',
) {
  if (!stops.length) return '—'
  if (kind === 'PICKUP') {
    const pickup = stops.find((stop) => stop.type === 'PICKUP')
    if (pickup) return pickup.address
    return [...stops].sort((left, right) => left.sequence - right.sequence)[0]?.address ?? '—'
  }
  const dropoff = stops.find((stop) => stop.type === 'DROPOFF')
  if (dropoff) return dropoff.address
  return [...stops].sort((left, right) => left.sequence - right.sequence).at(-1)?.address ?? '—'
}

export function bookedLabel(row: JobRow, timezone: string) {
  const iso = row.scheduledAt ?? row.createdAt
  const when = DateTime.fromISO(iso, { zone: 'utc' }).setZone(timezone)
  if (!when.isValid) return '—'
  return when.toFormat('dd LLL, h:mm a')
}

/** Start/end of a calendar day in branch time, as UTC ISO instants for the list API. */
export function branchDayRange(date: string, timezone: string) {
  const day = DateTime.fromISO(date, { zone: timezone })
  if (!day.isValid) return null
  const from = day.startOf('day').toUTC().toISO()
  const to = day.endOf('day').toUTC().toISO()
  if (!from || !to) return null
  return { from, to }
}

export function todayInBranch(timezone: string) {
  return DateTime.now().setZone(timezone).toFormat('yyyy-LL-dd')
}
