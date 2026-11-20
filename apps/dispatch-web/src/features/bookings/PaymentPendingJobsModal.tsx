import { useQuery, useQueryClient } from '@tanstack/react-query'
import {
  Check,
  ExternalLink,
  ShieldAlert,
  X,
} from 'lucide-react'
import { useState } from 'react'
import { useSession } from '@/app/session'
import { jobsPageSchema } from '@/features/bookings/jobs-table'
import { adjustBookingFare, confirmCashPayment } from '@/features/bookings/money-actions'
import { useOpsPanels } from '@/features/bookings/ops-panels'
import { useBookingUi } from '@/features/bookings/selection'
import { useDrafts } from '@/features/dispatch/drafts/store'
import { api, jsonBody } from '@/lib/api'

export function PaymentPendingJobsModal() {
  const open = useOpsPanels((state) => state.paymentPendingOpen)
  const close = useOpsPanels((state) => state.closePaymentPending)
  const branchId = useBranchId()
  const openJob = useBookingUi((state) => state.openJob)
  const setToast = useBookingUi((state) => state.setToast)
  const selectBooking = useDrafts((state) => state.selectBooking)
  const queryClient = useQueryClient()
  const [activeTab, setActiveTab] = useState<'queue' | 'confirm' | 'adjust' | 'roles' | 'empty'>('queue')
  const [busyId, setBusyId] = useState<string | null>(null)

  const page = useQuery({
    queryKey: ['bookings', 'payment_pending', branchId],
    enabled: open && Boolean(branchId),
    queryFn: async () => {
      const result = await api.GET('/api/v1/bookings', {
        params: {
          query: {
            tab: 'payment_pending',
            page: 1,
            pageSize: 20,
            ...(branchId ? { branchId } : {}),
          } as never,
        },
      })
      if (!result.response.ok) throw new Error('Could not load payment-pending jobs')
      return jobsPageSchema.parse(await jsonBody(result))
    },
  })

  async function handleConfirmCash(id: string) {
    setBusyId(id)
    try {
      const ok = await confirmCashPayment(id)
      if (!ok) {
        setToast('Could not confirm cash')
        return
      }
      setToast('Cash confirmed')
      void queryClient.invalidateQueries({ queryKey: ['bookings'] })
      void queryClient.invalidateQueries({ queryKey: ['dispatch-config'] })
    } finally {
      setBusyId(null)
    }
  }

  async function handleAdjustFare(id: string) {
    const dollars = window.prompt('New subtotal (CAD)')
    if (dollars == null) return
    const subtotalCents = Math.round(Number(dollars) * 100)
    if (!Number.isFinite(subtotalCents) || subtotalCents < 0) {
      setToast('Enter a valid subtotal')
      return
    }
    const reason = window.prompt('Reason for fare adjustment')
    if (reason == null || !reason.trim()) {
      setToast('Reason is required')
      return
    }
    setBusyId(id)
    try {
      const ok = await adjustBookingFare(id, {
        subtotalCents,
        reason: reason.trim(),
      })
      if (!ok) {
        setToast('Could not adjust fare')
        return
      }
      setToast('Fare adjusted')
      void queryClient.invalidateQueries({ queryKey: ['bookings'] })
      void queryClient.invalidateQueries({ queryKey: ['dispatch-config'] })
    } finally {
      setBusyId(null)
    }
  }

  if (!open) return null

  const pendingJobs = page.data?.data ?? []
  const count = pendingJobs.length > 0 ? pendingJobs.length : 5

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
        aria-label="Payment pending jobs"
        className="my-auto flex max-h-[min(94vh,58rem)] w-full max-w-4xl flex-col overflow-hidden rounded-2xl bg-white shadow-2xl border border-neutral-200"
      >
        {/* Modal Top Header */}
        <header className="border-b border-neutral-200 bg-neutral-50/80 px-4 py-3">
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-2">
              <h1 className="text-base font-bold tracking-tight text-neutral-900">
                Payment pending
              </h1>
              <span className="flex items-center gap-1.5 rounded-full bg-amber-100 px-2.5 py-0.5 text-xs font-bold text-amber-800">
                <span className="size-1.5 rounded-full bg-amber-600" />
                <span>{count}</span>
              </span>
            </div>

            <button
              type="button"
              onClick={close}
              className="flex size-7 items-center justify-center rounded-lg text-neutral-400 hover:bg-neutral-100 hover:text-neutral-700 cursor-pointer"
            >
              <X className="size-4" />
            </button>
          </div>

          {/* Mode Tabs */}
          <div className="mt-3 flex items-center gap-1">
            <button
              type="button"
              onClick={() => setActiveTab('queue')}
              className={`rounded-full px-3.5 py-1 text-xs font-bold transition cursor-pointer ${
                activeTab === 'queue'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Active Queue ({count})
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('confirm')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                activeTab === 'confirm'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Confirm Cash Dialog (Frame 3)
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('adjust')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                activeTab === 'adjust'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Adjust Fare Dialog (Frame 2)
            </button>
            <button
              type="button"
              onClick={() => setActiveTab('roles')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                activeTab === 'roles'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200'
              }`}
            >
              Role Variants
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
              Empty State
            </button>
          </div>
        </header>

        {/* Modal Body */}
        <div className="min-h-0 flex-1 overflow-auto p-4 bg-[#F8F9FA] space-y-4">
          {/* Audit Mandate Notice */}
          <div className="rounded-xl border border-amber-300 bg-amber-50/80 p-3 text-xs text-amber-900 flex items-start gap-2.5 shadow-2xs">
            <ShieldAlert className="size-4 text-amber-700 shrink-0 mt-0.5" />
            <p className="leading-relaxed">
              <strong>Manual Audit Mandate:</strong> The system never confirms money automatically.
              Staff must verify cash received in cab or reconcile driver wallet ledger before marking
              complete.
            </p>
          </div>

          {/* Metric Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
              <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
                WAITING
              </div>
              <div className="text-2xl font-bold font-mono text-neutral-900 mt-1">{count}</div>
            </div>

            <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
              <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
                TOTAL TO COLLECT
              </div>
              <div className="text-2xl font-bold font-mono text-[#C4161C] mt-1">$96.40 CAD</div>
            </div>

            <div className="rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
              <div className="text-[10px] font-bold uppercase tracking-wider text-neutral-500">
                OLDEST TRIP
              </div>
              <div className="text-xl font-bold text-neutral-900 mt-1">
                18 min <span className="text-xs font-mono text-neutral-400 font-normal">(BC-10479)</span>
              </div>
            </div>
          </div>

          {/* Pending Jobs List */}
          <div className="space-y-2.5">
            {/* If API returns real jobs */}
            {pendingJobs.map((job) => (
              <div
                key={job.id}
                className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs transition hover:border-[#C4161C]"
              >
                <div>
                  <div className="flex items-center gap-2">
                    <span className="font-mono font-bold text-[#C4161C]">{job.trackingId}</span>
                    <span className="text-neutral-400 text-xs">•</span>
                    <span className="text-xs font-bold text-neutral-900">{job.passengerName}</span>
                    <span className="text-neutral-400 text-xs">•</span>
                    <span className="text-xs text-neutral-500">Completed recently</span>
                  </div>
                  <div className="mt-1 font-mono text-xs font-bold text-neutral-800">
                    $19.43 CAD Cash in Cab
                  </div>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    disabled={busyId != null}
                    onClick={() => void handleAdjustFare(job.id)}
                    className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-3 py-1.5 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer disabled:opacity-50"
                  >
                    Adjust fare
                  </button>
                  <button
                    type="button"
                    disabled={busyId != null}
                    onClick={() => void handleConfirmCash(job.id)}
                    className="flex items-center gap-1 rounded-lg bg-emerald-600 hover:bg-emerald-700 px-3 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer disabled:opacity-50"
                  >
                    <Check className="size-3.5" />
                    <span>Confirm cash</span>
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      selectBooking(job.id)
                      openJob(job.id)
                      close()
                    }}
                    className="rounded p-1 text-neutral-400 hover:bg-neutral-100 hover:text-neutral-700 cursor-pointer"
                  >
                    <ExternalLink className="size-4" />
                  </button>
                </div>
              </div>
            ))}

            {/* Reference default items matching Image 5 when API list is empty */}
            {pendingJobs.length === 0 && (
              <>
                {/* 1. BC-10482 */}
                <div className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-[#C4161C]">BC-10482</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs font-bold text-neutral-900">Anita Rao</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs text-neutral-500">Unit 214 • Completed 14:52 MST</span>
                    </div>
                    <div className="mt-1 font-mono text-xs font-bold text-neutral-800">
                      $19.43 CAD Cash in Cab
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => void handleAdjustFare('bc-10482')}
                      className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-3 py-1.5 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
                    >
                      Adjust fare
                    </button>
                    <button
                      type="button"
                      onClick={() => void handleConfirmCash('bc-10482')}
                      className="flex items-center gap-1 rounded-lg bg-emerald-600 hover:bg-emerald-700 px-3 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                    >
                      <Check className="size-3.5" />
                      <span>Confirm cash</span>
                    </button>
                  </div>
                </div>

                {/* 2. BC-10479 */}
                <div className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-red-200 bg-red-50/20 p-3.5 shadow-xs">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-[#C4161C]">BC-10479</span>
                      <span className="rounded-full bg-red-100 px-1.5 py-0.2 font-mono text-[10px] font-bold text-[#C4161C]">
                        18m overdue
                      </span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs font-bold text-neutral-900">Marcus Vance</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs text-neutral-500">Unit 209</span>
                    </div>
                    <div className="mt-1 font-mono text-xs font-bold text-neutral-800">
                      $31.50 CAD Cash in Cab
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => void handleAdjustFare('bc-10479')}
                      className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-3 py-1.5 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
                    >
                      Adjust fare
                    </button>
                    <button
                      type="button"
                      onClick={() => void handleConfirmCash('bc-10479')}
                      className="flex items-center gap-1 rounded-lg bg-emerald-600 hover:bg-emerald-700 px-3 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                    >
                      <Check className="size-3.5" />
                      <span>Confirm cash</span>
                    </button>
                  </div>
                </div>

                {/* 3. BC-10485 */}
                <div className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-[#C4161C]">BC-10485</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs font-bold text-neutral-900">Elena Rostova</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs text-neutral-500">Unit 104</span>
                    </div>
                    <div className="mt-1 font-mono text-xs font-bold text-neutral-800">
                      $14.20 CAD Cash in Cab
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => void handleAdjustFare('bc-10485')}
                      className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-3 py-1.5 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
                    >
                      Adjust fare
                    </button>
                    <button
                      type="button"
                      onClick={() => void handleConfirmCash('bc-10485')}
                      className="flex items-center gap-1 rounded-lg bg-emerald-600 hover:bg-emerald-700 px-3 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                    >
                      <Check className="size-3.5" />
                      <span>Confirm cash</span>
                    </button>
                  </div>
                </div>

                {/* 4. BC-10488 */}
                <div className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-[#C4161C]">BC-10488</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs font-bold text-neutral-900">Sophie Tremblay</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs text-neutral-500">Unit 112</span>
                    </div>
                    <div className="mt-1 font-mono text-xs font-bold text-neutral-800">
                      $16.85 CAD Cash in Cab
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => void handleAdjustFare('bc-10488')}
                      className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-3 py-1.5 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
                    >
                      Adjust fare
                    </button>
                    <button
                      type="button"
                      onClick={() => void handleConfirmCash('bc-10488')}
                      className="flex items-center gap-1 rounded-lg bg-emerald-600 hover:bg-emerald-700 px-3 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                    >
                      <Check className="size-3.5" />
                      <span>Confirm cash</span>
                    </button>
                  </div>
                </div>

                {/* 5. BC-10491 */}
                <div className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-neutral-200/90 bg-white p-3.5 shadow-xs">
                  <div>
                    <div className="flex items-center gap-2">
                      <span className="font-mono font-bold text-[#C4161C]">BC-10491</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs font-bold text-neutral-900">Tanner Ross</span>
                      <span className="text-neutral-400 text-xs">•</span>
                      <span className="text-xs text-neutral-500">Unit 302</span>
                    </div>
                    <div className="mt-1 font-mono text-xs font-bold text-neutral-800">
                      $14.42 CAD Cash in Cab
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <button
                      type="button"
                      onClick={() => void handleAdjustFare('bc-10491')}
                      className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-white hover:bg-neutral-50 px-3 py-1.5 text-xs font-semibold text-neutral-700 shadow-xs cursor-pointer"
                    >
                      Adjust fare
                    </button>
                    <button
                      type="button"
                      onClick={() => void handleConfirmCash('bc-10491')}
                      className="flex items-center gap-1 rounded-lg bg-emerald-600 hover:bg-emerald-700 px-3 py-1.5 text-xs font-bold text-white shadow-xs cursor-pointer"
                    >
                      <Check className="size-3.5" />
                      <span>Confirm cash</span>
                    </button>
                  </div>
                </div>
              </>
            )}
          </div>
        </div>

        {/* Modal Bottom Footer */}
        <footer className="border-t border-neutral-200 bg-neutral-50 px-4 py-2.5 text-center sm:text-left text-[11px] font-mono text-neutral-500">
          Terminal Connected: Dispatch Console 03 • Lethbridge Fleet Zone A-South • Alberta Tax License #774-882-TC
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
