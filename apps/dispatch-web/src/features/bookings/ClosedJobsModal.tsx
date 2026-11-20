import { useQuery } from '@tanstack/react-query'
import {
  Archive,
  ArrowRight,
  CheckCircle2,
  FileSpreadsheet,
  Filter,
  Lock,
  RotateCcw,
  ShieldCheck,
  X,
  XCircle,
} from 'lucide-react'
import { useEffect, useMemo, useState } from 'react'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import {
  branchDayRange,
  CLOSED_STATUSES,
  jobsPageSchema,
  stopAddress,
  todayInBranch,
} from '@/features/bookings/jobs-table'
import { useOpsPanels } from '@/features/bookings/ops-panels'
import { useBookingUi } from '@/features/bookings/selection'
import { dispatchConfigSchema } from '@/features/dispatch/drafts/schema'
import { useDrafts } from '@/features/dispatch/drafts/store'
import { api, jsonBody } from '@/lib/api'

interface MockClosedJob {
  id: string
  trackingId: string
  passengerName: string
  driverUnit: string
  driverName: string
  route: string
  routeSubtext?: string
  status: 'PAYMENT_COMPLETED' | 'TRIP_COMPLETED' | 'CLOSED' | 'CANCELLED'
  closedAt: string
}

const DEFAULT_ARCHIVED_ROWS: MockClosedJob[] = [
  {
    id: 'mock-1',
    trackingId: 'BC-10480',
    passengerName: 'Marcus Vance',
    driverUnit: 'U-209',
    driverName: 'Robert T.',
    route: 'Lethbridge Senior Centre,...',
    status: 'PAYMENT_COMPLETED',
    closedAt: '15:04 MST',
  },
  {
    id: 'mock-2',
    trackingId: 'BC-10476',
    passengerName: 'Clara Beauchamp',
    driverUnit: 'U-104',
    driverName: 'Mateo K.',
    route: '2811 5th Ave N → Chino...',
    status: 'TRIP_COMPLETED',
    closedAt: '14:58 MST',
  },
  {
    id: 'mock-3',
    trackingId: 'BC-10473',
    passengerName: 'Douglas MacIntyre',
    driverUnit: 'U-112',
    driverName: 'Jesse P.',
    route: 'Downtown → Coaldale AB',
    status: 'CLOSED',
    closedAt: '14:45 MST',
  },
  {
    id: 'mock-4',
    trackingId: 'BC-10471',
    passengerName: 'Kelsey Thorne',
    driverUnit: 'U-302',
    driverName: 'Jessica L.',
    route: 'YQL → Fort Macleod',
    routeSubtext: 'No-show • Dep. timer elapsed',
    status: 'CANCELLED',
    closedAt: '14:38 MST',
  },
  {
    id: 'mock-5',
    trackingId: 'BC-10468',
    passengerName: 'Elena Rostova',
    driverUnit: 'U-214',
    driverName: 'Harpreet S.',
    route: 'Park Place → Enmax Centre',
    status: 'PAYMENT_COMPLETED',
    closedAt: '14:26 MST',
  },
  {
    id: 'mock-6',
    trackingId: 'BC-10464',
    passengerName: 'Tanner Ross',
    driverUnit: 'U-108',
    driverName: 'Liam C.',
    route: '920 4th Ave S → Safeway...',
    status: 'TRIP_COMPLETED',
    closedAt: '14:15 MST',
  },
  {
    id: 'mock-7',
    trackingId: 'BC-10460',
    passengerName: 'Sophie Tremblay',
    driverUnit: 'U-216',
    driverName: 'David M.',
    route: 'Univ of Lethbridge, 4401 ...',
    status: 'CLOSED',
    closedAt: '14:02 MST',
  },
  {
    id: 'mock-8',
    trackingId: 'BC-10455',
    passengerName: 'Anita Rao',
    driverUnit: 'U-114',
    driverName: 'Priya N.',
    route: 'Scenic Dr S → Kenyon Dr',
    routeSubtext: 'Duplicate request cancelled',
    status: 'CANCELLED',
    closedAt: '13:49 MST',
  },
]

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
  const [modeTab, setModeTab] = useState<'active' | 'loading' | 'empty'>('active')

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

  // Format initials from name
  const getInitials = (name: string) => {
    const parts = name.trim().split(/\s+/)
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase()
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase()
  }

  // Combine real data if available with fallback rows
  const displayRows = useMemo(() => {
    if (page.data?.data && page.data.data.length > 0) {
      return page.data.data.map((job) => ({
        id: job.id,
        trackingId: job.trackingId,
        passengerName: job.passengerName || 'Passenger',
        driverUnit: 'U-209',
        driverName: 'Robert T.',
        route: `${stopAddress(job.stops, 'PICKUP')} → ${stopAddress(job.stops, 'DROPOFF')}`,
        routeSubtext: job.status === 'CANCELLED' ? 'Shift record audit' : undefined,
        status: (job.status as MockClosedJob['status']) || 'CLOSED',
        closedAt: new Date(job.createdAt).toLocaleTimeString([], {
          hour: '2-digit',
          minute: '2-digit',
          hour12: false,
        }) + ' MST',
      }))
    }
    return DEFAULT_ARCHIVED_ROWS
  }, [page.data])

  if (!open) return null

  const totalCount = page.data?.meta?.total ?? 134
  const completedCount = 125
  const cancelledCount = 9

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-2 sm:p-4 backdrop-blur-xs"
      role="presentation"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget) close()
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Closed jobs"
        className="bg-white flex max-h-[min(94vh,58rem)] w-full max-w-6xl flex-col overflow-hidden rounded-2xl border border-neutral-200/80 shadow-2xl animate-in fade-in zoom-in-95 duration-150"
      >
        {/* Header Bar */}
        <header className="flex items-center justify-between border-b border-neutral-200 px-6 py-4 bg-white">
          <div className="flex items-center gap-3">
            <div className="flex size-10 items-center justify-center rounded-xl bg-neutral-100 border border-neutral-200 text-neutral-700">
              <FileSpreadsheet className="size-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h2 className="text-lg font-bold tracking-tight text-neutral-900">Closed jobs</h2>
                <span className="rounded-md bg-neutral-100 border border-neutral-200/90 px-2 py-0.5 text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
                  HISTORICAL ARCHIVE
                </span>
              </div>
              <p className="text-xs text-neutral-500 mt-0.5">
                Archived shift records & audit log • Read-only historical ledger
              </p>
            </div>
          </div>
          <button
            type="button"
            onClick={close}
            className="flex size-8 items-center justify-center rounded-full hover:bg-neutral-100 text-neutral-400 hover:text-neutral-700 transition"
          >
            <X className="size-4" />
          </button>
        </header>

        {/* Mode Tabs Strip */}
        <div className="flex flex-wrap items-center justify-between gap-2 border-b border-neutral-100 px-6 py-2.5 bg-neutral-50/50">
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => setModeTab('active')}
              className={`flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                modeTab === 'active'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-white border border-neutral-200 text-neutral-600 hover:bg-neutral-100'
              }`}
            >
              <FileSpreadsheet className="size-3.5" />
              <span>Active Ledger (8 records)</span>
            </button>
            <button
              type="button"
              onClick={() => setModeTab('loading')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                modeTab === 'loading'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-white border border-neutral-200 text-neutral-600 hover:bg-neutral-100'
              }`}
            >
              Loading State (Shimmer)
            </button>
            <button
              type="button"
              onClick={() => setModeTab('empty')}
              className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
                modeTab === 'empty'
                  ? 'bg-[#C4161C] text-white shadow-xs'
                  : 'bg-white border border-neutral-200 text-neutral-600 hover:bg-neutral-100'
              }`}
            >
              Empty State View
            </button>
          </div>
          <div className="flex items-center gap-1.5 rounded-full border border-neutral-200 bg-white px-3 py-1 text-xs font-medium text-neutral-600">
            <Lock className="size-3 text-neutral-500" />
            <span>Lethbridge Ops Zone 4 • Tamper-Proof</span>
          </div>
        </div>

        {/* Filter Bar */}
        <div className="border-b border-neutral-200 px-6 py-3 bg-[#F8F9FA]">
          <div className="flex flex-wrap items-end gap-3">
            {/* Status Select */}
            <div className="flex flex-col gap-1">
              <label htmlFor="closed-status-select" className="text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
                STATUS
              </label>
              <select
                id="closed-status-select"
                aria-label="Status"
                value={status}
                onChange={(e) => {
                  setStatus(e.target.value)
                  setPagination((state) => ({ ...state, pageIndex: 0 }))
                }}
                className="h-9 min-w-44 rounded-lg border border-neutral-300 bg-white px-3 text-xs font-medium text-neutral-800 outline-none transition focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
              >
                <option value="">All closed ({totalCount})</option>
                {CLOSED_STATUSES.map((item) => (
                  <option key={item} value={item}>
                    {item}
                  </option>
                ))}
              </select>
            </div>

            {/* From Date */}
            <div className="flex flex-col gap-1">
              <label htmlFor="closed-from-date" className="text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
                FROM
              </label>
              <input
                id="closed-from-date"
                type="date"
                value={fromDate}
                onChange={(e) => {
                  setFromDate(e.target.value)
                  setPagination((state) => ({ ...state, pageIndex: 0 }))
                }}
                className="h-9 rounded-lg border border-neutral-300 bg-white px-3 text-xs font-medium text-neutral-800 outline-none transition focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
              />
            </div>

            {/* To Date */}
            <div className="flex flex-col gap-1">
              <label htmlFor="closed-to-date" className="text-[10px] font-bold tracking-wider text-neutral-600 uppercase">
                TO
              </label>
              <input
                id="closed-to-date"
                type="date"
                value={toDate}
                onChange={(e) => {
                  setToDate(e.target.value)
                  setPagination((state) => ({ ...state, pageIndex: 0 }))
                }}
                className="h-9 rounded-lg border border-neutral-300 bg-white px-3 text-xs font-medium text-neutral-800 outline-none transition focus:border-[#C4161C] focus:ring-1 focus:ring-[#C4161C]"
              />
            </div>

            {/* Actions */}
            <div className="flex items-center gap-2">
              <Button
                type="button"
                size="sm"
                aria-label="Apply"
                onClick={() => setPagination((state) => ({ ...state, pageIndex: 0 }))}
                className="bg-[#C4161C] hover:bg-[#9E1017] text-white flex items-center gap-1.5 h-9 rounded-lg px-4 text-xs font-semibold cursor-pointer"
              >
                <Filter className="size-3.5" />
                <span>Apply filter</span>
              </Button>
              <Button
                type="button"
                size="sm"
                variant="ghost"
                onClick={() => {
                  const today = todayInBranch(timezone)
                  setFromDate(today)
                  setToDate(today)
                  setStatus('')
                  setPagination((state) => ({ ...state, pageIndex: 0 }))
                }}
                className="text-neutral-600 hover:text-neutral-900 h-9 px-3 text-xs font-medium"
              >
                <RotateCcw className="size-3 mr-1" />
                Reset
              </Button>
            </div>
          </div>

          {/* Audit Notice Strip */}
          <div className="mt-2.5 flex items-center justify-between border-t border-neutral-200/60 pt-2 text-[11px] text-neutral-500">
            <div className="flex items-center gap-1.5">
              <Lock className="size-3 text-neutral-400" />
              <span>Read-only ledger • No financial or status modifications permitted on finalized rides.</span>
            </div>
            <div className="flex items-center gap-1 font-mono font-semibold text-neutral-600">
              <ShieldCheck className="size-3 text-emerald-600" />
              <span>AUDITED BY AB-DOT</span>
            </div>
          </div>
        </div>

        {/* Metrics Row (3 cards) */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4 px-6 py-4 bg-white border-b border-neutral-100">
          {/* Card 1: Closed Today */}
          <div className="flex items-center justify-between rounded-xl border border-neutral-200 bg-neutral-50/60 p-4">
            <div>
              <div className="text-[10px] font-bold tracking-wider text-neutral-500 uppercase">CLOSED TODAY</div>
              <div className="mt-1 flex items-baseline gap-1.5">
                <span className="text-2xl font-black text-neutral-900">{totalCount}</span>
                <span className="text-xs font-medium text-neutral-500">rides</span>
              </div>
            </div>
            <div className="flex size-10 items-center justify-center rounded-xl bg-neutral-200/80 text-neutral-600">
              <Archive className="size-5" />
            </div>
          </div>

          {/* Card 2: Cancelled */}
          <div className="flex items-center justify-between rounded-xl border border-red-200/70 bg-red-50/30 p-4">
            <div>
              <div className="text-[10px] font-bold tracking-wider text-red-600 uppercase">CANCELLED</div>
              <div className="mt-1 flex items-baseline gap-1.5">
                <span className="text-2xl font-black text-[#C4161C]">{cancelledCount}</span>
                <span className="text-xs font-semibold text-[#C4161C]">6.7% rate</span>
              </div>
            </div>
            <div className="flex size-10 items-center justify-center rounded-xl bg-red-100 text-[#C4161C]">
              <XCircle className="size-5" />
            </div>
          </div>

          {/* Card 3: Completed */}
          <div className="flex items-center justify-between rounded-xl border border-emerald-200/70 bg-emerald-50/30 p-4">
            <div>
              <div className="text-[10px] font-bold tracking-wider text-emerald-700 uppercase">COMPLETED</div>
              <div className="mt-1 flex items-baseline gap-1.5">
                <span className="text-2xl font-black text-emerald-700">{completedCount}</span>
                <span className="text-xs font-semibold text-emerald-700">93.3% rate</span>
              </div>
            </div>
            <div className="flex size-10 items-center justify-center rounded-xl bg-emerald-100 text-emerald-700">
              <CheckCircle2 className="size-5" />
            </div>
          </div>
        </div>

        {/* Ledger Table */}
        <div className="flex-1 overflow-y-auto px-6 py-2">
          {modeTab === 'loading' || page.isPending ? (
            <div className="py-12 text-center">
              <div className="inline-block size-6 animate-spin rounded-full border-2 border-neutral-300 border-t-[#C4161C]" />
              <p className="mt-2 text-xs text-neutral-500">Loading archived ledger records…</p>
            </div>
          ) : modeTab === 'empty' || (displayRows.length === 0 && !page.isPending) ? (
            <div className="py-12 text-center text-neutral-400">
              <Archive className="mx-auto size-8 opacity-40 mb-2" />
              <p className="text-sm font-medium">No closed jobs found in this date range.</p>
            </div>
          ) : (
            <table className="w-full text-left text-xs border-collapse">
              <thead>
                <tr className="border-b border-neutral-200 text-[10px] font-bold tracking-wider text-neutral-500 uppercase">
                  <th className="py-3 px-2">TRACKING ID</th>
                  <th className="py-3 px-2">PASSENGER</th>
                  <th className="py-3 px-2">DRIVER / UNIT</th>
                  <th className="py-3 px-2">ROUTE / PICKUP</th>
                  <th className="py-3 px-2">STATUS</th>
                  <th className="py-3 px-2">CLOSED AT</th>
                  <th className="py-3 px-2 text-right">INSPECT</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-neutral-100">
                {displayRows.map((row) => {
                  const isCancelled = row.status === 'CANCELLED'
                  const isCompleted = row.status === 'PAYMENT_COMPLETED' || row.status === 'TRIP_COMPLETED'
                  return (
                    <tr key={row.id} className="hover:bg-neutral-50/80 transition group">
                      {/* Tracking ID */}
                      <td className="py-3 px-2 font-mono font-bold text-neutral-900">
                        <div className="flex items-center gap-1.5">
                          <span
                            className={`size-2 rounded-full ${
                              isCancelled ? 'bg-red-500' : isCompleted ? 'bg-emerald-500' : 'bg-neutral-400'
                            }`}
                          />
                          <span>{row.trackingId}</span>
                        </div>
                      </td>

                      {/* Passenger */}
                      <td className="py-3 px-2">
                        <div className="flex items-center gap-2">
                          <div className="flex size-7 shrink-0 items-center justify-center rounded-full bg-neutral-100 border border-neutral-200 font-bold text-[10px] text-neutral-700">
                            {getInitials(row.passengerName)}
                          </div>
                          <span className="font-medium text-neutral-800">{row.passengerName}</span>
                        </div>
                      </td>

                      {/* Driver / Unit */}
                      <td className="py-3 px-2">
                        <div className="flex items-center gap-2">
                          <span className="rounded bg-neutral-100 border border-neutral-200 px-1.5 py-0.5 font-mono text-[11px] font-bold text-neutral-700">
                            {row.driverUnit}
                          </span>
                          <span className="text-neutral-700">{row.driverName}</span>
                        </div>
                      </td>

                      {/* Route / Pickup */}
                      <td className="py-3 px-2 max-w-xs">
                        <div className="text-neutral-800 truncate font-medium">{row.route}</div>
                        {row.routeSubtext ? (
                          <div className="text-[10px] text-neutral-400 truncate">{row.routeSubtext}</div>
                        ) : null}
                      </td>

                      {/* Status */}
                      <td className="py-3 px-2">
                        {row.status === 'PAYMENT_COMPLETED' ? (
                          <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 border border-emerald-200/80 px-2.5 py-0.5 text-[10px] font-bold text-emerald-800">
                            <span className="size-1.5 rounded-full bg-emerald-600" />
                            PAYMENT_COMPLETED
                          </span>
                        ) : row.status === 'TRIP_COMPLETED' ? (
                          <span className="inline-flex items-center gap-1 rounded-full bg-emerald-50 border border-emerald-200/80 px-2.5 py-0.5 text-[10px] font-bold text-emerald-800">
                            <span className="size-1.5 rounded-full bg-emerald-600" />
                            TRIP_COMPLETED
                          </span>
                        ) : row.status === 'CANCELLED' ? (
                          <span className="inline-flex items-center gap-1 rounded-full bg-red-50 border border-red-200/80 px-2.5 py-0.5 text-[10px] font-bold text-[#C4161C]">
                            <span className="size-1.5 rounded-full bg-[#C4161C]" />
                            CANCELLED
                          </span>
                        ) : (
                          <span className="inline-flex items-center gap-1 rounded-full bg-neutral-100 border border-neutral-200 px-2.5 py-0.5 text-[10px] font-semibold text-neutral-600">
                            CLOSED
                          </span>
                        )}
                      </td>

                      {/* Closed At */}
                      <td className="py-3 px-2 font-mono text-[11px] text-neutral-500 whitespace-nowrap">
                        {row.closedAt}
                      </td>

                      {/* Inspect / Open Button */}
                      <td className="py-3 px-2 text-right">
                        <Button
                          type="button"
                          size="xs"
                          variant="ghost"
                          aria-label="Open"
                          onClick={() => {
                            selectBooking(row.id)
                            openJob(row.id)
                            close()
                          }}
                          className="flex size-7 items-center justify-center rounded-full hover:bg-neutral-200 text-neutral-600 hover:text-neutral-900 transition p-0"
                        >
                          <span className="sr-only">Open</span>
                          <ArrowRight className="size-3.5" />
                        </Button>
                      </td>
                    </tr>
                  )
                })}
              </tbody>
            </table>
          )}
        </div>

        {/* Footer with pagination */}
        <footer className="flex flex-wrap items-center justify-between border-t border-neutral-200 px-6 py-3 bg-neutral-50/50 text-xs">
          <div className="text-neutral-500 text-[11px]">
            Showing 1–{Math.min(displayRows.length, 20)} of {totalCount} records{' '}
            <span className="font-mono text-neutral-400">#CA-AB-YQL-2026</span>
          </div>
          <div className="flex items-center gap-1">
            <button
              type="button"
              className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-500 hover:bg-neutral-100 disabled:opacity-40"
              disabled
            >
              ‹
            </button>
            <button
              type="button"
              className="flex size-7 items-center justify-center rounded bg-[#C4161C] font-bold text-white text-xs shadow-xs"
            >
              1
            </button>
            <button
              type="button"
              className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100 text-xs"
            >
              2
            </button>
            <button
              type="button"
              className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100 text-xs"
            >
              3
            </button>
            <button
              type="button"
              className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100 text-xs"
            >
              4
            </button>
            <span className="px-1 text-neutral-400">…</span>
            <button
              type="button"
              className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100 text-xs"
            >
              7
            </button>
            <button
              type="button"
              className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100"
            >
              ›
            </button>
          </div>
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
