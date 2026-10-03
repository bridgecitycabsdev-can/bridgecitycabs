import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { z } from 'zod'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import { EditJobForm } from '@/features/bookings/EditJobForm'
import { useBookingUi } from '@/features/bookings/selection'
import { LocationFields } from '@/features/dispatch/drafts/LocationFields'
import { PassengerFields } from '@/features/dispatch/drafts/PassengerFields'
import { QuoteCard } from '@/features/dispatch/drafts/QuoteCard'
import {
  bookingPayload,
  canonicalJson,
  dispatchConfigSchema,
  quoteSchema,
  resolvedAssignMode,
  sha256,
  validateJob,
  type FareZone,
  type PlaceValue,
} from '@/features/dispatch/drafts/schema'
import { anyDraftDirty, MAX_DRAFTS, useDrafts, type Draft } from '@/features/dispatch/drafts/store'
import { api, jsonBody } from '@/lib/api'

const fieldClass =
  'border-input bg-background h-8 w-full rounded-md border px-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring'

const vehicleTypesSchema = z.object({
  data: z.array(z.object({ id: z.string(), name: z.string(), active: z.boolean().optional() })),
})

const bookingCreatedSchema = z.object({
  id: z.string(),
  trackingId: z.string(),
})

const errorBodySchema = z.object({
  code: z.string().optional(),
  message: z.string().optional(),
  fields: z.record(z.string(), z.string()).optional(),
  quote: quoteSchema.optional(),
})

export function NewJobPanel() {
  const drafts = useDrafts((state) => state.drafts)
  const activeId = useDrafts((state) => state.activeId)
  const panel = useDrafts((state) => state.panel)
  const addDraft = useDrafts((state) => state.addDraft)
  const setActive = useDrafts((state) => state.setActive)
  const showEdit = useDrafts((state) => state.showEdit)
  const active = drafts.find((draft) => draft.id === activeId) ?? drafts[0]

  useEffect(() => {
    const warn = (event: BeforeUnloadEvent) => {
      if (!anyDraftDirty()) return
      event.preventDefault()
      event.returnValue = ''
    }
    window.addEventListener('beforeunload', warn)
    return () => window.removeEventListener('beforeunload', warn)
  }, [])

  return (
    <section className="bg-card flex h-full min-h-0 flex-col border-r" aria-label="Jobs Section">
      <header className="border-b px-2 py-1.5">
        <div className="flex items-center justify-between gap-2">
          <h2 className="text-sm font-semibold">Jobs Section</h2>
          <Button
            type="button"
            size="xs"
            variant="outline"
            disabled={drafts.length >= MAX_DRAFTS}
            onClick={addDraft}
          >
            New job
          </Button>
        </div>
        <div className="mt-2 flex flex-wrap gap-1" role="tablist" aria-label="Job drafts">
          {drafts.map((draft, index) => (
            <button
              key={draft.id}
              type="button"
              role="tab"
              aria-selected={panel === 'draft' && draft.id === activeId}
              className="rounded-md px-2 py-1 text-xs data-[on=true]:bg-primary data-[on=true]:text-primary-foreground"
              data-on={panel === 'draft' && draft.id === activeId}
              onClick={() => setActive(draft.id)}
            >
              New Job #{index + 1}
              {draft.dirty ? ' *' : ''}
            </button>
          ))}
          <button
            type="button"
            role="tab"
            aria-selected={panel === 'edit'}
            className="rounded-md px-2 py-1 text-xs data-[on=true]:bg-primary data-[on=true]:text-primary-foreground"
            data-on={panel === 'edit'}
            onClick={showEdit}
          >
            Edit Job
          </button>
        </div>
      </header>
      <div className="min-h-0 flex-1 overflow-auto p-2">
        {panel === 'edit' ? <EditJobForm /> : active ? <JobForm draft={active} /> : null}
      </div>
    </section>
  )
}

