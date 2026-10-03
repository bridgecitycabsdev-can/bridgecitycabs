import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useEffect, useMemo, useState } from 'react'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import { apiErrorBody } from '@/features/bookings/api-error'
import { CANCEL_REASONS, canAssign, canCancel } from '@/features/bookings/booking-detail'
import { JobsTable, PlainText } from '@/features/bookings/JobsTable'
import {
  bookedLabel,
  jobsPageSchema,
  stopAddress,
} from '@/features/bookings/jobs-table'
import { jobsColumnHelper } from '@/features/bookings/jobs-table-setup'
import { useOpsPanels } from '@/features/bookings/ops-panels'
import { useBookingUi } from '@/features/bookings/selection'
import { useTimeoutAlerts } from '@/features/bookings/timeout-alerts'
import { dispatchConfigSchema } from '@/features/dispatch/drafts/schema'
import { useDrafts } from '@/features/dispatch/drafts/store'
import { api, jsonBody } from '@/lib/api'

const helper = jobsColumnHelper

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
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 20 })
  const [busyId, setBusyId] = useState<string | null>(null)
  const [cancelFor, setCancelFor] = useState<string | null>(null)
  const [cancelReason, setCancelReason] = useState<string>(CANCEL_REASONS[0].id)

  useEffect(() => {
    if (open) clearBadge()
  }, [clearBadge, open])

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

  const page = useQuery({
    queryKey: ['bookings', 'timeout', branchId, pagination.pageIndex, pagination.pageSize],
    enabled: open && Boolean(branchId),
    queryFn: async () => {
      const result = await api.GET('/api/v1/bookings', {
        params: {
          query: {
            tab: 'timeout',
            page: pagination.pageIndex + 1,
            pageSize: pagination.pageSize,
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

  const columns = useMemo(
    () =>
      helper.columns([
        helper.display({
          id: 'booked',
          header: 'Booked',
          cell: ({ row }) => (
            <span className="block">
              <PlainText value={row.original.trackingId} />
              <span className="text-muted-foreground block">
                {bookedLabel(row.original, timezone)}
              </span>
            </span>
          ),
        }),
        helper.accessor((row) => stopAddress(row.stops, 'PICKUP'), {
          id: 'pickup',
          header: 'Pick-Up',
          cell: (info) => <PlainText value={info.getValue()} />,
        }),
        helper.accessor((row) => stopAddress(row.stops, 'DROPOFF'), {
          id: 'dropoff',
          header: 'Drop-Off',
          cell: (info) => <PlainText value={info.getValue()} />,
        }),
        helper.accessor('passengerName', {
          header: 'Passenger',
          cell: (info) => <PlainText value={info.getValue()} />,
        }),
        helper.accessor('passengerPhone', {
          header: 'Phone',
          cell: (info) => <PlainText value={info.getValue()} />,
        }),
        helper.accessor('source', {
          header: 'Source',
          cell: (info) => <PlainText value={info.getValue()} />,
        }),
        helper.accessor('status', {
          header: 'Status',
          cell: (info) => <PlainText value={info.getValue()} />,
        }),
        helper.display({
          id: 'action',
          header: 'Action',
          cell: ({ row }) => {
            const job = row.original
            return (
              <div className="flex flex-wrap gap-1">
                {canAssign(role, job.status) ? (
                  <Button
                    type="button"
                    size="xs"
                    onClick={() => {
                      selectBooking(job.id)
                      openJob(job.id, 'assign')
                      close()
                    }}
                  >
                    Assign
                  </Button>
                ) : null}
                {job.status === 'NO_DRIVER_FOUND' ? (
                  <Button
                    type="button"
                    size="xs"
                    variant="outline"
                    disabled={busyId === job.id}
                    onClick={() => void retry(job.id)}
                  >
                    {busyId === job.id ? 'Retrying…' : 'Retry search'}
                  </Button>
                ) : null}
                {canCancel(job.status) ? (
                  <Button
                    type="button"
                    size="xs"
                    variant="destructive"
                    onClick={() => setCancelFor(job.id)}
                  >
                    Cancel
                  </Button>
                ) : null}
              </div>
            )
          },
        }),
      ]),
    [busyId, close, openJob, role, selectBooking, timezone],
  )

  if (!open) return null

  return (
    <div
      className="fixed inset-0 z-50 flex items-start justify-center bg-black/40 p-3 sm:p-6"
      role="presentation"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget) close()
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Unassigned and timeout jobs"
        className="bg-card flex max-h-[min(92vh,56rem)] w-full max-w-6xl flex-col overflow-hidden rounded-lg border shadow-lg"
      >
        <header className="flex flex-wrap items-center justify-between gap-2 border-b px-3 py-2">
          <div>
            <h2 className="text-sm font-semibold">Unassigned / Timeout</h2>
            <p className="text-muted-foreground text-xs">
              Missed auto offers and long manual waits
            </p>
          </div>
          <div className="flex items-center gap-2">
            <label className="inline-flex items-center gap-1.5 text-xs">
              <input
                type="checkbox"
                aria-label="Sound alerts"
                checked={soundEnabled}
                onChange={(event) => {
                  const next = event.target.checked
                  setSoundEnabled(next)
                  if (next) primeAudio()
                }}
              />
              Sound alerts
            </label>
            <Button type="button" size="xs" variant="ghost" onClick={close}>
              Close
            </Button>
          </div>
        </header>
        <div className="flex min-h-0 flex-1 flex-col p-3">
          {!branchId ? (
            <p className="text-muted-foreground text-sm">Select a branch to load jobs.</p>
          ) : (
            <JobsTable
              data={page.data?.data ?? []}
              columns={columns}
              pagination={pagination}
              onPaginationChange={setPagination}
              pageCount={page.data?.meta.totalPages ?? 0}
              total={page.data?.meta.total ?? 0}
              isPending={page.isPending}
              isError={page.isError}
              emptyMessage="No timeout jobs right now."
            />
          )}
        </div>
        {cancelFor ? (
          <div className="flex flex-wrap items-end gap-2 border-t px-3 py-2">
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
              disabled={busyId === cancelFor}
              onClick={() => void cancel(cancelFor)}
            >
              Confirm cancel
            </Button>
            <Button type="button" size="sm" variant="outline" onClick={() => setCancelFor(null)}>
              Back
            </Button>
          </div>
        ) : null}
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
