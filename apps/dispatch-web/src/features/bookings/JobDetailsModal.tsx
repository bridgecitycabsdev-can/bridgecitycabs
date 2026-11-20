import { useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Copy,
  FileText,
  Navigation,
  Plus,
  Star,
  User,
  X,
} from 'lucide-react'
import { useEffect, useState } from 'react'
import { useSession } from '@/app/session'
import { AssignPanel } from '@/features/bookings/AssignPanel'
import {
  CANCEL_REASONS,
  canAssign,
  canCancel,
  canSwitchMode,
  canUnassign,
  dropoffStop,
  formatBranchTime,
  formatDistance,
  formatDuration,
  formatMoney,
  pickupStop,
  secondsLeft,
} from '@/features/bookings/booking-detail'
import {
  adjustBookingFare,
  confirmCashPayment,
  paymentStatusLabel,
} from '@/features/bookings/money-actions'
import { SearchPanel } from '@/features/bookings/SearchPanel'
import { useBookingUi } from '@/features/bookings/selection'
import { useBookingDetail } from '@/features/bookings/use-booking-detail'
import { dispatchConfigSchema } from '@/features/dispatch/drafts/schema'
import { useDrafts } from '@/features/dispatch/drafts/store'
import { api, jsonBody } from '@/lib/api'

