import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useEffect, useState, type ReactNode } from 'react'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import { AssignPanel } from '@/features/bookings/AssignPanel'
import {
  CANCEL_REASONS,
  canAdjustFare,
  canAssign,
  canCancel,
  canConfirmCash,
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
      className="fixed inset-0 z-50 flex items-start justify-center bg-black/40 p-3 sm:p-6"
      role="presentation"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget) closeModal()
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Job details"
        className="bg-card flex max-h-[min(92vh,56rem)] w-full max-w-3xl flex-col overflow-hidden rounded-lg border shadow-lg"
      >
        <header className="flex items-center justify-between gap-2 border-b px-3 py-2">
          <div className="flex flex-wrap gap-1" role="tablist" aria-label="Job modal">
            <TabButton active={tab === 'job'} onClick={() => setTab('job')}>
              Job
            </TabButton>
            <TabButton active={tab === 'search'} onClick={() => setTab('search')}>
              Search
            </TabButton>
            {tab === 'assign' ? (
              <TabButton active onClick={() => setTab('assign')}>
                Assign
              </TabButton>
            ) : null}
          </div>
          <Button type="button" size="xs" variant="ghost" onClick={closeModal}>
            Close
          </Button>
        </header>
        <div className="min-h-0 flex-1 overflow-auto p-3">
          {tab === 'search' ? <SearchPanel timezone={timezone} /> : null}
          {tab === 'assign' && selectedId ? <AssignPanel bookingId={selectedId} /> : null}
          {tab === 'job' && selectedId ? (
            <JobPanel bookingId={selectedId} timezone={timezone} />
          ) : null}
          {tab === 'job' && !selectedId ? (
            <p className="text-muted-foreground text-sm">No job selected.</p>
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
    return <p className="text-muted-foreground text-sm">Loading job…</p>
  }
  if (!detail.data) {
    return <p className="text-destructive text-sm">Could not load this job.</p>
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
      <div className="flex flex-wrap items-start justify-between gap-2">
        <div>
          <div className="flex flex-wrap items-center gap-2">
            <h2 className="text-base font-semibold">{booking.trackingId}</h2>
            <Button type="button" size="xs" variant="outline" onClick={() => void copyTracking()}>
              {copied ? 'Copied' : 'Copy'}
            </Button>
            <StatusBadge status={booking.status} />
            <span className="text-muted-foreground text-xs">{booking.source}</span>
          </div>
          <p className="text-muted-foreground mt-1 text-xs">
            Mode {booking.assignMode}
            {booking.vehicleType?.name ? ` · ${booking.vehicleType.name}` : ''}
          </p>
        </div>
        <div className="flex flex-wrap gap-1.5">
          {canAssign(role, booking.status) ? (
            <Button type="button" size="sm" onClick={() => setTab('assign')}>
              Assign
            </Button>
          ) : null}
          {canUnassign(role, booking.status) ? (
            <Button
              type="button"
              size="sm"
              variant="outline"
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
            >
              {busy === 'unassign' ? 'Unassigning…' : 'Unassign'}
            </Button>
          ) : null}
          {canSwitchMode(role, booking.status) ? (
            <Button
              type="button"
              size="sm"
              variant="outline"
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
            >
              {busy === 'mode'
                ? 'Switching…'
                : booking.assignMode === 'AUTO'
                  ? 'Switch to Manual'
                  : 'Switch to Auto'}
            </Button>
          ) : null}
          {booking.editableFields.length ? (
            <Button
              type="button"
              size="sm"
              variant="outline"
              onClick={() => {
                selectBooking(bookingId)
                showEdit()
                closeModal()
              }}
            >
              Edit
            </Button>
          ) : null}
        </div>
      </div>

      <dl className="grid gap-2 sm:grid-cols-2">
        <Cell label="Vehicle unit" value={booking.driverUnit || '—'} />
        <Cell label="Driver" value={booking.driverName || '—'} />
        <Cell label="Passenger" value={booking.passengerName} />
        <Cell label="Phone" value={booking.passengerPhone} />
        <Cell label="Account" value="—" />
        <Cell
          label="Date & time"
          value={formatBranchTime(booking.scheduledAt ?? booking.createdAt, timezone)}
        />
        <Cell label="When" value={booking.scheduledAt ? 'Scheduled' : 'ASAP'} />
        <Cell label="Distance" value={formatDistance(booking.distanceMeters)} />
        <Cell label="Duration" value={formatDuration(booking.durationSeconds)} />
        <Cell label="From" value={pickup?.address ?? '—'} />
        <Cell label="To" value={dropoff?.address ?? '—'} />
      </dl>

      <section className="space-y-2">
        <h3 className="text-sm font-semibold">Money</h3>
        <div className="grid gap-2 sm:grid-cols-3">
          <Money
            label="Quoted"
            value={formatMoney(booking.quotedFareCents + booking.quotedTaxCents)}
          />
          <Money
            label="Fixed"
            value={booking.fixedFareCents != null ? formatMoney(booking.fixedFareCents) : '—'}
          />
          <Money label="Payment" value={paymentStatusLabel(booking.paymentStatus)} />
        </div>
        <div className="grid gap-2 sm:grid-cols-3">
          <Money label="Subtotal" value={formatMoney(booking.finalSubtotalCents)} />
          <Money label="GST" value={formatMoney(booking.finalTaxCents)} />
          <Money label="Total" value={formatMoney(booking.finalFareCents)} />
        </div>
        {booking.status === 'PAYMENT_PENDING' ? (
          <div className="flex flex-wrap gap-1.5 pt-1">
            {canConfirmCash(role, booking.status) ? (
              <Button
                type="button"
                size="sm"
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
              >
                {busy === 'cash' ? 'Confirming…' : 'Confirm cash'}
              </Button>
            ) : null}
            {canAdjustFare(role, booking.status) ? (
              <Button
                type="button"
                size="sm"
                variant="outline"
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
              >
                {busy === 'adjust' ? 'Adjusting…' : 'Adjust fare'}
              </Button>
            ) : null}
          </div>
        ) : null}
      </section>

      <section className="grid gap-2 sm:grid-cols-2">
        <Cell label="Created by" value={booking.createdBy} />
        <Cell label="Assigned by" value={booking.assignedBy || '—'} />
      </section>

      {canCancel(booking.status) ? (
        <div className="flex flex-wrap items-end gap-2 border-t pt-3">
          <label className="block text-xs">
            <span className="text-muted-foreground">Cancel reason</span>
            <select
              className="border-input bg-background mt-0.5 h-8 rounded-md border px-2 text-sm"
              value={cancelReason}
              onChange={(event) => setCancelReason(event.target.value)}
            >
              {CANCEL_REASONS.map((reason) => (
                <option key={reason.id} value={reason.id}>
                  {reason.label}
                </option>
              ))}
            </select>
          </label>
          <Button
            type="button"
            size="sm"
            variant="destructive"
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
          >
            {busy === 'cancel' ? 'Cancelling…' : 'Cancel'}
          </Button>
        </div>
      ) : null}

      <section>
        <h3 className="mb-2 text-sm font-semibold">Timeline</h3>
        <ol className="space-y-1.5 text-sm">
          {booking.history.map((row) => (
            <li key={row.id} className="flex justify-between gap-3 border-b border-dashed py-1.5 last:border-0">
              <span>
                {row.fromStatus ? `${row.fromStatus} → ` : ''}
                {row.toStatus}
                {row.reason ? ` · ${row.reason}` : ''}
              </span>
              <span className="text-muted-foreground shrink-0 text-xs">
                {formatBranchTime(row.createdAt, timezone)}
              </span>
            </li>
          ))}
          {offer ? (
            <li className="text-primary font-medium">
              Offered to Unit {offer.unit || '—'}, {left}s left
            </li>
          ) : null}
          {booking.history.length === 0 && !offer ? (
            <li className="text-muted-foreground">No status history yet.</li>
          ) : null}
        </ol>
      </section>

      {booking.notes ? (
        <p className="text-muted-foreground text-sm">
          <span className="font-medium text-foreground">Notes: </span>
          {booking.notes}
        </p>
      ) : null}
    </div>
  )
}

