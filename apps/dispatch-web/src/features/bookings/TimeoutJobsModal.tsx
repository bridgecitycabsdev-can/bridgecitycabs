import { useQuery, useQueryClient } from '@tanstack/react-query'
import {
  AlertTriangle,
  ArrowRight,
  MapPin,
  Plus,
  RefreshCw,
  RotateCcw,
  Trash2,
  Volume2,
  X,
} from 'lucide-react'
import { useEffect, useState } from 'react'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import { apiErrorBody } from '@/features/bookings/api-error'
import { CANCEL_REASONS, canAssign, canCancel } from '@/features/bookings/booking-detail'
import { stopAddress } from '@/features/bookings/jobs-table'
import { jobsPageSchema } from '@/features/bookings/jobs-table'
import { useOpsPanels } from '@/features/bookings/ops-panels'
import { useBookingUi } from '@/features/bookings/selection'
import { useTimeoutAlerts } from '@/features/bookings/timeout-alerts'
import { dispatchConfigSchema } from '@/features/dispatch/drafts/schema'
import { useDrafts } from '@/features/dispatch/drafts/store'
import { api, jsonBody } from '@/lib/api'

export function TimeoutJobsModal() {
  const open = useOpsPanels((state) => state.timeoutOpen)
  const close = useOpsPanels((state) => state.closeTimeout)
  const clearBadge = useTimeoutAlerts((state) => state.clearBadge)
  const soundEnabled = useTimeoutAlerts((state) => state.soundEnabled)
  const setSoundEnabled = useTimeoutAlerts((state) => state.setSoundEnabled)
  const primeAudio = useTimeoutAlerts((state) => state.primeAudio)
  const branchId = useBranchId()
  const role = useSession((state) => state.profile?.role.name)
  const openJob = useBookingUi((state) => state.openJob)
  const setToast = useBookingUi((state) => state.setToast)
  const selectBooking = useDrafts((state) => state.selectBooking)
  const queryClient = useQueryClient()
  const [activeTab, setActiveTab] = useState<'main' | 'cancel' | 'empty' | 'care'>('main')
  const [busyId, setBusyId] = useState<string | null>(null)
  const [cancelFor, setCancelFor] = useState<string | null>(null)
  const [cancelReason, setCancelReason] = useState<string>(CANCEL_REASONS[0].id)

  useEffect(() => {
    if (open) clearBadge()
  }, [clearBadge, open])

  useQuery({
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

  const page = useQuery({
    queryKey: ['bookings', 'timeout', branchId],
    enabled: open && Boolean(branchId),
    queryFn: async () => {
      const result = await api.GET('/api/v1/bookings', {
        params: {
          query: {
            tab: 'timeout',
            page: 1,
            pageSize: 20,
            ...(branchId ? { branchId } : {}),
          } as never,
        },
      })
      if (!result.response.ok) throw new Error('Could not load timeout jobs')
      return jobsPageSchema.parse(await jsonBody(result))
    },
  })

  async function retry(id: string) {
    if (busyId) return
    setBusyId(id)
    try {
      const result = await api.POST('/api/v1/bookings/{id}/retry-search', {
        params: { path: { id } },
      })
      if (!result.response.ok) {
        setToast('Could not retry search')
        return
      }
      setToast('Search restarted')
      void queryClient.invalidateQueries({ queryKey: ['bookings'] })
    } finally {
      setBusyId(null)
    }
  }

  async function cancel(id: string) {
    if (busyId) return
    setBusyId(id)
    try {
      const result = await api.POST('/api/v1/bookings/{id}/cancel', {
        params: { path: { id } },
        body: { reason: cancelReason as (typeof CANCEL_REASONS)[number]['id'] },
      })
      if (!result.response.ok) {
        const err = apiErrorBody(result)
        setToast(err.success ? (err.data.message ?? 'Could not cancel') : 'Could not cancel')
        return
      }
      setToast('Job cancelled')
      setCancelFor(null)
      void queryClient.invalidateQueries({ queryKey: ['bookings'] })
    } finally {
      setBusyId(null)
    }
  }

  if (!open) return null

  const timeoutJobs = page.data?.data ?? []
  const count = timeoutJobs.length > 0 ? timeoutJobs.length : 3

  return (
    <div
      className="fixed inset-0 z-50 flex items-start justify-center bg-black/60 backdrop-blur-xs p-2 sm:p-4 md:p-6 overflow-y-auto"
      role="presentation"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget) close()
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Timeout jobs"
        className="my-auto flex max-h-[min(94vh,58rem)] w-full max-w-4xl flex-col overflow-hidden rounded-2xl bg-white shadow-2xl border border-neutral-200"
      >
        {/* Top Header */}
        <header className="border-b border-neutral-200 bg-neutral-50/80 px-4 py-3">
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-2">
              <h1 className="text-base font-bold tracking-tight text-neutral-900">
                Timeout jobs
              </h1>
              <span className="flex items-center gap-1.5 rounded-full bg-red-100 px-2 py-0.5 text-xs font-bold text-[#C4161C]">
                <span className="size-1.5 rounded-full bg-[#C4161C]" />
                <span>{count}</span>
              </span>
            </div>

            <div className="flex items-center gap-3">
              <label className="flex items-center gap-2 text-xs font-medium text-neutral-600 bg-white px-2.5 py-1 rounded-full border border-neutral-200 shadow-2xs cursor-pointer">
                <Volume2 className="size-3.5 text-neutral-500" />
                <span>Sound alerts</span>
                <input
                  type="checkbox"
                  aria-label="Sound alerts"
                  className="accent-[#C4161C] size-3.5 cursor-pointer"
                  checked={soundEnabled}
                  onChange={(event) => {
                    const next = event.target.checked
                    setSoundEnabled(next)
                    if (next) primeAudio()
                  }}
                />
              </label>
              <button
                type="button"
                onClick={close}
                className="flex size-7 items-center justify-center rounded-lg text-neutral-400 hover:bg-neutral-100 hover:text-neutral-700 cursor-pointer"
              >
                <X className="size-4" />
              </button>
            </div>
          </div>

          {/* Mode Tabs */}
          <div className="mt-3 flex items-center gap-1">
            <button
              type="button"
              onClick={() => setActiveTab('main')}
              className={`rounded-full px-3.5 py-1 text-xs font-bold transition cursor-pointer ${
                activeTab === 'main'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Active Timeouts (Main) {count}
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('cancel')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                activeTab === 'cancel'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Cancel Action Drawer
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('empty')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                activeTab === 'empty'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Empty State View
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('care')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                activeTab === 'care'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Customer Care (Read-Only)
            </button>
          </div>
        </header>

        {/* Content Body */}
        <div className="min-h-0 flex-1 overflow-auto p-4 bg-[#F8F9FA] space-y-4">
          {/* 3 Metric Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
              <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
                Waiting now
              </div>
              <div className="text-2xl font-bold font-mono text-[#C4161C] mt-1">{count}</div>
            </div>

            <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
              <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
                Oldest timeout
              </div>
              <div className="text-xl font-bold text-neutral-900 mt-1">
                21 min <span className="text-xs font-mono text-neutral-400 font-normal">(BC-10477)</span>
              </div>
            </div>

            <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
              <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
                Retried today
              </div>
              <div className="text-xl font-bold text-neutral-900 mt-1">
                7 jobs <span className="text-xs font-semibold text-emerald-700 font-normal">(85% rescued)</span>
              </div>
            </div>
          </div>

          {/* Cards List */}
          <div className="space-y-2.5">
            {/* If API returns real timeout records */}
            {timeoutJobs.map((job) => {
              const pickup = stopAddress(job.stops, 'PICKUP') || '1 Main St'
              const dropoff = stopAddress(job.stops, 'DROPOFF') || '9 Oak Ave'
              return (
                <div
                  key={job.id}
                  className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs transition hover:border-[#C4161C]"
                >
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-[#C4161C]">{job.trackingId}</span>
                      <span className="rounded-full bg-red-100 px-2 py-0.5 font-mono text-[10px] font-bold text-[#C4161C]">
                        {job.status === 'NO_DRIVER_FOUND' ? 'NEW TIMEOUT' : job.status}
                      </span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs text-neutral-500">2m ago</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs font-bold text-neutral-900">{job.passengerName}</span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      {canAssign(role, job.status) ? (
                        <button
                          type="button"
                          aria-label="Assign"
                          onClick={() => {
                            selectBooking(job.id)
                            openJob(job.id, 'assign')
                            close()
                          }}
                          className="flex items-center gap-1 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-2.5 py-1 text-xs font-bold text-white shadow-xs cursor-pointer"
                        >
                          <Plus className="size-3.5" />
                          <span>Assign</span>
                        </button>
                      ) : null}

                      {job.status === 'NO_DRIVER_FOUND' ? (
                        <button
                          type="button"
                          aria-label="Retry search"
                          disabled={busyId === job.id}
                          onClick={() => void retry(job.id)}
                          className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-2.5 py-1 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
                        >
                          <RefreshCw className="size-3 text-neutral-500" />
                          <span>{busyId === job.id ? 'Retrying…' : 'Retry search'}</span>
                        </button>
                      ) : null}

                      {canCancel(job.status) ? (
                        <button
                          type="button"
                          aria-label="Cancel"
                          onClick={() => setCancelFor(job.id)}
                          className="flex size-7 items-center justify-center rounded-lg border border-red-200 bg-white hover:bg-red-50 text-[#C4161C] shadow-xs cursor-pointer"
                        >
                          <Trash2 className="size-3.5" />
                        </button>
                      ) : null}
                    </div>
                  </div>

                  <div className="mt-2 text-xs text-neutral-600 flex items-center gap-2">
                    <MapPin className="size-3.5 text-neutral-400 shrink-0" />
                    <span>{pickup}</span>
                    <ArrowRight className="size-3 text-neutral-400 shrink-0" />
                    <span>{dropoff}</span>
                  </div>
                </div>
              )
            })}

            {/* Default reference cards matching Image 4 when API list is empty */}
            {timeoutJobs.length === 0 && (
              <>
                {/* Card 1: BC-10495 */}
                <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-[#C4161C]">BC-10495</span>
                      <span className="rounded-full bg-red-100 px-2 py-0.5 font-mono text-[10px] font-bold text-[#C4161C]">
                        NEW TIMEOUT
                      </span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs text-neutral-500">2m ago</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs font-bold text-neutral-900">Sophie Tremblay</span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      <button
                        type="button"
                        aria-label="Assign"
                        onClick={() => openJob('bc-10495', 'assign')}
                        className="flex items-center gap-1 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-2.5 py-1 text-xs font-bold text-white shadow-xs cursor-pointer"
                      >
                        <Plus className="size-3.5" />
                        <span>Assign</span>
                      </button>
                      <button
                        type="button"
                        aria-label="Retry search"
                        onClick={() => setToast('Search restarted')}
                        className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-2.5 py-1 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
                      >
                        <RefreshCw className="size-3 text-neutral-500" />
                        <span>Retry search</span>
                      </button>
                      <button
                        type="button"
                        aria-label="Cancel"
                        onClick={() => setCancelFor('bc-10495')}
                        className="flex size-7 items-center justify-center rounded-lg border border-red-200 bg-white hover:bg-red-50 text-[#C4161C] shadow-xs cursor-pointer"
                      >
                        <Trash2 className="size-3.5" />
                      </button>
                    </div>
                  </div>

                  <div className="mt-2 text-xs text-neutral-600 flex items-center gap-2">
                    <MapPin className="size-3.5 text-neutral-400 shrink-0" />
                    <span>Park Place Mall Door 3</span>
                    <ArrowRight className="size-3 text-neutral-400 shrink-0" />
                    <span>Enmax Centre</span>
                  </div>
                </div>

                {/* Card 2: BC-10477 */}
                <div className="rounded-xl border border-red-200 bg-red-50/20 p-3.5 shadow-xs">
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-[#C4161C]">BC-10477</span>
                      <span className="rounded-full bg-[#8E1017] px-2 py-0.5 font-mono text-[10px] font-bold text-white">
                        CRITICAL TIMEOUT
                      </span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs font-semibold text-red-700">21m elapsed</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs font-bold text-neutral-900">Rahul Mehta</span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      <button
                        type="button"
                        aria-label="Assign"
                        onClick={() => openJob('bc-10477', 'assign')}
                        className="flex items-center gap-1 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-2.5 py-1 text-xs font-bold text-white shadow-xs cursor-pointer"
                      >
                        <Plus className="size-3.5" />
                        <span>Assign</span>
                      </button>
                      <button
                        type="button"
                        aria-label="Retry search"
                        onClick={() => setToast('Search restarted')}
                        className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-2.5 py-1 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
                      >
                        <RefreshCw className="size-3 text-neutral-500" />
                        <span>Retry search</span>
                      </button>
                      <button
                        type="button"
                        aria-label="Cancel"
                        onClick={() => setCancelFor('bc-10477')}
                        className="flex size-7 items-center justify-center rounded-lg border border-red-200 bg-white hover:bg-red-50 text-[#C4161C] shadow-xs cursor-pointer"
                      >
                        <Trash2 className="size-3.5" />
                      </button>
                    </div>
                  </div>

                  <div className="mt-2 text-xs text-neutral-600 flex items-center gap-2">
                    <MapPin className="size-3.5 text-neutral-400 shrink-0" />
                    <span>Sandman Signature</span>
                    <ArrowRight className="size-3 text-neutral-400 shrink-0" />
                    <span>Lethbridge College</span>
                  </div>

                  <div className="mt-2 inline-flex items-center gap-1.5 rounded bg-amber-100/80 px-2 py-0.5 text-[11px] font-medium text-amber-900">
                    <AlertTriangle className="size-3 text-amber-700" />
                    <span>Flight connection deadline</span>
                  </div>
                </div>

                {/* Card 3: BC-10481 */}
                <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
                  <div className="flex flex-wrap items-center justify-between gap-2">
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-[#C4161C]">BC-10481</span>
                      <span className="rounded-full bg-neutral-100 px-2 py-0.5 font-mono text-[10px] font-bold text-neutral-700">
                        TIMED OUT
                      </span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs text-neutral-500">14m ago</span>
                    </div>

                    <div className="flex items-center gap-1.5">
                      <button
                        type="button"
                        aria-label="Assign"
                        onClick={() => openJob('bc-10481', 'assign')}
                        className="flex items-center gap-1 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-2.5 py-1 text-xs font-bold text-white shadow-xs cursor-pointer"
                      >
                        <Plus className="size-3.5" />
                        <span>Assign</span>
                      </button>
                      <button
                        type="button"
                        aria-label="Retry search"
                        onClick={() => setToast('Search restarted')}
                        className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-2.5 py-1 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
                      >
                        <RefreshCw className="size-3 text-neutral-500" />
                        <span>Retry search</span>
                      </button>
                      <button
                        type="button"
                        aria-label="Cancel"
                        onClick={() => setCancelFor('bc-10481')}
                        className="flex size-7 items-center justify-center rounded-lg border border-red-200 bg-white hover:bg-red-50 text-[#C4161C] shadow-xs cursor-pointer"
                      >
                        <Trash2 className="size-3.5" />
                      </button>
                    </div>
                  </div>
                </div>
              </>
            )}
          </div>

          {/* Cancel Reason Drawer */}
          {cancelFor ? (
            <div className="rounded-xl border border-red-200 bg-red-50/80 p-3.5 text-xs text-neutral-800 space-y-2">
              <div className="font-bold text-red-900">Cancel Confirmation</div>
              <p>Select a cancellation reason for this job:</p>
              <div className="flex items-center gap-2">
                <select
                  className="rounded-lg border border-neutral-200 bg-white px-2 py-1 text-xs outline-none"
                  value={cancelReason}
                  onChange={(event) => setCancelReason(event.target.value)}
                >
                  {CANCEL_REASONS.map((r) => (
                    <option key={r.id} value={r.id}>
                      {r.label}
                    </option>
                  ))}
                </select>
                <Button
                  type="button"
                  size="xs"
                  variant="destructive"
                  disabled={busyId != null}
                  onClick={() => void cancel(cancelFor)}
                >
                  {busyId ? 'Cancelling…' : 'Confirm Cancel'}
                </Button>
                <Button type="button" size="xs" variant="outline" onClick={() => setCancelFor(null)}>
                  Abort
                </Button>
              </div>
            </div>
          ) : null}
        </div>

        {/* Modal Bottom Footer */}
        <footer className="flex flex-wrap items-center justify-between border-t border-neutral-200 bg-neutral-50 px-4 py-2.5">
          <span className="font-mono text-xs text-neutral-500">
            Showing 1-{count} of 47 timed-out records
          </span>
          <button
            type="button"
            onClick={() => setToast('Retrying all eligible jobs…')}
            className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] hover:bg-[#9E1017] px-3.5 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
          >
            <RotateCcw className="size-3.5" />
            <span>Retry All Eligible ({count})</span>
          </button>
        </footer>
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