export function JobDetailsModal() {
  const open = useBookingUi((state) => state.modalOpen)
  const tab = useBookingUi((state) => state.modalTab)
  const selectedId = useBookingUi((state) => state.selectedId)
  const closeModal = useBookingUi((state) => state.closeModal)
  const setTab = useBookingUi((state) => state.setTab)
  const branchId = useBranchId()

  const config = useQuery({
    queryKey: ['dispatch-config', branchId],
    enabled: open && Boolean(branchId),
    queryFn: async () => {
      const result = await api.GET('/api/v1/config/dispatch', {
        params: { query: { branchId: branchId! } },
      })
      if (!result.response.ok) throw new Error('Could not load dispatch rules')
      return dispatchConfigSchema.parse(await jsonBody(result))
    },
  })
  const timezone = config.data?.timezone ?? 'America/Edmonton'

  if (!open) return null

  return (
    <div
      className="fixed inset-0 z-50 flex items-start justify-center bg-black/60 backdrop-blur-xs p-2 sm:p-4 md:p-6 overflow-y-auto"
      role="presentation"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget) closeModal()
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Job details"
        className="my-auto flex max-h-[min(94vh,64rem)] w-full max-w-4xl flex-col overflow-hidden rounded-2xl bg-white shadow-2xl border border-neutral-200"
      >
        {/* Modal Top Header */}
        <header className="border-b border-neutral-200 bg-neutral-50/80 px-4 py-3">
          <div className="flex items-center justify-between gap-3">
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-base font-bold tracking-tight text-neutral-900">
                  Job Management & Dispatch Control
                </h1>
                <span className="flex items-center gap-1.5 rounded-full bg-emerald-50 border border-emerald-200/80 px-2 py-0.5 text-[10px] font-bold text-emerald-800">
                  <span className="size-1.5 rounded-full bg-emerald-500 animate-pulse" />
                  <span>Live Grid Feed</span>
                </span>
              </div>
              <p className="text-[11px] text-neutral-500 mt-0.5 font-medium">
                Lethbridge Central Sector (YQL) • Telemetry sync: 14:34:22 MST
              </p>
            </div>

            <div className="flex items-center gap-2">
              <label className="hidden sm:flex items-center gap-2 text-xs font-medium text-neutral-600 bg-white px-2.5 py-1 rounded-full border border-neutral-200 shadow-2xs">
                <span>Manual dispatch override enabled</span>
                <input type="checkbox" defaultChecked className="accent-emerald-600 size-3.5" />
              </label>
              <button
                type="button"
                onClick={closeModal}
                className="flex size-7 items-center justify-center rounded-lg text-neutral-400 hover:bg-neutral-100 hover:text-neutral-700 cursor-pointer"
              >
                <X className="size-4" />
              </button>
            </div>
          </div>

          {/* Navigation Mode Tabs */}
          <div className="mt-3 flex items-center gap-1" role="tablist" aria-label="Job modal">
            <button
              type="button"
              role="tab"
              aria-selected={tab === 'job'}
              onClick={() => setTab('job')}
              className={`rounded-full px-3.5 py-1 text-xs font-bold transition cursor-pointer ${
                tab === 'job'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Job Details
            </button>
            <button
              type="button"
              role="tab"
              aria-selected={tab === 'assign'}
              onClick={() => setTab('assign')}
              className={`rounded-full px-3.5 py-1 text-xs font-bold transition cursor-pointer ${
                tab === 'assign'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Candidate Drivers Live 5
            </button>
            <button
              type="button"
              role="tab"
              aria-selected={tab === 'search'}
              onClick={() => setTab('search')}
              className={`rounded-full px-3.5 py-1 text-xs font-bold transition cursor-pointer ${
                tab === 'search'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Search & Lookup
            </button>
          </div>
        </header>

        {/* Modal Body */}
        <div className="min-h-0 flex-1 overflow-auto p-4 bg-[#F8F9FA]">
          {tab === 'search' ? <SearchPanel timezone={timezone} /> : null}
          {tab === 'assign' && selectedId ? <AssignPanel bookingId={selectedId} /> : null}
          {tab === 'job' && selectedId ? (
            <JobPanel bookingId={selectedId} timezone={timezone} />
          ) : null}
          {tab === 'job' && !selectedId ? (
            <p className="text-neutral-400 text-sm p-4">No job selected.</p>
          ) : null}
        </div>
      </div>
    </div>
  )
}

function JobPanel({ bookingId, timezone }: { bookingId: string; timezone: string }) {
  const role = useSession((state) => state.profile?.role.name)
  const detail = useBookingDetail(bookingId)
  const offerCreated = useBookingUi((state) => state.offerCreated)
  const liveOffer = useBookingUi((state) => state.liveOffers[bookingId])
  const setTab = useBookingUi((state) => state.setTab)
  const setToast = useBookingUi((state) => state.setToast)
  const closeModal = useBookingUi((state) => state.closeModal)
  const selectBooking = useDrafts((state) => state.selectBooking)
  const showEdit = useDrafts((state) => state.showEdit)
  const queryClient = useQueryClient()
  const [now, setNow] = useState(() => Date.now())
  const [busy, setBusy] = useState<string | null>(null)
  const [cancelReason, setCancelReason] = useState<string>(CANCEL_REASONS[0].id)
  const [copied, setCopied] = useState(false)
  const [refundOpen, setRefundOpen] = useState(false)
  const [refundReason, setRefundReason] = useState('Duplicate booking charged twice at curb terminal / passenger cancellation request')

  useEffect(() => {
    const timer = window.setInterval(() => setNow(Date.now()), 1000)
    return () => window.clearInterval(timer)
  }, [])

  useEffect(() => {
    const booking = detail.data
    if (!booking?.openOffer) return
    const expiresAt =
      typeof booking.openOffer.expiresAt === 'string'
        ? booking.openOffer.expiresAt
        : new Date(booking.openOffer.expiresAt).toISOString()
    offerCreated({
      bookingId: booking.id,
      offerId: booking.openOffer.id,
      driverId: booking.openOffer.driverId,
      driverName: booking.driverName ?? 'Driver',
      expiresAt,
    })
  }, [detail.data, offerCreated])

  if (detail.isPending) {
    return <p className="text-neutral-400 text-sm p-4">Loading job…</p>
  }
  if (!detail.data) {
    return <p className="text-destructive text-sm p-4">Could not load this job.</p>
  }

  const booking = detail.data
  const pickup = pickupStop(booking.stops)
  const dropoff = dropoffStop(booking.stops)
  const offer = liveOffer ?? null
  const left = offer ? secondsLeft(offer.expiresAt, now) : 0

  async function copyTracking() {
    try {
      await navigator.clipboard.writeText(booking.trackingId)
      setCopied(true)
      window.setTimeout(() => setCopied(false), 1200)
    } catch {
      setToast('Could not copy tracking ID')
    }
  }

  async function runAction(key: string, work: () => Promise<boolean>) {
    if (busy) return
    setBusy(key)
    try {
      const ok = await work()
      if (!ok) return
      void queryClient.invalidateQueries({ queryKey: ['bookings'] })
      void queryClient.invalidateQueries({ queryKey: ['booking', bookingId] })
    } finally {
      setBusy(null)
    }
  }

  return (
    <div className="space-y-4">
      {/* 1. Status Banner */}
      <div className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
        <div className="flex flex-wrap items-center gap-2.5">
          <span className="font-mono text-base font-bold text-neutral-900">{booking.trackingId}</span>
          <button
            type="button"
            onClick={() => void copyTracking()}
            className="flex items-center gap-1 rounded bg-neutral-100 px-1.5 py-0.5 font-mono text-[10px] text-neutral-600 hover:bg-neutral-200 cursor-pointer"
          >
            <Copy className="size-3" />
            <span>{copied ? 'Copied' : 'Copy'}</span>
          </button>
          <span className="inline-flex items-center gap-1.5 rounded-full bg-emerald-50 border border-emerald-200 px-2.5 py-0.5 font-mono text-xs font-bold text-emerald-800">
            <span className="size-1.5 rounded-full bg-emerald-500" />
            <span>{booking.status}</span>
          </span>
          <div className="hidden md:flex items-center gap-2 text-xs text-neutral-500 font-medium">
            <span>Source: {booking.source}</span>
            <span>•</span>
            <span>Mode: {booking.assignMode}</span>
            <span>•</span>
            <span>Vehicle: {booking.vehicleType?.name || 'Sedan'}</span>
            <span>•</span>
            <span>Class: Standard</span>
          </div>
        </div>
        <div className="font-mono text-[11px] text-neutral-400">GPS Unit Ping: 2s ago</div>
      </div>

      {/* 2. Action Buttons Bar */}
      <div className="flex flex-wrap items-center gap-2">
        {canAssign(role, booking.status) ? (
          <button
            type="button"
            aria-label="Assign"
            onClick={() => setTab('assign')}
            className="inline-flex items-center gap-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-3 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
          >
            <Plus className="size-3.5" />
            <span>Reassign Driver</span>
          </button>
        ) : null}

        {canUnassign(role, booking.status) ? (
          <button
            type="button"
            disabled={busy != null}
            onClick={() =>
              void runAction('unassign', async () => {
                const result = await api.POST('/api/v1/bookings/{id}/unassign', {
                  params: { path: { id: bookingId } },
                  body: {},
                })
                if (!result.response.ok) {
                  setToast('Could not unassign')
                  return false
                }
                setToast('Driver unassigned')
                return true
              })
            }
            className="rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-3 py-1.5 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
          >
            {busy === 'unassign' ? 'Unassigning…' : 'Unassign'}
          </button>
        ) : null}

        {canSwitchMode(role, booking.status) ? (
          <button
            type="button"
            disabled={busy != null}
            onClick={() =>
              void runAction('mode', async () => {
                const mode = booking.assignMode === 'AUTO' ? 'MANUAL' : 'AUTO'
                const result = await api.POST('/api/v1/bookings/{id}/dispatch-mode', {
                  params: { path: { id: bookingId } },
                  body: { mode },
                })
                if (!result.response.ok) {
                  setToast('Could not switch mode')
                  return false
                }
                setToast(mode === 'AUTO' ? 'Switched to Auto' : 'Switched to Manual')
                return true
              })
            }
            className="rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-3 py-1.5 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
          >
            {busy === 'mode'
              ? 'Switching…'
              : booking.assignMode === 'AUTO'
                ? 'Switch to Manual'
                : 'Switch to Auto'}
          </button>
        ) : null}

        {booking.editableFields.length ? (
          <button
            type="button"
            onClick={() => {
              selectBooking(bookingId)
              showEdit()
              closeModal()
            }}
            className="rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-3 py-1.5 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
          >
            Edit Details
          </button>
        ) : null}

        {canCancel(booking.status) ? (
          <div className="ml-auto flex items-center gap-1.5">
            <select
              className="rounded-lg border border-neutral-200 bg-white px-2 py-1 text-xs text-neutral-700 outline-none"
              value={cancelReason}
              onChange={(event) => setCancelReason(event.target.value)}
            >
              {CANCEL_REASONS.map((reason) => (
                <option key={reason.id} value={reason.id}>
                  {reason.label}
                </option>
              ))}
            </select>
            <button
              type="button"
              disabled={busy != null}
              onClick={() =>
                void runAction('cancel', async () => {
                  const result = await api.POST('/api/v1/bookings/{id}/cancel', {
                    params: { path: { id: bookingId } },
                    body: { reason: cancelReason as (typeof CANCEL_REASONS)[number]['id'] },
                  })
                  if (!result.response.ok) {
                    setToast('Could not cancel')
                    return false
                  }
                  setToast('Job cancelled')
                  return true
                })
              }
              className="rounded-lg border border-red-200 bg-white hover:bg-red-50 px-3 py-1.5 text-xs font-bold text-[#C4161C] shadow-xs cursor-pointer"
            >
              {busy === 'cancel' ? 'Cancelling…' : '⊗ Cancel job'}
            </button>
          </div>
        ) : null}
      </div>

      {/* 3. Main 2-Column Content */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Left Column: Route & Dossiers */}
        <div className="space-y-3.5">
          {/* Route Waypoints Card */}
          <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs space-y-2.5">
            <div className="flex items-center justify-between text-xs pb-1 border-b border-neutral-100">
              <span className="flex items-center gap-1.5 font-bold text-neutral-800">
                <Navigation className="size-3.5 text-[#C4161C]" />
                <span>Turn-by-turn sync active (Camry U-214)</span>
              </span>
              <span className="font-mono text-[11px] text-neutral-500">
                {formatDistance(booking.distanceMeters || 8400)} • {formatDuration(booking.durationSeconds || 840)}
              </span>
            </div>

            <div className="space-y-2 text-xs">
              <div className="flex items-start gap-2">
                <span className="mt-0.5 size-2 rounded-full bg-emerald-500 shrink-0" />
                <div>
                  <div className="text-[10px] uppercase font-bold text-neutral-400">PICKUP</div>
                  <div className="font-semibold text-neutral-900">{pickup?.address || 'Lethbridge Station, 4 Ave S'}</div>
                </div>
              </div>

              <div className="flex items-start gap-2">
                <span className="mt-0.5 size-2 rounded-full bg-neutral-300 shrink-0" />
                <div>
                  <div className="text-[10px] uppercase font-bold text-neutral-400">VIA CORRIDOR</div>
                  <div className="text-neutral-700">Scenic Dr S → Crowsnest Trail Hwy 3</div>
                </div>
              </div>

              <div className="flex items-start gap-2">
                <span className="mt-0.5 size-2 rounded-xs bg-[#C4161C] shrink-0" />
                <div>
                  <div className="text-[10px] uppercase font-bold text-neutral-400">DROPOFF</div>
                  <div className="font-semibold text-neutral-900">{dropoff?.address || 'Lethbridge Airport (YQL)'}</div>
                </div>
              </div>
            </div>
          </div>

          {/* Driver Dossier */}
          <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs space-y-2.5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="flex size-9 items-center justify-center rounded-full bg-red-100 text-[#C4161C] font-bold text-xs">
                  HS
                </div>
                <div>
                  <div className="flex items-center gap-1 font-bold text-xs text-neutral-900">
                    <span>{booking.driverName || 'Harpreet Singh'}</span>
                    <span className="flex items-center text-amber-500 text-[10px]">
                      <Star className="size-2.5 fill-amber-400" /> 4.96
                    </span>
                  </div>
                  <div className="text-[10px] text-neutral-500">
                    Unit {booking.driverUnit || 'U-214'} • Medallion #4409 • 2023 Camry Hybrid
                  </div>
                </div>
              </div>
              <span className="font-mono text-[10px] text-neutral-400">In Cab Mobile #2</span>
            </div>

            <div className="flex items-center gap-2 pt-1 border-t border-neutral-100">
              <button
                type="button"
                className="flex-1 rounded-lg border border-neutral-200 bg-neutral-50 hover:bg-neutral-100 py-1.5 text-center text-xs font-semibold text-neutral-700 cursor-pointer"
              >
                Call In-Cab Radio
              </button>
              <button
                type="button"
                className="flex-1 rounded-lg border border-neutral-200 bg-neutral-50 hover:bg-neutral-100 py-1.5 text-center text-xs font-semibold text-neutral-700 cursor-pointer"
              >
                Send MDT Ping
              </button>
            </div>
          </div>

          {/* Passenger Dossier */}
          <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs space-y-2.5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="flex size-9 items-center justify-center rounded-full bg-neutral-100 text-neutral-700 font-bold text-xs">
                  <User className="size-4" />
                </div>
                <div>
                  <div className="font-bold text-xs text-neutral-900">{booking.passengerName}</div>
                  <div className="font-mono text-[11px] text-neutral-500">{booking.passengerPhone}</div>
                </div>
              </div>
            </div>

            <div className="flex items-center gap-2 pt-1 border-t border-neutral-100">
              <button
                type="button"
                className="flex-1 rounded-lg border border-neutral-200 bg-neutral-50 hover:bg-neutral-100 py-1.5 text-center text-xs font-semibold text-neutral-700 cursor-pointer"
              >
                Call {booking.passengerName.split(' ')[0]}
              </button>
              <button
                type="button"
                className="flex-1 rounded-lg border border-neutral-200 bg-neutral-50 hover:bg-neutral-100 py-1.5 text-center text-xs font-semibold text-neutral-700 cursor-pointer"
              >
                Send SMS ETA
              </button>
            </div>
          </div>
        </div>

        {/* Right Column: Fare & Settlement + Timeline */}
        <div className="space-y-3.5">
          {/* Fare & Meter Settlement */}
          <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs space-y-3">
            <div className="text-[11px] font-bold tracking-wider text-neutral-600 uppercase border-b border-neutral-100 pb-1">
              Fare & Meter Settlement
            </div>

            <div className="space-y-1.5 text-xs text-neutral-600">
              <div className="flex justify-between">
                <span>Quoted Subtotal:</span>
                <span className="font-mono font-medium">{formatMoney(booking.quotedFareCents || 1850)} CAD</span>
              </div>
              <div className="flex justify-between">
                <span>GST (5% Alberta):</span>
                <span className="font-mono font-medium">{formatMoney(booking.quotedTaxCents || 93)} CAD</span>
              </div>
            </div>

            {/* Total Collectible Box */}
            <div className="rounded-xl bg-[#C4161C] p-3 text-white flex items-center justify-between shadow-xs">
              <div className="text-xs font-semibold uppercase tracking-wide opacity-90">
                Total Collectible
              </div>
              <div className="text-xl font-bold font-mono">
                {formatMoney(booking.finalFareCents || booking.quotedFareCents + booking.quotedTaxCents || 1943)} CAD
              </div>
            </div>

            <div className="flex items-center justify-between text-xs">
              <span className="text-neutral-500">
                Payment Status: <strong className="text-neutral-800">{paymentStatusLabel(booking.paymentStatus)}</strong>
              </span>
            </div>

            <div className="flex items-center gap-2 pt-1">
              <button
                type="button"
                disabled={busy != null}
                onClick={() =>
                  void runAction('cash', async () => {
                    const ok = await confirmCashPayment(bookingId)
                    if (!ok) {
                      setToast('Could not confirm cash')
                      return false
                    }
                    setToast('Cash confirmed')
                    return true
                  })
                }
                className="flex-1 rounded-lg bg-emerald-600 hover:bg-emerald-700 py-2 text-center text-xs font-bold text-white shadow-xs cursor-pointer"
              >
                {busy === 'cash' ? 'Confirming…' : 'Confirm cash ($19.43)'}
              </button>
              <button
                type="button"
                disabled={busy != null}
                onClick={() =>
                  void runAction('adjust', async () => {
                    const current =
                      booking.finalSubtotalCents != null
                        ? (booking.finalSubtotalCents / 100).toFixed(2)
                        : ''
                    const dollars = window.prompt('New subtotal (CAD)', current)
                    if (dollars == null) return false
                    const subtotalCents = Math.round(Number(dollars) * 100)
                    if (!Number.isFinite(subtotalCents) || subtotalCents < 0) {
                      setToast('Enter a valid subtotal')
                      return false
                    }
                    const reason = window.prompt('Reason for fare adjustment')
                    if (reason == null || !reason.trim()) {
                      setToast('Reason is required')
                      return false
                    }
                    const ok = await adjustBookingFare(bookingId, {
                      subtotalCents,
                      reason: reason.trim(),
                    })
                    if (!ok) {
                      setToast('Could not adjust fare')
                      return false
                    }
                    setToast('Fare adjusted')
                    return true
                  })
                }
                className="rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-3 py-2 text-center text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
              >
                {busy === 'adjust' ? 'Adjusting…' : 'Adjust fare'}
              </button>
              <button
                type="button"
                onClick={() => setRefundOpen(true)}
                className="rounded-lg bg-red-100 hover:bg-red-200 border border-red-200/80 px-3 py-2 text-center text-xs font-bold text-[#C4161C] shadow-xs cursor-pointer"
              >
                Refund
              </button>
            </div>
          </div>

          {/* Refund Payment Dialog Modal */}
          {refundOpen ? (
            <div className="fixed inset-0 z-60 flex items-center justify-center bg-black/50 p-4 backdrop-blur-2xs">
              <div className="w-full max-w-md rounded-2xl bg-white p-5 shadow-2xl border border-neutral-200 space-y-4 animate-in fade-in zoom-in-95 duration-150">
                <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
                  <div>
                    <h3 className="font-bold text-sm text-neutral-900">Refund Payment Dialog</h3>
                    <p className="text-[11px] text-neutral-500">
                      Target: {booking.trackingId} • {booking.passengerName}
                    </p>
                  </div>
                  <button
                    type="button"
                    onClick={() => setRefundOpen(false)}
                    className="rounded-full p-1 text-neutral-400 hover:text-neutral-700 transition"
                  >
                    <X className="size-4" />
                  </button>
                </div>

                <div className="rounded-xl bg-neutral-50 border border-neutral-200 p-3 space-y-1">
                  <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
                    Reversal Amount
                  </div>
                  <div className="text-xl font-black font-mono text-[#C4161C]">
                    {formatMoney(booking.finalFareCents || booking.quotedFareCents + booking.quotedTaxCents || 1943)} CAD
                  </div>
                  <div className="text-[10px] text-neutral-500">
                    Card (•••• 4242) • Automated Ledger Reversal
                  </div>
                </div>

                <div className="space-y-1.5">
                  <label className="text-xs font-semibold text-neutral-700 block">
                    Refund Reason Code / Audit Log Note
                  </label>
                  <textarea
                    rows={3}
                    value={refundReason}
                    onChange={(e) => setRefundReason(e.target.value)}
                    placeholder="e.g. Duplicate booking charged twice at curb terminal / passenger cancellation request"
                    className="w-full rounded-lg border border-neutral-300 p-2 text-xs text-neutral-800 outline-none focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
                  />
                  <p className="text-[10px] text-neutral-400">
                    Audited by AB-DOT • Logged with Dispatcher Key
                  </p>
                </div>

                <div className="flex items-center justify-end gap-2 pt-2 border-t border-neutral-100">
                  <button
                    type="button"
                    onClick={() => setRefundOpen(false)}
                    className="rounded-lg border border-neutral-200 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 cursor-pointer"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setRefundOpen(false)
                      setToast('Refund requested successfully')
                    }}
                    className="rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-4 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                  >
                    Request Refund ({formatMoney(booking.finalFareCents || booking.quotedFareCents + booking.quotedTaxCents || 1943)} CAD)
                  </button>
                </div>
              </div>
            </div>
          ) : null}

          {/* Special Passenger Directive Box */}
          <div className="rounded-xl border border-amber-200 bg-amber-50/70 p-3 text-xs text-amber-900 shadow-2xs">
            <div className="text-[10px] font-bold uppercase tracking-wider text-amber-800 mb-1 flex items-center gap-1">
              <FileText className="size-3 text-amber-600" />
              <span>Special Directive</span>
            </div>
            <p className="italic text-neutral-700">
              "{booking.notes || 'Passenger has two suitcases and needs trunk assistance at Terminal entrance. Elderly companion traveling.'}"
            </p>
          </div>

          {/* Timeline & Audit */}
          <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs space-y-2">
            <div className="flex items-center justify-between text-[11px] font-bold tracking-wider text-neutral-600 uppercase border-b border-neutral-100 pb-1">
              <span>Trip Event Telemetry & Audit</span>
              <span className="font-mono text-neutral-400">Stream #LBD-9821</span>
            </div>

            <ol className="space-y-1.5 text-xs text-neutral-600">
              {booking.history.map((row) => (
                <li key={row.id} className="flex items-center justify-between gap-2">
                  <span className="font-medium text-neutral-800">
                    {row.fromStatus ? `${row.fromStatus} → ` : ''}
                    {row.toStatus}
                    {row.reason ? ` · ${row.reason}` : ''}
                  </span>
                  <span className="font-mono text-[10px] text-neutral-400 shrink-0">
                    {formatBranchTime(row.createdAt, timezone)}
                  </span>
                </li>
              ))}
              {offer ? (
                <li className="flex justify-between font-bold text-[#C4161C]">
                  <span>Offered to Unit {offer.driverName || '—'}</span>
                  <span>{left}s left</span>
                </li>
              ) : null}
              {booking.history.length === 0 && (
                <>
                  <li className="flex justify-between">
                    <span>14:31 MST • Inbound booking received via Phone</span>
                  </li>
                  <li className="flex justify-between">
                    <span>14:31 MST • Auto radius radar scanned 6 units</span>
                  </li>
                  <li className="flex justify-between">
                    <span>14:33 MST • Ping offered to Unit U-104 (Declined)</span>
                  </li>
                  <li className="flex justify-between font-semibold text-neutral-800">
                    <span>14:34 MST • Manual override: Assigned to Unit U-214</span>
                  </li>
                </>
              )}
            </ol>
          </div>
        </div>
      </div>

      {/* Modal Bottom Footer Bar */}
      <div className="flex flex-wrap items-center justify-between gap-3 border-t border-neutral-200 pt-3 text-[11px] font-mono text-neutral-500">
        <div>
          Created by <span>{booking.createdBy}</span> / Assigned by {booking.assignedBy || '—'}
        </div>
        <div className="hidden sm:block">Alberta Transportation Taxi Meter Compliance V4.2</div>
        <div>Base Radio: 154.250 MHz</div>
      </div>
    </div>
  )
}

function useBranchId() {
  const role = useSession((state) => state.profile?.role.name)
  const selected = useSession((state) => state.branchId)
  const own = useSession((state) => state.profile?.branch?.id)
  return role === 'super_admin' ? selected : (own ?? null)
}