function JobForm({ draft }: { draft: Draft }) {
  const patch = useDrafts((state) => state.patch)
  const setZone = useDrafts((state) => state.setZone)
  const setQuote = useDrafts((state) => state.setQuote)
  const setErrors = useDrafts((state) => state.setErrors)
  const rememberIdem = useDrafts((state) => state.rememberIdem)
  const reset = useDrafts((state) => state.reset)
  const selectBooking = useDrafts((state) => state.selectBooking)
  const setSelected = useBookingUi((state) => state.setSelected)
  const queryClient = useQueryClient()
  const branchId = useBranchId()
  const [toast, setToast] = useState<{ trackingId: string } | null>(null)
  const [booking, setBooking] = useState(false)
  const [quoteBusy, setQuoteBusy] = useState(false)
  const quoteAbort = useRef<AbortController | null>(null)
  const quoteTick = useRef(0)

  const configQuery = useQuery({
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
  const vehiclesQuery = useQuery({
    queryKey: ['vehicle-types'],
    queryFn: async () => {
      const result = await api.GET('/api/v1/vehicle-types')
      if (!result.response.ok) throw new Error('Could not load vehicle types')
      const body = await jsonBody(result)
      const page = vehicleTypesSchema.safeParse(body)
      if (page.success) return page.data.data.filter((row) => row.active !== false)
      const list = z
        .array(z.object({ id: z.string(), name: z.string(), active: z.boolean().optional() }))
        .parse(body)
      return list.filter((row) => row.active !== false)
    },
  })

  const config = configQuery.data
  const assignMode = resolvedAssignMode(draft.form, config)

  const requestQuote = useCallback(
    async (zone?: FareZone | null) => {
      if (!draft.form.pickup || !draft.form.dropoff || !branchId) {
        setQuote(draft.id, null)
        return
      }
      quoteAbort.current?.abort()
      const controller = new AbortController()
      quoteAbort.current = controller
      const tick = ++quoteTick.current
      setQuoteBusy(true)
      try {
        const result = await api.POST('/api/v1/fares/quotes', {
          body: {
            branchId,
            ...(zone ? { zone } : {}),
            stops: [
              { lat: draft.form.pickup.lat, lng: draft.form.pickup.lng },
              ...draft.form.vias.map((stop) => ({ lat: stop.lat, lng: stop.lng })),
              { lat: draft.form.dropoff.lat, lng: draft.form.dropoff.lng },
            ],
          },
          signal: controller.signal,
        })
        if (controller.signal.aborted || tick !== quoteTick.current) return
        if (!result.response.ok) {
          setQuote(draft.id, null)
          return
        }
        const quote = quoteSchema.parse(await jsonBody(result))
        setQuote(draft.id, { ...quote, priceChanged: false })
        if (!draft.form.zone) setZone(draft.id, quote.zone)
      } catch {
        if (!controller.signal.aborted) setQuote(draft.id, null)
      } finally {
        if (tick === quoteTick.current) setQuoteBusy(false)
      }
    },
    [branchId, draft.form.dropoff, draft.form.pickup, draft.form.vias, draft.form.zone, draft.id, setQuote, setZone],
  )

  useEffect(() => {
    if (!draft.form.pickup || !draft.form.dropoff || !draft.form.vehicleTypeId) {
      setQuote(draft.id, null)
      return
    }
    const timer = setTimeout(() => {
      void requestQuote(draft.form.zone)
    }, 400)
    return () => clearTimeout(timer)
  }, [
    draft.form.dropoff,
    draft.form.pickup,
    draft.form.vehicleTypeId,
    draft.form.vias,
    draft.form.zone,
    draft.id,
    requestQuote,
    setQuote,
  ])

  useEffect(() => {
    function onKey(event: KeyboardEvent) {
      if (!(event.ctrlKey || event.metaKey) || event.key !== 'Enter') return
      const target = event.target
      if (target instanceof HTMLElement && !target.closest('[aria-label="Jobs Section"]')) return
      event.preventDefault()
      const button = document.querySelector<HTMLButtonElement>(
        '[aria-label="Jobs Section"] button[type="submit"]',
      )
      button?.click()
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  const viaPlace = useMemo(
    () => (index: number, place: PlaceValue | null) => {
      const vias = [...draft.form.vias]
      vias[index] = place ?? { address: '', placeId: '', lat: 0, lng: 0 }
      patch(draft.id, { vias })
    },
    [draft.form.vias, draft.id, patch],
  )

  async function book() {
    if (!config || booking) return
    const checked = validateJob(draft.form, config)
    if (Object.keys(checked.errors).length) {
      setErrors(draft.id, checked.errors)
      return
    }
    if (!draft.quote) {
      setErrors(draft.id, { quote: 'Price the trip before booking' })
      return
    }
    const built = bookingPayload(draft.form, draft.quote, config, branchId)
    if ('errors' in built) {
      setErrors(draft.id, built.errors)
      return
    }
    const hash = await sha256(canonicalJson(built.payload))
    let idem = draft.idem
    if (!idem || idem.hash !== hash) {
      idem = { key: crypto.randomUUID(), hash }
      rememberIdem(draft.id, idem)
    }
    setBooking(true)
    try {
      const result = await api.POST('/api/v1/bookings', {
        body: built.payload,
        headers: { 'Idempotency-Key': idem.key },
      })
      if (result.response.status === 201) {
        const created = bookingCreatedSchema.parse(await jsonBody(result))
        setToast({ trackingId: created.trackingId })
        reset(draft.id)
        selectBooking(created.id)
        setSelected(created.id)
        void queryClient.invalidateQueries({ queryKey: ['bookings'] })
        return
      }
      const body = errorBodySchema.safeParse(await result.response.clone().json().catch(() => null))
      if (result.response.status === 409 && body.success && body.data.code === 'QUOTE_EXPIRED') {
        if (body.data.quote) {
          const previous = draft.quote.options.find(
            (row) => row.vehicleTypeId === draft.form.vehicleTypeId,
          )
          const next = body.data.quote.options.find(
            (row) => row.vehicleTypeId === draft.form.vehicleTypeId,
          )
          const priceChanged =
            previous != null && next != null && previous.totalCents !== next.totalCents
          setQuote(draft.id, { ...body.data.quote, priceChanged })
        }
        setErrors(draft.id, { quote: 'Quote expired. Confirm the new price, then book again.' })
        return
      }
      if (result.response.status === 422 || result.response.status === 400) {
        setErrors(draft.id, body.success ? (body.data.fields ?? { form: body.data.message ?? 'Check the form' }) : { form: 'Check the form' })
        return
      }
      setErrors(draft.id, { form: body.success ? (body.data.message ?? 'Could not book') : 'Could not book' })
    } finally {
      setBooking(false)
    }
  }

  return (
    <form
      className="space-y-3"
      onSubmit={(event) => {
        event.preventDefault()
        void book()
      }}
    >
      <LocationFields
        pickup={draft.form.pickup}
        dropoff={draft.form.dropoff}
        vias={draft.form.vias}
        errors={draft.errors}
        onPickup={(place) => patch(draft.id, { pickup: place })}
        onDropoff={(place) => patch(draft.id, { dropoff: place })}
        onVia={viaPlace}
        onAddVia={() => {
          if (draft.form.vias.length >= 3) return
          patch(draft.id, {
            vias: [...draft.form.vias, { address: '', placeId: '', lat: 0, lng: 0 }],
          })
        }}
        onRemoveVia={(index) =>
          patch(draft.id, { vias: draft.form.vias.filter((_, item) => item !== index) })
        }
        onSwap={() =>
          patch(draft.id, { pickup: draft.form.dropoff, dropoff: draft.form.pickup })
        }
      />

      <fieldset className="space-y-2">
        <legend className="text-xs font-medium">Vehicle</legend>
        <label className="block text-xs">
          <span className="text-muted-foreground">Type</span>
          <select
            className={fieldClass}
            aria-label="Vehicle type"
            value={draft.form.vehicleTypeId}
            onChange={(event) => patch(draft.id, { vehicleTypeId: event.target.value })}
          >
            <option value="">Select…</option>
            {vehiclesQuery.data?.map((type) => (
              <option key={type.id} value={type.id}>
                {type.name}
              </option>
            ))}
          </select>
          {draft.errors.vehicleTypeId ? (
            <span className="text-destructive">{draft.errors.vehicleTypeId}</span>
          ) : null}
        </label>
        <label className="flex items-center gap-2 text-sm">
          <input
            type="checkbox"
            checked={draft.form.vanOnly}
            onChange={(event) => patch(draft.id, { vanOnly: event.target.checked })}
          />
          Van Only
        </label>
        <label className="flex items-center gap-2 text-sm">
          <input
            type="checkbox"
            checked={draft.form.ladyOnly}
            onChange={(event) => patch(draft.id, { ladyOnly: event.target.checked })}
          />
          Lady Only
        </label>
      </fieldset>

      <fieldset className="space-y-2">
        <legend className="text-xs font-medium">When</legend>
        <div className="flex gap-1">
          {(['NOW', 'LATER'] as const).map((when) => (
            <button
              key={when}
              type="button"
              className="rounded-md px-2 py-1 text-xs data-[on=true]:bg-primary data-[on=true]:text-primary-foreground"
              data-on={draft.form.when === when}
              onClick={() => patch(draft.id, { when })}
            >
              {when === 'NOW' ? 'Now' : 'Later'}
            </button>
          ))}
        </div>
        {draft.form.when === 'LATER' ? (
          <label className="block text-xs">
            <span className="text-muted-foreground">
              Date and time ({config?.timezone ?? 'branch time'})
            </span>
            <input
              type="datetime-local"
              className={fieldClass}
              aria-label="Scheduled time"
              value={draft.form.scheduledLocal}
              onChange={(event) => patch(draft.id, { scheduledLocal: event.target.value })}
            />
            {draft.errors.scheduledAt ? (
              <span className="text-destructive">{draft.errors.scheduledAt}</span>
            ) : null}
          </label>
        ) : null}
      </fieldset>

      <PassengerFields draft={draft} />

      <fieldset className="space-y-2">
        <legend className="text-xs font-medium">Fare and assign</legend>
        <label className="block text-xs">
          <span className="text-muted-foreground">Fixed fare (optional)</span>
          <input
            className={fieldClass}
            aria-label="Fixed fare"
            inputMode="decimal"
            placeholder="0.00"
            value={draft.form.fixedFare}
            onChange={(event) => patch(draft.id, { fixedFare: event.target.value })}
          />
          {draft.errors.fixedFare ? (
            <span className="text-destructive">{draft.errors.fixedFare}</span>
          ) : null}
        </label>
        <div className="flex gap-1" role="group" aria-label="Assign mode">
          {(['AUTO', 'MANUAL'] as const).map((mode) => (
            <button
              key={mode}
              type="button"
              className="rounded-md px-2 py-1 text-xs data-[on=true]:bg-primary data-[on=true]:text-primary-foreground"
              data-on={assignMode === mode}
              onClick={() => patch(draft.id, { assignMode: mode })}
            >
              {mode === 'AUTO' ? 'Auto' : 'Manual'}
            </button>
          ))}
        </div>
        <div>
          <p className="text-muted-foreground text-xs">Payment</p>
          <div className="mt-1 flex flex-wrap gap-1">
            <span className="bg-primary text-primary-foreground rounded-md px-2 py-1 text-xs">Cash</span>
            <span className="text-muted-foreground rounded-md border px-2 py-1 text-xs opacity-60" title="Coming with payments">
              Card
            </span>
            <span
              className="text-muted-foreground rounded-md border px-2 py-1 text-xs opacity-60"
              title="Coming with corporate accounts"
            >
              Account
            </span>
          </div>
        </div>
      </fieldset>

      <QuoteCard
        quote={draft.quote}
        vehicleTypeId={draft.form.vehicleTypeId}
        busy={quoteBusy}
        onZone={(zone) => {
          setZone(draft.id, zone)
          void requestQuote(zone)
        }}
        onRecalculate={() => void requestQuote(draft.form.zone)}
      />

      {draft.errors.quote || draft.errors.form ? (
        <p className="text-destructive text-sm">{draft.errors.quote ?? draft.errors.form}</p>
      ) : null}

      <div className="flex items-center gap-2">
        <Button type="submit" disabled={booking || !config}>
          {booking ? 'Booking…' : 'Book'}
        </Button>
        <span className="text-muted-foreground text-xs">Ctrl+Enter</span>
      </div>

      {toast ? (
        <div className="bg-muted flex items-center justify-between gap-2 rounded-md border px-2 py-1.5 text-sm">
          <span>
            Booked <strong>{toast.trackingId}</strong>
          </span>
          <Button
            type="button"
            size="xs"
            variant="outline"
            onClick={() => void navigator.clipboard.writeText(toast.trackingId)}
          >
            Copy
          </Button>
        </div>
      ) : null}
    </form>
  )
}

function useBranchId() {
  const role = useSession((state) => state.profile?.role.name)
  const selected = useSession((state) => state.branchId)
  const own = useSession((state) => state.profile?.branch?.id)
  return role === 'super_admin' ? selected : (own ?? null)
}
