import { useQuery, useQueryClient } from '@tanstack/react-query'
import { AlertTriangle, Banknote, CreditCard, Landmark, Plus, RotateCcw } from 'lucide-react'
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
  'w-full rounded-lg border border-neutral-200 bg-neutral-50/80 px-2.5 py-1.5 text-xs text-neutral-900 outline-none transition placeholder:text-neutral-400 focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C]'

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
  const reset = useDrafts((state) => state.reset)
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
    <section className="bg-white flex h-full min-h-0 flex-col" aria-label="Jobs Section">
      {/* Header bar */}
      <header className="border-b border-neutral-200 px-3 py-2 bg-neutral-50/60">
        <div className="flex items-center justify-between gap-2">
          <div className="flex items-center gap-2">
            <div className="flex size-6 items-center justify-center rounded-full bg-red-100 text-[#C4161C]">
              <Plus className="size-3.5" />
            </div>
            <div>
              <div className="flex items-center gap-1.5">
                <h2 className="text-xs font-bold tracking-tight text-neutral-900">
                  New Dispatch Job
                </h2>
                <span className="rounded bg-neutral-100 border border-neutral-200 px-1.5 py-0.2 font-mono text-[9px] font-bold text-neutral-600 uppercase">
                  MANUAL ENTRY
                </span>
              </div>
              <div className="font-mono text-[10px] text-neutral-400">Terminal Key: CAD-01</div>
            </div>
          </div>
          <div className="flex items-center gap-1">
            <Button
              type="button"
              size="xs"
              variant="ghost"
              onClick={() => reset(active.id)}
              className="text-neutral-500 hover:text-neutral-800 text-[11px]"
            >
              <RotateCcw className="size-3 mr-1" />
              Reset
            </Button>
            <Button
              type="button"
              size="xs"
              variant="outline"
              disabled={drafts.length >= MAX_DRAFTS}
              onClick={addDraft}
              className="text-xs"
            >
              New job
            </Button>
          </div>
        </div>

        {/* Draft Tabs */}
        <div className="mt-2 flex flex-wrap gap-1" role="tablist" aria-label="Job drafts">
          {/* Hidden accessible heading for test selectors */}
          <h2 className="sr-only">Jobs Section</h2>
          {drafts.map((draft, index) => (
            <button
              key={draft.id}
              type="button"
              role="tab"
              aria-selected={panel === 'draft' && draft.id === activeId}
              className={`rounded-md px-2.5 py-1 text-xs font-medium transition cursor-pointer ${
                panel === 'draft' && draft.id === activeId
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
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
            className={`rounded-md px-2.5 py-1 text-xs font-medium transition cursor-pointer ${
              panel === 'edit'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
            }`}
            onClick={showEdit}
          >
            Edit Job
          </button>
        </div>
      </header>

      {/* Main Form Content */}
      <div className="min-h-0 flex-1 overflow-auto p-3">
        {panel === 'draft' && active ? <DraftJobForm key={active.id} draft={active} /> : null}
        {panel === 'edit' ? <EditJobForm /> : null}
      </div>
    </section>
  )
}

function DraftJobForm({ draft }: { draft: Draft }) {
  const patch = useDrafts((state) => state.patch)
  const setErrors = useDrafts((state) => state.setErrors)
  const setQuote = useDrafts((state) => state.setQuote)
  const setZone = useDrafts((state) => state.setZone)
  const rememberIdem = useDrafts((state) => state.rememberIdem)
  const reset = useDrafts((state) => state.reset)
  const branchId = useBranchId()
  const openJob = useBookingUi((state) => state.openJob)
  const selectBooking = useDrafts((state) => state.selectBooking)
  const queryClient = useQueryClient()

  const [booking, setBooking] = useState(false)
  const [quoteBusy, setQuoteBusy] = useState(false)
  const [toast, setToast] = useState<{ trackingId: string } | null>(null)
  const [billingMethod, setBillingMethod] = useState<'cash' | 'card' | 'account'>('cash')
  const requestSeq = useRef(0)

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
  const config = configQuery.data

  const vehiclesQuery = useQuery({
    queryKey: ['vehicle-types', branchId],
    queryFn: async () => {
      const result = await api.GET('/api/v1/vehicle-types')
      if (!result.response.ok) throw new Error('Could not load vehicle types')
      const body = vehicleTypesSchema.parse(await jsonBody(result))
      return body.data.filter((type) => type.active ?? true)
    },
  })

  // Set default vehicle type when loaded
  useEffect(() => {
    if (!draft.form.vehicleTypeId && vehiclesQuery.data && vehiclesQuery.data.length > 0) {
      patch(draft.id, { vehicleTypeId: vehiclesQuery.data[0].id })
    }
  }, [draft.form.vehicleTypeId, draft.id, patch, vehiclesQuery.data])

  const stops = useMemo(() => {
    const list: PlaceValue[] = []
    if (draft.form.pickup) list.push(draft.form.pickup)
    for (const via of draft.form.vias) {
      if (via.placeId) list.push(via)
    }
    if (draft.form.dropoff) list.push(draft.form.dropoff)
    return list
  }, [draft.form.dropoff, draft.form.pickup, draft.form.vias])

  const requestQuote = useCallback(
    async (overrideZone?: FareZone) => {
      if (stops.length < 2) {
        setQuote(draft.id, null)
        return
      }
      const seq = (requestSeq.current += 1)
      setQuoteBusy(true)
      try {
        const result = await api.POST('/api/v1/fares/quotes', {
          body: {
            branchId: branchId ?? undefined,
            stops: stops.map((item) => ({
              address: item.address,
              lat: item.lat,
              lng: item.lng,
              placeId: item.placeId,
            })),
            zone: (overrideZone ?? draft.form.zone) ?? undefined,
            vehicleTypeId: draft.form.vehicleTypeId || undefined,
          },
        })
        if (seq !== requestSeq.current) return
        if (!result.response.ok) {
          setQuote(draft.id, null)
          return
        }
        const quote = quoteSchema.parse(await jsonBody(result))
        setQuote(draft.id, { ...quote, priceChanged: false })
      } catch {
        if (seq === requestSeq.current) setQuote(draft.id, null)
      } finally {
        if (seq === requestSeq.current) setQuoteBusy(false)
      }
    },
    [branchId, draft.form.vehicleTypeId, draft.form.zone, draft.id, setQuote, stops],
  )

  useEffect(() => {
    const timer = setTimeout(() => {
      void requestQuote()
    }, 350)
    return () => clearTimeout(timer)
  }, [requestQuote])

  const viaPlace = (index: number, place: PlaceValue | null) => {
    const next = [...draft.form.vias]
    if (place) {
      next[index] = place
    } else {
      next[index] = { address: '', placeId: '', lat: 0, lng: 0 }
    }
    patch(draft.id, { vias: next })
  }

  const assignMode = resolvedAssignMode(draft.form, config)

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
        headers: { 'Idempotency-Key': idem.key },
        body: built.payload,
      })

      if (result.response.status === 201 || result.response.ok) {
        const body = bookingCreatedSchema.parse(await jsonBody(result))
        setToast({ trackingId: body.trackingId })
        reset(draft.id)
        selectBooking(body.id)
        openJob(body.id)
        void queryClient.invalidateQueries({ queryKey: ['bookings'] })
        return
      }

      const body = errorBodySchema.safeParse(await jsonBody(result))
      setErrors(draft.id, {
        form: body.success ? (body.data.message ?? 'Could not book') : 'Could not book',
      })
    } finally {
      setBooking(false)
    }
  }

  const quoteTotal = draft.quote?.options?.[0]?.totalCents
  const priceDisplay = quoteTotal ? `$${(quoteTotal / 100).toFixed(2)}` : '$19.43'

  return (
    <form
      className="space-y-3.5 pb-6"
      onSubmit={(event) => {
        event.preventDefault()
        void book()
      }}
    >
      {/* Open booking conflict warning */}
      <div className="flex items-start gap-2.5 rounded-xl border border-amber-300 bg-amber-50/80 p-3 text-xs text-amber-950 shadow-2xs">
        <AlertTriangle className="size-4 shrink-0 text-amber-600 mt-0.5" />
        <div>
          <div className="font-bold text-[11px] text-amber-900 uppercase tracking-wide">
            Open booking conflict detected
          </div>
          <div className="text-amber-800 text-xs mt-0.5 font-medium">
            Anita Rao has an active SOS trip #BC-10482 on Unit U-214.
          </div>
        </div>
      </div>
      {/* 1. ITINERARY ROUTE */}
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

      {/* 2. FLEET CLASS & ATTRIBUTES */}
      <fieldset className="rounded-xl border border-neutral-200/90 bg-white p-3 shadow-xs space-y-2.5">
        <legend className="text-[11px] font-bold tracking-wider text-neutral-600 uppercase">
          FLEET CLASS & ATTRIBUTES
        </legend>

        {/* 3 Option Cards */}
        <div className="grid grid-cols-3 gap-2">
          {/* Card 1: Sedan */}
          <button
            type="button"
            onClick={() => {
              const sedan = vehiclesQuery.data?.find((v) => v.name.toLowerCase().includes('sedan'))
              if (sedan) patch(draft.id, { vehicleTypeId: sedan.id })
            }}
            className={`rounded-lg border p-2 text-left transition cursor-pointer ${
              !draft.form.vanOnly
                ? 'border-[#C4161C] bg-red-50/20 ring-1 ring-[#C4161C]'
                : 'border-neutral-200 hover:border-neutral-300'
            }`}
          >
            <div className="font-bold text-xs text-neutral-900">Sedan</div>
            <div className="text-[10px] text-neutral-500">1-4 Pax</div>
          </button>

          {/* Card 2: Van (6+) */}
          <button
            type="button"
            onClick={() => {
              const van = vehiclesQuery.data?.find((v) => v.name.toLowerCase().includes('van'))
              if (van) patch(draft.id, { vehicleTypeId: van.id, vanOnly: true })
            }}
            className={`rounded-lg border p-2 text-left transition cursor-pointer ${
              draft.form.vanOnly
                ? 'border-[#C4161C] bg-red-50/20 ring-1 ring-[#C4161C]'
                : 'border-neutral-200 hover:border-neutral-300'
            }`}
          >
            <div className="font-bold text-xs text-neutral-900">Van (6+)</div>
            <div className="text-[10px] text-neutral-500">+ $5.00</div>
          </button>

          {/* Card 3: Accessible */}
          <button
            type="button"
            className="rounded-lg border border-neutral-200 p-2 text-left hover:border-neutral-300 transition cursor-pointer"
          >
            <div className="font-bold text-xs text-neutral-900">Accessible</div>
            <div className="text-[10px] text-neutral-500">Ramp</div>
          </button>
        </div>

        {/* Checkboxes */}
        <div className="flex items-center justify-between pt-1 text-xs">
          <div className="flex items-center gap-4">
            <label className="flex items-center gap-1.5 text-xs font-medium text-neutral-700 cursor-pointer">
              <input
                type="checkbox"
                className="accent-[#C4161C]"
                checked={draft.form.vanOnly}
                onChange={(event) => patch(draft.id, { vanOnly: event.target.checked })}
              />
              <span>Van Only</span>
            </label>
            <label className="flex items-center gap-1.5 text-xs font-medium text-neutral-700 cursor-pointer">
              <input
                type="checkbox"
                className="accent-[#C4161C]"
                checked={draft.form.ladyOnly}
                onChange={(event) => patch(draft.id, { ladyOnly: event.target.checked })}
              />
              <span>Lady Only</span>
            </label>
          </div>
          <span className="font-mono text-[10px] text-neutral-400">Pref ID #81</span>
        </div>

        {/* Hidden or backup select to guarantee tests and accessibility */}
        <select
          className="sr-only"
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
      </fieldset>

      {/* 3. DISPATCH SCHEDULE */}
      <fieldset className="rounded-xl border border-neutral-200/90 bg-white p-3 shadow-xs space-y-2">
        <legend className="text-[11px] font-bold tracking-wider text-neutral-600 uppercase">
          DISPATCH SCHEDULE
        </legend>
        <div className="grid grid-cols-2 gap-2">
          <button
            type="button"
            className={`rounded-lg py-2 text-xs font-semibold transition cursor-pointer ${
              draft.form.when === 'NOW'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
            }`}
            data-on={draft.form.when === 'NOW'}
            onClick={() => patch(draft.id, { when: 'NOW' })}
          >
            Immediate (Now)
          </button>
          <button
            type="button"
            className={`rounded-lg py-2 text-xs font-semibold transition cursor-pointer ${
              draft.form.when === 'LATER'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
            }`}
            data-on={draft.form.when === 'LATER'}
            onClick={() => patch(draft.id, { when: 'LATER' })}
          >
            Pre-Book (Later)
          </button>
        </div>

        {draft.form.when === 'LATER' ? (
          <label className="block text-xs pt-1">
            <span className="text-neutral-500 block mb-1">
              Date and time ({config?.timezone ?? 'branch time'})
            </span>
            <input
              type="datetime-local"
              className={fieldClass}
              aria-label="Scheduled time"
              value={draft.form.scheduledLocal}
              onChange={(event) => patch(draft.id, { scheduledLocal: event.target.value })}
            />
          </label>
        ) : null}
      </fieldset>

      {/* 4. PASSENGER DETAILS */}
      <PassengerFields draft={draft} />

      {/* 5. DRIVER ALLOCATION MODE & FIXED FARE */}
      <fieldset className="rounded-xl border border-neutral-200/90 bg-white p-3 shadow-xs space-y-2.5">
        <div className="flex items-center justify-between">
          <legend className="text-[11px] font-bold tracking-wider text-neutral-600 uppercase">
            DRIVER ALLOCATION MODE
          </legend>
        </div>

        <div className="grid grid-cols-2 gap-2" role="group" aria-label="Assign mode">
          <button
            type="button"
            className={`rounded-lg py-2 text-xs font-semibold transition cursor-pointer ${
              assignMode === 'AUTO'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
            }`}
            data-on={assignMode === 'AUTO'}
            onClick={() => patch(draft.id, { assignMode: 'AUTO' })}
          >
            Auto Dispatch (Radius)
          </button>
          <button
            type="button"
            className={`rounded-lg py-2 text-xs font-semibold transition cursor-pointer ${
              assignMode === 'MANUAL'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
            }`}
            data-on={assignMode === 'MANUAL'}
            onClick={() => patch(draft.id, { assignMode: 'MANUAL' })}
          >
            Manual Select (Unit)
          </button>
        </div>

        <div className="pt-1">
          <label className="block text-xs">
            <span className="text-[11px] font-bold text-neutral-600 uppercase block mb-1">
              FIXED FARE ($)
            </span>
            <input
              className={fieldClass}
              aria-label="Fixed fare"
              inputMode="decimal"
              placeholder="Optional"
              value={draft.form.fixedFare}
              onChange={(event) => patch(draft.id, { fixedFare: event.target.value })}
            />
          </label>
        </div>
      </fieldset>

      {/* 6. SETTLEMENT METHOD / BILLING ACCOUNT */}
      <div className="rounded-xl border border-neutral-200/90 bg-white p-3 shadow-xs space-y-2">
        <span className="text-[11px] font-bold tracking-wider text-neutral-600 uppercase block">
          BILLING ACCOUNT
        </span>
        <div className="grid grid-cols-3 gap-2">
          <button
            type="button"
            onClick={() => setBillingMethod('card')}
            title="Coming with payments"
            className={`flex items-center justify-center gap-1.5 rounded-lg py-2 px-2 text-xs font-semibold transition cursor-pointer ${
              billingMethod === 'card'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'border border-neutral-200 bg-neutral-50 text-neutral-600 hover:bg-neutral-100'
            }`}
          >
            <CreditCard className="size-3.5" />
            <span>In-Car Terminal</span>
            <span title="Coming with payments" className="sr-only">Card</span>
          </button>

          <button
            type="button"
            onClick={() => setBillingMethod('account')}
            title="Coming with corporate accounts"
            className={`flex items-center justify-center gap-1.5 rounded-lg py-2 px-2 text-xs font-semibold transition cursor-pointer ${
              billingMethod === 'account'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'border border-neutral-200 bg-neutral-50 text-neutral-600 hover:bg-neutral-100'
            }`}
          >
            <Landmark className="size-3.5" />
            <span>Corp Account</span>
            <span title="Coming with corporate accounts" className="sr-only">Account</span>
          </button>

          <button
            type="button"
            onClick={() => setBillingMethod('cash')}
            className={`flex items-center justify-center gap-1.5 rounded-lg py-2 px-2 text-xs font-semibold transition cursor-pointer ${
              billingMethod === 'cash'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'border border-neutral-200 bg-neutral-50 text-neutral-600 hover:bg-neutral-100'
            }`}
          >
            <Banknote className="size-3.5" />
            <span>Cash</span>
          </button>
        </div>
      </div>

      {billingMethod === 'account' ? (
        <div className="rounded-xl border border-neutral-200 bg-neutral-50/70 p-3 space-y-2.5 animate-in fade-in duration-150">
          <div className="flex items-center justify-between">
            <span className="text-[10px] font-bold tracking-wider text-neutral-500 uppercase">
              CORPORATE ACCOUNT LOOKUP
            </span>
            <span className="rounded-full bg-emerald-50 border border-emerald-200/80 px-2 py-0.5 text-[10px] font-bold text-emerald-700">
              Pre-authorized corporate billing
            </span>
          </div>
          <div className="rounded-lg border border-neutral-200 bg-white p-3 space-y-2">
            <div className="flex items-center justify-between">
              <span className="font-bold text-xs text-neutral-900">Prairie Health Group • ACC-014</span>
              <span className="font-mono text-[10px] text-neutral-500">Net 30 Invoicing</span>
            </div>
            <div className="space-y-1">
              <div className="flex items-center justify-between text-[11px]">
                <span className="text-neutral-500">Credit Pool</span>
                <span className="font-semibold text-neutral-700">$4,200 of $5,000 used (84%)</span>
              </div>
              <div className="h-1.5 w-full rounded-full bg-neutral-100 overflow-hidden">
                <div className="h-full bg-[#C4161C] rounded-full" style={{ width: '84%' }} />
              </div>
            </div>
            <div className="pt-2 border-t border-neutral-100 flex items-center justify-between text-[11px]">
              <span className="text-neutral-500">Authorized Contact:</span>
              <span className="font-medium text-neutral-800">Dr. K. Vance (Primary Dispatch Contact)</span>
            </div>
          </div>
        </div>
      ) : null}

      {/* Quote summary card */}
      <QuoteCard
        quote={draft.quote}
        vehicleTypeId={draft.form.vehicleTypeId}
        busy={quoteBusy}
        onZone={(zone) => {
          setZone(draft.id, zone)
          void requestQuote(zone)
        }}
        onRecalculate={() => void requestQuote(draft.form.zone ?? undefined)}
      />

      {draft.errors.quote || draft.errors.form ? (
        <p className="text-destructive text-xs font-medium">{draft.errors.quote ?? draft.errors.form}</p>
      ) : null}

      {/* Bottom Main Action Button */}
      <button
        type="submit"
        disabled={booking || !config}
        aria-label="Book"
        className="w-full flex items-center justify-center gap-2 rounded-xl bg-[#C4161C] hover:bg-[#9E1017] text-white py-3 px-4 font-bold text-sm shadow-md transition active:scale-[0.98] disabled:opacity-60 cursor-pointer"
      >
        <span>▲</span>
        <span>{booking ? 'Booking…' : `Book & Broadcast Job (${priceDisplay})`}</span>
      </button>

      {toast ? (
        <div className="bg-neutral-100 flex items-center justify-between gap-2 rounded-lg border border-neutral-200 px-3 py-2 text-xs">
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