function TabButton({
  active,
  onClick,
  children,
}: {
  active: boolean
  onClick: () => void
  children: ReactNode
}) {
  return (
    <button
      type="button"
      role="tab"
      aria-selected={active}
      className="rounded-md px-2 py-1 text-xs data-[on=true]:bg-primary data-[on=true]:text-primary-foreground"
      data-on={active}
      onClick={onClick}
    >
      {children}
    </button>
  )
}

function StatusBadge({ status }: { status: string }) {
  return (
    <span className="bg-muted inline-flex rounded-md px-1.5 py-0.5 text-xs font-medium">
      {status}
    </span>
  )
}

function Cell({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-md border px-2.5 py-2">
      <dt className="text-muted-foreground text-xs">{label}</dt>
      <dd className="text-sm font-medium wrap-break-word">{value}</dd>
    </div>
  )
}

function Money({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-md border px-2.5 py-2">
      <p className="text-muted-foreground text-xs">{label}</p>
      <p className="text-sm font-semibold">{value}</p>
    </div>
  )
}

function useBranchId() {
  const role = useSession((state) => state.profile?.role.name)
  const selected = useSession((state) => state.branchId)
  const own = useSession((state) => state.profile?.branch?.id)
  return role === 'super_admin' ? selected : (own ?? null)
}
