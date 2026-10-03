import { useQuery, useQueryClient } from '@tanstack/react-query'
import { DateTime } from 'luxon'
import { useEffect, useMemo, useState } from 'react'
import { z } from 'zod'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import { apiErrorBody } from '@/features/bookings/api-error'
import {
  dropoffStop,
  formatBranchTime,
  formatMoney,
  pickupStop,
  type BookingDetail,
} from '@/features/bookings/booking-detail'
import { useBookingUi } from '@/features/bookings/selection'
import { useBookingDetail } from '@/features/bookings/use-booking-detail'
import { LocationFields } from '@/features/dispatch/drafts/LocationFields'
import {
  dispatchConfigSchema,
  dollarsToCents,
  phoneToE164,
  type PlaceValue,
} from '@/features/dispatch/drafts/schema'
import { useDrafts } from '@/features/dispatch/drafts/store'
import { api, jsonBody } from '@/lib/api'

const fieldClass =
  'border-input bg-background h-8 w-full rounded-md border px-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:opacity-50'

const vehicleTypesSchema = z.object({
  data: z.array(z.object({ id: z.string(), name: z.string(), active: z.boolean().optional() })),
})

type EditForm = {
  passengerName: string
  passengerPhone: string
  vehicleTypeId: string
  zone: 'INSIDE_TOWN' | 'OUT_OF_TOWN'
  vanOnly: boolean
  ladyDriverOnly: boolean
  when: 'NOW' | 'LATER'
  scheduledLocal: string
  notes: string
  fixedFare: string
  paymentMethod: string
  pickup: PlaceValue | null
  vias: PlaceValue[]
  dropoff: PlaceValue | null
}

