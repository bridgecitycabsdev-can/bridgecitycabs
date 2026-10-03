import { useQuery } from '@tanstack/react-query'
import { useEffect, useMemo, useState } from 'react'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import { JobsTable, PlainText } from '@/features/bookings/JobsTable'
import {
  bookedLabel,
  branchDayRange,
  CLOSED_STATUSES,
  jobsPageSchema,
  stopAddress,
  todayInBranch,
} from '@/features/bookings/jobs-table'
import { jobsColumnHelper } from '@/features/bookings/jobs-table-setup'
import { useOpsPanels } from '@/features/bookings/ops-panels'
import { useBookingUi } from '@/features/bookings/selection'
import { dispatchConfigSchema } from '@/features/dispatch/drafts/schema'
import { useDrafts } from '@/features/dispatch/drafts/store'
import { api, jsonBody } from '@/lib/api'

const helper = jobsColumnHelper
const fieldClass =
  'border-input bg-background h-8 rounded-md border px-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring'

export function ClosedJobsModal() {
  const open = useOpsPanels((state) => state.closedOpen)
  const close = useOpsPanels((state) => state.closeClosed)
  const branchId = useBranchId()
  const openJob = useBookingUi((state) => state.openJob)
  const selectBooking = useDrafts((state) => state.selectBooking)
  const [pagination, setPagination] = useState({ pageIndex: 0, pageSize: 20 })
  const [status, setStatus] = useState('')
  const [fromDate, setFromDate] = useState('')
  const [toDate, setToDate] = useState('')

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

  useEffect(() => {
    if (!open || !config.data) return
    const today = todayInBranch(config.data.timezone)
    setFromDate(today)
    setToDate(today)
    setPagination((state) => ({ ...state, pageIndex: 0 }))
    setStatus('')
  }, [config.data, open])

  const range =
    fromDate && toDate
      ? {
          from: branchDayRange(fromDate, timezone)?.from,
          to: branchDayRange(toDate, timezone)?.to,
        }
      : null

  const page = useQuery({
    queryKey: [
      'bookings',
      'closed',
      branchId,
      fromDate,
      toDate,
      status,
      pagination.pageIndex,
      pagination.pageSize,
    ],
    enabled: open && Boolean(branchId) && Boolean(range?.from && range?.to),
    queryFn: async () => {
      const result = await api.GET('/api/v1/bookings', {
        params: {
          query: {
            tab: 'closed',
            page: pagination.pageIndex + 1,
            pageSize: pagination.pageSize,
            from: range!.from!,
            to: range!.to!,
            ...(status ? { status } : {}),
            ...(branchId ? { branchId } : {}),
          } as never,
        },
      })
      if (!result.response.ok) throw new Error('Could not load closed jobs')
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
          cell: ({ row }) => (
            <Button
              type="button"
              size="xs"
              variant="outline"
              onClick={() => {
                selectBooking(row.original.id)
                openJob(row.original.id)
                close()
              }}
            >
              Open
            </Button>
          ),
        }),
      ]),
    [close, openJob, selectBooking, timezone],
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
        aria-label="Closed jobs"
        className="bg-card flex max-h-[min(92vh,56rem)] w-full max-w-6xl flex-col overflow-hidden rounded-lg border shadow-lg"
      >
        <header className="flex flex-wrap items-center justify-between gap-2 border-b px-3 py-2">
          <div>
            <h2 className="text-sm font-semibold">Closed jobs</h2>
            <p className="text-muted-foreground text-xs">
              Date range uses {timezone} and is sent as UTC instants
            </p>
          </div>
          <Button type="button" size="xs" variant="ghost" onClick={close}>
            Close
          </Button>
        </header>
        <div className="flex flex-wrap items-end gap-2 border-b px-3 py-2">
          <label className="block text-xs">
            <span className="text-muted-foreground">From</span>
            <input
              type="date"
              className={fieldClass}
              value={fromDate}
              onChange={(event) => {
                setFromDate(event.target.value)
                setPagination((state) => ({ ...state, pageIndex: 0 }))
              }}
            />
          </label>
          <label className="block text-xs">
            <span className="text-muted-foreground">To</span>
            <input
              type="date"
              className={fieldClass}
              value={toDate}
              onChange={(event) => {
                setToDate(event.target.value)
                setPagination((state) => ({ ...state, pageIndex: 0 }))
              }}
            />
          </label>
          <label className="block text-xs">
            <span className="text-muted-foreground">Status</span>
            <select
              className={fieldClass}
              value={status}
              onChange={(event) => {
                setStatus(event.target.value)
                setPagination((state) => ({ ...state, pageIndex: 0 }))
              }}
            >
              <option value="">Any closed</option>
              {CLOSED_STATUSES.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>
          </label>
        </div>
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
              emptyMessage="No closed jobs in this range."
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
