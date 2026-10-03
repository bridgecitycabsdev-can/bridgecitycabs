import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useMemo, useState } from 'react'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import { canAdjustFare, canConfirmCash } from '@/features/bookings/booking-detail'
import { JobsTable, PlainText } from '@/features/bookings/JobsTable'
import {
  bookedLabel,
  jobsPageSchema,
  stopAddress,
} from '@/features/bookings/jobs-table'
import { jobsColumnHelper } from '@/features/bookings/jobs-table-setup'
import { adjustBookingFare, confirmCashPayment } from '@/features/bookings/money-actions'
import { useOpsPanels } from '@/features/bookings/ops-panels'
import { useBookingUi } from '@/features/bookings/selection'
import { dispatchConfigSchema } from '@/features/dispatch/drafts/schema'
import { useDrafts } from '@/features/dispatch/drafts/store'
import { api, jsonBody } from '@/lib/api'

const helper = jobsColumnHelper

export function PaymentPendingJobsModal() {
  const open = useOpsPanels((state) => state.paymentPendingOpen)
  const close = useOpsPanels((state) => state.closePaymentPending)
  const branchId = useBranchId()
  const role = useSession((state) => state.profile?.role.name)
  const openJob = useBookingUi((state) => state.openJob)
  const setToast = useBookingUi((state) => state.setToast)
  const selectBooking = useDrafts((state) => state.selectBooking)
  const queryClient = useQueryClient()
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 20 })
  const [busyId, setBusyId] = useState<string | null>(null)

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
    queryKey: ['bookings', 'payment_pending', branchId, pagination.pageIndex, pagination.pageSize],
    enabled: open && Boolean(branchId),
    queryFn: async () => {
      const result = await api.GET('/api/v1/bookings', {
        params: {
          query: {
            tab: 'payment_pending',
            page: pagination.pageIndex + 1,
            pageSize: pagination.pageSize,
            ...(branchId ? { branchId } : {}),
          } as never,
        },
      })
      if (!result.response.ok) throw new Error('Could not load payment-pending jobs')
      return jobsPageSchema.parse(await jsonBody(result))
    },
  })

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
        helper.accessor('paymentMethod', {
          header: 'Method',
          cell: (info) => <PlainText value={info.getValue() ?? '—'} />,
        }),
        helper.display({
          id: 'action',
          header: 'Action',
          cell: ({ row }) => {
            const id = row.original.id
            const status = row.original.status
            const showCash = canConfirmCash(role, status)
            const showAdjust = canAdjustFare(role, status)
            return (
              <div className="flex flex-wrap gap-1">
                {showCash ? (
                  <Button
                    type="button"
                    size="xs"
                    disabled={busyId != null}
                    onClick={() => {
                      void (async () => {
                        setBusyId(id)
                        try {
                          const ok = await confirmCashPayment(id)
                          if (!ok) {
                            setToast('Could not confirm cash')
                            return
                          }
                          setToast('Cash confirmed')
                          void queryClient.invalidateQueries({ queryKey: ['bookings'] })
                          void queryClient.invalidateQueries({
                            queryKey: ['dispatch-config'],
                          })
                        } finally {
                          setBusyId(null)
                        }
                      })()
                    }}
                  >
                    {busyId === id ? '…' : 'Confirm cash'}
                  </Button>
                ) : null}
                {showAdjust ? (
                  <Button
                    type="button"
                    size="xs"
                    variant="outline"
                    disabled={busyId != null}
                    onClick={() => {
                      void (async () => {
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
                          void queryClient.invalidateQueries({
                            queryKey: ['dispatch-config'],
                          })
                        } finally {
                          setBusyId(null)
                        }
                      })()
                    }}
                  >
                    Adjust fare
                  </Button>
                ) : null}
                <Button
                  type="button"
                  size="xs"
                  variant="outline"
                  onClick={() => {
                    selectBooking(id)
                    openJob(id)
                    close()
                  }}
                >
                  Open
                </Button>
              </div>
            )
          },
        }),
      ]),
    [busyId, close, openJob, queryClient, role, selectBooking, setToast, timezone],
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
        aria-label="Payment pending jobs"
        className="bg-card flex max-h-[min(92vh,56rem)] w-full max-w-6xl flex-col overflow-hidden rounded-lg border shadow-lg"
      >
        <header className="flex flex-wrap items-center justify-between gap-2 border-b px-3 py-2">
          <div>
            <h2 className="text-sm font-semibold">Payment pending</h2>
            <p className="text-muted-foreground text-xs">
              Confirm cash on the job. The system never auto-confirms money.
            </p>
          </div>
          <Button type="button" size="xs" variant="ghost" onClick={close}>
            Close
          </Button>
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
              emptyMessage="No trips waiting on payment."
            />
          )}
        </div>
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