export function EditJobForm() {
  const bookingId = useDrafts((state) => state.selectedBookingId)
  const setToast = useBookingUi((state) => state.setToast)
  const detail = useBookingDetail(bookingId)
  const branchId = useBranchId()
  const queryClient = useQueryClient()
  const [form, setForm] = useState<EditForm | null>(null)
  const [conflict, setConflict] = useState<string[]>([])
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [saving, setSaving] = useState(false)

  const config = useQuery({
    queryKey: ['dispatch-config', branchId],
    enabled: Boolean(branchId),
    queryFn: async () => {
      const result = await api.GET('/api/v1/config/dispatch', {
        params: { query: { branchId: branchId! } },
      })
      if (!result.response.ok) throw new Error('Could not load dispatch rules')
      return dispatchConfigSchema.parse(await jsonBody(result))
    },
  })

  const vehicles = useQuery({
    queryKey: ['vehicle-types'],
    queryFn: async () => {
      const result = await api.GET('/api/v1/vehicle-types')
      if (!result.response.ok) throw new Error('Could not load vehicle types')
      const body = await jsonBody(result)
      const page = vehicleTypesSchema.safeParse(body)
      if (page.success) return page.data.data.filter((row) => row.active !== false)
      return z
        .array(z.object({ id: z.string(), name: z.string(), active: z.boolean().optional() }))
        .parse(body)
        .filter((row) => row.active !== false)
    },
  })

  const loadedId = detail.data?.id
  const loadedVersion = detail.data?.version
  const branchTimezone = config.data?.timezone
  useEffect(() => {
    if (!detail.data || !branchTimezone) return
    setForm(toForm(detail.data, branchTimezone))
  }, [detail.data, loadedId, loadedVersion, branchTimezone])

  const editable = useMemo(
    () => new Set(detail.data?.editableFields ?? []),
    [detail.data?.editableFields],
  )

  if (!bookingId) {
    return (
      <p className="text-muted-foreground text-sm">Select a booking on the right to edit it here.</p>
    )
  }
  if (detail.isPending || !form || !config.data) {
    return <p className="text-muted-foreground text-sm">Loading job…</p>
  }
  if (!detail.data) {
    return <p className="text-destructive text-sm">Could not load this job.</p>
  }

  const booking = detail.data
  const timezone = config.data.timezone
  const can = (field: string) => editable.has(field)

  function patch(next: Partial<EditForm>) {
    setForm((state) => (state ? { ...state, ...next } : state))
    setErrors({})
    setConflict([])
  }

  async function save() {
    if (!form || !booking || saving) return
    const body: Record<string, unknown> = { version: booking.version }
    if (can('passengerName') && form.passengerName.trim() !== booking.passengerName) {
      body.passengerName = form.passengerName.trim()
    }
    if (can('passengerPhone')) {
      const phone = phoneToE164(form.passengerPhone)
      if (!phone) {
        setErrors({ passengerPhone: 'Enter a valid phone number' })
        return
      }
      if (phone !== booking.passengerPhone) body.passengerPhone = phone
    }
    if (can('vehicleTypeId') && form.vehicleTypeId !== booking.vehicleTypeId) {
      body.vehicleTypeId = form.vehicleTypeId
    }
    if (can('zone') && form.zone !== booking.zone) body.zone = form.zone
    if (can('vanOnly') && form.vanOnly !== booking.vanOnly) body.vanOnly = form.vanOnly
    if (can('ladyDriverOnly') && form.ladyDriverOnly !== booking.ladyDriverOnly) {
      body.ladyDriverOnly = form.ladyDriverOnly
    }
    if (can('notes')) {
      const notes = form.notes.trim() || null
      if (notes !== (booking.notes ?? null)) body.notes = notes ?? ''
    }
    if (can('fixedFareCents')) {
      const fare = dollarsToCents(form.fixedFare)
      if (Number.isNaN(fare)) {
        setErrors({ fixedFare: 'Enter a dollar amount like 25 or 25.50' })
        return
      }
      if (fare !== booking.fixedFareCents) {
        body.fixedFareCents = fare ?? 0
      }
    }
    if (can('paymentMethod') && form.paymentMethod !== booking.paymentMethod) {
      body.paymentMethod = form.paymentMethod
    }
    if (can('scheduledAt')) {
      if (form.when === 'LATER') {
        const local = form.scheduledLocal
          ? DateTime.fromISO(form.scheduledLocal, { zone: timezone })
          : null
        const iso = local?.isValid ? local.toUTC().toISO() : null
        if (!iso) {
          setErrors({ scheduledAt: 'Choose a valid time' })
          return
        }
        if (iso !== booking.scheduledAt) body.scheduledAt = iso
      }
    }
    if (can('stops') && form.pickup && form.dropoff) {
      const stops = [form.pickup, ...form.vias.filter((via) => via.placeId), form.dropoff]
      const current = [...booking.stops]
        .sort((left, right) => left.sequence - right.sequence)
        .map((stop) => ({
          address: stop.address,
          lat: stop.lat,
          lng: stop.lng,
          placeId: stop.placeId ?? '',
        }))
      const next = stops.map((stop) => ({
        address: stop.address,
        lat: stop.lat,
        lng: stop.lng,
        placeId: stop.placeId,
      }))
      if (JSON.stringify(current) !== JSON.stringify(next)) body.stops = next
    }

    if (Object.keys(body).length === 1) {
      setToast('No changes to save')
      return
    }

    const previous = booking
    setSaving(true)
    try {
      const result = await api.PATCH('/api/v1/bookings/{id}', {
        params: { path: { id: booking.id } },
        body: body as never,
      })
      if (result.response.status === 409) {
        const err = apiErrorBody(result)
        if (err.success && err.data.code === 'VERSION_CONFLICT') {
          const refreshed = await queryClient.fetchQuery({
            queryKey: ['booking', booking.id],
            queryFn: async () => {
              const fresh = await api.GET('/api/v1/bookings/{id}', {
                params: { path: { id: booking.id } },
              })
              if (!fresh.response.ok) throw new Error('reload failed')
              const { bookingDetailSchema } = await import('@/features/bookings/booking-detail')
              return bookingDetailSchema.parse(await jsonBody(fresh))
            },
          })
          setForm(toForm(refreshed, timezone))
          setConflict(diffFields(previous, refreshed))
          setToast('Someone else updated this job. Review the changes, then save again.')
          return
        }
        setToast('Could not save')
        return
      }
      if (!result.response.ok) {
        const bodyErr = apiErrorBody(result)
        if (bodyErr.success && bodyErr.data.fields) {
          setErrors(bodyErr.data.fields)
        } else {
          setToast(bodyErr.success ? (bodyErr.data.message ?? 'Could not save') : 'Could not save')
        }
        return
      }
      void queryClient.invalidateQueries({ queryKey: ['bookings'] })
      void queryClient.invalidateQueries({ queryKey: ['booking', booking.id] })
      setConflict([])
      setToast('Job updated')
    } finally {
      setSaving(false)
    }
  }

  return (
    <form
      className="space-y-3"
      onSubmit={(event) => {
        event.preventDefault()
        void save()
      }}
    >
      <div className="flex items-start justify-between gap-2">
        <div>
          <p className="text-sm font-semibold">{booking.trackingId}</p>
          <p className="text-muted-foreground text-xs">
            v{booking.version} · {booking.status}
          </p>
        </div>
        <Button type="submit" size="sm" disabled={saving || editable.size === 0}>
          {saving ? 'Saving…' : 'Save'}
        </Button>
      </div>

      {conflict.length ? (
        <div className="border-destructive/40 bg-destructive/5 rounded-md border px-2.5 py-2 text-sm">
          <p className="font-medium">Updated on the server</p>
          <ul className="mt-1 list-disc pl-4 text-xs">
            {conflict.map((line) => (
              <li key={line}>{line}</li>
            ))}
          </ul>
        </div>
      ) : null}

      {can('stops') ? (
        <LocationFields
          pickup={form.pickup}
          dropoff={form.dropoff}
          vias={form.vias}
          errors={errors}
          onPickup={(place) => patch({ pickup: place })}
          onDropoff={(place) => patch({ dropoff: place })}
          onVia={(index, place) => {
            const vias = [...form.vias]
            vias[index] = place ?? { address: '', placeId: '', lat: 0, lng: 0 }
            patch({ vias })
          }}
          onAddVia={() => {
            if (form.vias.length >= 3) return
            patch({ vias: [...form.vias, { address: '', placeId: '', lat: 0, lng: 0 }] })
          }}
          onRemoveVia={(index) => patch({ vias: form.vias.filter((_, item) => item !== index) })}
          onSwap={() => patch({ pickup: form.dropoff, dropoff: form.pickup })}
        />
      ) : (
        <p className="text-muted-foreground text-xs">
          From {pickupStop(booking.stops)?.address ?? '—'} →{' '}
          {dropoffStop(booking.stops)?.address ?? '—'}
        </p>
      )}

      <label className="block text-xs">
        <span className="text-muted-foreground">Passenger</span>
        <input
          className={fieldClass}
          disabled={!can('passengerName')}
          value={form.passengerName}
          onChange={(event) => patch({ passengerName: event.target.value })}
        />
        {errors.passengerName ? <p className="text-destructive mt-0.5">{errors.passengerName}</p> : null}
      </label>

      <label className="block text-xs">
        <span className="text-muted-foreground">Phone</span>
        <input
          className={fieldClass}
          disabled={!can('passengerPhone')}
          value={form.passengerPhone}
          onChange={(event) => patch({ passengerPhone: event.target.value })}
        />
        {errors.passengerPhone ? (
          <p className="text-destructive mt-0.5">{errors.passengerPhone}</p>
        ) : null}
      </label>

      <label className="block text-xs">
        <span className="text-muted-foreground">Vehicle type</span>
        <select
          className={fieldClass}
          disabled={!can('vehicleTypeId')}
          value={form.vehicleTypeId}
          onChange={(event) => patch({ vehicleTypeId: event.target.value })}
        >
          {vehicles.data?.map((type) => (
            <option key={type.id} value={type.id}>
              {type.name}
            </option>
          ))}
        </select>
      </label>

      <label className="block text-xs">
        <span className="text-muted-foreground">Zone</span>
        <select
          className={fieldClass}
          disabled={!can('zone')}
          value={form.zone}
          onChange={(event) =>
            patch({ zone: event.target.value as EditForm['zone'] })
          }
        >
          <option value="INSIDE_TOWN">Within town</option>
          <option value="OUT_OF_TOWN">Out of town</option>
        </select>
      </label>

      <div className="flex flex-wrap gap-3 text-xs">
        <label className="inline-flex items-center gap-1.5">
          <input
            type="checkbox"
            disabled={!can('vanOnly')}
            checked={form.vanOnly}
            onChange={(event) => patch({ vanOnly: event.target.checked })}
          />
          Van only
        </label>
        <label className="inline-flex items-center gap-1.5">
          <input
            type="checkbox"
            disabled={!can('ladyDriverOnly')}
            checked={form.ladyDriverOnly}
            onChange={(event) => patch({ ladyDriverOnly: event.target.checked })}
          />
          Lady driver
        </label>
      </div>

      <fieldset className="space-y-1.5" disabled={!can('scheduledAt')}>
        <legend className="text-xs font-medium">When</legend>
        <div className="flex gap-3 text-xs">
          <label className="inline-flex items-center gap-1.5">
            <input
              type="radio"
              checked={form.when === 'NOW'}
              onChange={() => patch({ when: 'NOW' })}
            />
            ASAP
          </label>
          <label className="inline-flex items-center gap-1.5">
            <input
              type="radio"
              checked={form.when === 'LATER'}
              onChange={() => patch({ when: 'LATER' })}
            />
            Scheduled
          </label>
        </div>
        {form.when === 'LATER' ? (
          <input
            type="datetime-local"
            className={fieldClass}
            value={form.scheduledLocal}
            onChange={(event) => patch({ scheduledLocal: event.target.value })}
          />
        ) : null}
        {errors.scheduledAt ? <p className="text-destructive text-xs">{errors.scheduledAt}</p> : null}
        <p className="text-muted-foreground text-xs">
          Branch time: {formatBranchTime(booking.scheduledAt ?? booking.createdAt, timezone)}
        </p>
      </fieldset>

      <label className="block text-xs">
        <span className="text-muted-foreground">Fixed fare</span>
        <input
          className={fieldClass}
          disabled={!can('fixedFareCents')}
          value={form.fixedFare}
          onChange={(event) => patch({ fixedFare: event.target.value })}
          placeholder={formatMoney(booking.quotedFareCents + booking.quotedTaxCents)}
        />
        {errors.fixedFare ? <p className="text-destructive mt-0.5">{errors.fixedFare}</p> : null}
      </label>

      <label className="block text-xs">
        <span className="text-muted-foreground">Notes</span>
        <textarea
          className="border-input bg-background min-h-20 w-full rounded-md border px-2 py-1.5 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring disabled:opacity-50"
          disabled={!can('notes')}
          value={form.notes}
          onChange={(event) => patch({ notes: event.target.value })}
        />
      </label>
    </form>
  )
}

function toForm(booking: BookingDetail, timezone: string): EditForm {
  const stops = [...booking.stops].sort((left, right) => left.sequence - right.sequence)
  const pickup = pickupStop(stops)
  const dropoff = dropoffStop(stops)
  const vias = stops.filter((stop) => stop.type === 'STOP' || (stop !== pickup && stop !== dropoff))
  const scheduledLocal = booking.scheduledAt
    ? (DateTime.fromISO(booking.scheduledAt, { zone: 'utc' })
        .setZone(timezone)
        .toFormat("yyyy-LL-dd'T'HH:mm") ?? '')
    : ''
  return {
    passengerName: booking.passengerName,
    passengerPhone: booking.passengerPhone,
    vehicleTypeId: booking.vehicleTypeId,
    zone: booking.zone,
    vanOnly: booking.vanOnly,
    ladyDriverOnly: booking.ladyDriverOnly,
    when: booking.scheduledAt ? 'LATER' : 'NOW',
    scheduledLocal,
    notes: booking.notes ?? '',
    fixedFare:
      booking.fixedFareCents != null ? (booking.fixedFareCents / 100).toFixed(2) : '',
    paymentMethod: booking.paymentMethod,
    pickup: pickup
      ? {
          address: pickup.address,
          placeId: pickup.placeId ?? '',
          lat: pickup.lat,
          lng: pickup.lng,
        }
      : null,
    vias: vias.map((stop) => ({
      address: stop.address,
      placeId: stop.placeId ?? '',
      lat: stop.lat,
      lng: stop.lng,
    })),
    dropoff: dropoff
      ? {
          address: dropoff.address,
          placeId: dropoff.placeId ?? '',
          lat: dropoff.lat,
          lng: dropoff.lng,
        }
      : null,
  }
}

function diffFields(before: BookingDetail, after: BookingDetail) {
  const lines: string[] = []
  const watch: (keyof BookingDetail)[] = [
    'passengerName',
    'passengerPhone',
    'status',
    'vehicleTypeId',
    'zone',
    'vanOnly',
    'ladyDriverOnly',
    'scheduledAt',
    'notes',
    'fixedFareCents',
    'paymentMethod',
    'assignMode',
    'version',
  ]
  for (const key of watch) {
    if (before[key] !== after[key]) {
      lines.push(`${String(key)}: ${String(before[key])} → ${String(after[key])}`)
    }
  }
  if (JSON.stringify(before.stops) !== JSON.stringify(after.stops)) {
    lines.push('stops changed')
  }
  return lines.length ? lines : ['Job was updated']
}

function useBranchId() {
  const role = useSession((state) => state.profile?.role.name)
  const selected = useSession((state) => state.branchId)
  const own = useSession((state) => state.profile?.branch?.id)
  return role === 'super_admin' ? selected : (own ?? null)
}
