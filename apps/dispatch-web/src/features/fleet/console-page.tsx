import { useQuery } from '@tanstack/react-query'
import { Bell, Car, ChevronDown, Headphones, Sliders } from 'lucide-react'
import { useEffect, useState } from 'react'
import { useSession } from '@/app/session'
import { UserMenu } from '@/features/auth/user-menu'
import { BookingLists } from '@/features/bookings/booking-lists'
import { BranchClock } from '@/features/bookings/BranchClock'
import { ClosedJobsModal } from '@/features/bookings/ClosedJobsModal'
import { JobDetailsModal } from '@/features/bookings/JobDetailsModal'
import { PaymentPendingJobsModal } from '@/features/bookings/PaymentPendingJobsModal'
import { useBookingUi } from '@/features/bookings/selection'
import { TimeoutJobsModal } from '@/features/bookings/TimeoutJobsModal'
import { NewJobPanel } from '@/features/dispatch/drafts/NewJobPanel'
import { dispatchConfigSchema } from '@/features/dispatch/drafts/schema'
import { BranchSelect } from '@/features/fleet/branch-select'
import { FleetChips } from '@/features/fleet/chips'
import { DriverTable } from '@/features/fleet/driver-table'
import { FleetMap } from '@/features/fleet/fleet-map'
import { FleetSocketProvider } from '@/features/fleet/socket-provider'
import { FLEET_CONN_LABEL, useFleet, type FleetConn } from '@/features/fleet/store'
import { useFleetDrivers } from '@/features/fleet/use-fleet-drivers'
import { api, jsonBody } from '@/lib/api'

const CONN_DOT: Record<FleetConn, string> = {
  live: 'var(--color-success)',
  reconnecting: '#B86E00',
  offline: 'var(--color-danger)',
}

export function ConsolePage() {
  return (
    <FleetSocketProvider>
      <ConsoleLayout />
    </FleetSocketProvider>
  )
}

function ConsoleLayout() {
  const profile = useSession((state) => state.profile)
  const conn = useFleet((state) => state.conn)
  const fleet = useFleetDrivers()
  const toast = useBookingUi((state) => state.toast)
  const setToast = useBookingUi((state) => state.setToast)
  const branchId = useBranchId()
  const [activeTab, setActiveTab] = useState<'dispatch' | 'fleets' | 'reports' | 'config'>('dispatch')

  const config = useQuery({
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
  const timezone = config.data?.timezone ?? 'America/Edmonton'

  useEffect(() => {
    if (!toast) return
    const timer = window.setTimeout(() => setToast(null), 3200)
    return () => window.clearTimeout(timer)
  }, [setToast, toast])

  const branchTitle = profile?.branch?.name ?? 'Lethbridge Branch (YQL)'

  return (
    <div className="flex h-screen flex-col bg-[#F3F4F6] text-neutral-900 font-sans antialiased overflow-hidden">
      {/* Top Application Header Bar */}
      <header className="flex h-14 shrink-0 items-center justify-between gap-3 border-b border-neutral-200/90 bg-white px-3 sm:px-4 shadow-xs z-20">
        {/* Left branding & branch */}
        <div className="flex min-w-0 items-center gap-3">
          <div className="flex items-center gap-2.5">
            <div className="flex size-9 items-center justify-center rounded-xl bg-[#C4161C] text-white shadow-xs">
              <Car className="size-5" />
            </div>
            <div>
              <div className="flex items-center gap-1.5 leading-none">
                <span className="text-sm font-bold tracking-tight text-neutral-900">BridgeCabs Dispatch</span>
                <span className="rounded bg-neutral-100 px-1.5 py-0.5 font-mono text-[10px] font-semibold text-neutral-600">
                  OPS v4.8
                </span>
              </div>
              <div className="text-[10px] text-neutral-500 font-medium mt-0.5 truncate hidden sm:block">
                Lethbridge Regional Urban Network
              </div>
            </div>
          </div>

          <div className="h-5 w-px bg-neutral-200 hidden md:block" />

          {/* Branch Pill */}
          <div className="hidden lg:flex items-center gap-1.5 rounded-full border border-neutral-200 bg-neutral-50 px-3 py-1 text-xs font-semibold text-neutral-800">
            <span className="size-2 rounded-full bg-[#C4161C]" />
            {profile?.role.name === 'super_admin' ? (
              <BranchSelect />
            ) : (
              <span className="truncate">{branchTitle}</span>
            )}
            <ChevronDown className="size-3 text-neutral-400" />
          </div>

          {/* Support Ticket Badge Pill */}
          <div className="hidden md:flex items-center gap-1.5 rounded-full border border-red-200/80 bg-red-50/60 px-2.5 py-1 text-xs font-semibold text-[#C4161C]">
            <Headphones className="size-3" />
            <span>Support</span>
            <span className="rounded-full bg-[#C4161C] text-white text-[10px] size-4 flex items-center justify-center font-bold">
              7
            </span>
          </div>

          {/* Clock Pill */}
          <div className="hidden xl:flex items-center rounded-full border border-neutral-200 bg-neutral-50 px-3 py-1">
            <BranchClock timezone={timezone} />
          </div>

          {/* Status Live Pill */}
          <div
            className="hidden sm:inline-flex items-center gap-1.5 rounded-full border border-emerald-200/80 bg-emerald-50 px-2.5 py-1 text-xs font-semibold text-emerald-800"
            data-health={conn}
          >
            <span className="size-2 rounded-full" style={{ background: CONN_DOT[conn] }} />
            <span>{FLEET_CONN_LABEL[conn]}</span>
          </div>

          {/* Primary Node Ping Pill */}
          <div className="hidden 2xl:flex items-center rounded-full border border-neutral-200 bg-neutral-50 px-2.5 py-1 text-[11px] font-mono text-neutral-600">
            Primary Node • Ping 18ms
          </div>
        </div>

        {/* Center Navigation Tabs */}
        <nav className="flex items-center gap-1 bg-neutral-100/90 p-1 rounded-full border border-neutral-200/80">
          <button
            type="button"
            onClick={() => setActiveTab('dispatch')}
            className={`flex items-center gap-1.5 rounded-full px-3.5 py-1 text-xs font-semibold transition cursor-pointer ${
              activeTab === 'dispatch'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'text-neutral-600 hover:text-neutral-900'
            }`}
          >
            <span className={`size-1.5 rounded-full ${activeTab === 'dispatch' ? 'bg-white' : 'bg-[#C4161C]'}`} />
            <span>Dispatch</span>
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('fleets')}
            className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
              activeTab === 'fleets'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'text-neutral-600 hover:text-neutral-900'
            }`}
          >
            Fleets
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('reports')}
            className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
              activeTab === 'reports'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'text-neutral-600 hover:text-neutral-900'
            }`}
          >
            Reports
          </button>
          <button
            type="button"
            onClick={() => setActiveTab('config')}
            className={`rounded-full px-3 py-1 text-xs font-semibold transition cursor-pointer ${
              activeTab === 'config'
                ? 'bg-[#C4161C] text-white shadow-xs'
                : 'text-neutral-600 hover:text-neutral-900'
            }`}
          >
            Config
          </button>
        </nav>

        {/* Right Notification & Profile */}
        <div className="flex items-center gap-2.5">
          <button
            type="button"
            aria-label="Notifications"
            className="relative flex size-8 items-center justify-center rounded-lg border border-neutral-200 bg-white text-neutral-600 hover:text-neutral-900 shadow-xs cursor-pointer"
          >
            <Bell className="size-4" />
            <span className="absolute -top-1 -right-1 flex size-2.5">
              <span className="absolute inline-flex h-full w-full animate-ping rounded-full bg-[#C4161C] opacity-75" />
              <span className="relative inline-flex size-2.5 rounded-full bg-[#C4161C]" />
            </span>
          </button>
          <UserMenu />
        </div>
      </header>

      {/* Console State Simulator Bar */}
      <div className="flex h-9 shrink-0 items-center justify-between border-b border-neutral-200/90 bg-[#F9FAFB] px-4 text-xs z-10">
        <div className="flex items-center gap-2 overflow-x-auto py-1">
          <Sliders className="size-3 text-neutral-500 shrink-0" />
          <span className="font-bold text-[10px] tracking-wider text-neutral-500 uppercase whitespace-nowrap">
            CONSOLE STATE SIMULATOR:
          </span>
          <button
            type="button"
            className="rounded-full bg-white border border-neutral-200 hover:border-neutral-300 px-2.5 py-0.5 text-[11px] font-medium text-neutral-700 shadow-2xs whitespace-nowrap cursor-pointer"
          >
            Frame 1: SOS Strip & Alert States
          </button>
          <button
            type="button"
            className="rounded-full bg-white border border-neutral-200 hover:border-neutral-300 px-2.5 py-0.5 text-[11px] font-medium text-neutral-700 shadow-2xs whitespace-nowrap cursor-pointer"
          >
            Frame 2: Header Support & Nav
          </button>
          <button
            type="button"
            className="rounded-full bg-white border border-neutral-200 hover:border-neutral-300 px-2.5 py-0.5 text-[11px] font-medium text-neutral-700 shadow-2xs whitespace-nowrap cursor-pointer"
          >
            Frame 3: Driver Side Panel
          </button>
        </div>
        <div className="font-mono text-[11px] text-neutral-500 hidden sm:block whitespace-nowrap pl-2">
          Lethbridge CAD Sync • 24ms
        </div>
      </div>

      {/* Main 3-Column Operational Board */}
      <div className="grid min-h-0 flex-1 grid-cols-1 lg:grid-cols-[23rem_minmax(0,1fr)_26rem] divide-y lg:divide-y-0 lg:divide-x divide-neutral-200">
        {/* Left Column: New Dispatch Job Panel */}
        <aside className="flex min-h-0 flex-col bg-white overflow-hidden">
          <NewJobPanel />
        </aside>

        {/* Center Column: Live Map & Driver Telemetry */}
        <section className="flex min-h-0 flex-col bg-white overflow-hidden">
          {/* Top: Fleet Map */}
          <div className="relative min-h-80 flex-1 bg-slate-50">
            <FleetMap />
            {/* Status chips overlay on top of map */}
            <div className="pointer-events-none absolute inset-x-0 top-0 z-10 p-3">
              <div className="pointer-events-auto flex items-center justify-start">
                <FleetChips />
              </div>
            </div>
          </div>

          {/* Bottom: Live Driver Telemetry Table */}
          <div className="flex h-56 shrink-0 flex-col border-t border-neutral-200 bg-white">
            {fleet.isError ? (
              <p className="text-destructive px-3 py-2 text-xs">Could not load the fleet.</p>
            ) : null}
            <div className="min-h-0 flex-1">
              <DriverTable />
            </div>
          </div>
        </section>

        {/* Right Column: Active Jobs Board */}
        <aside className="flex min-h-0 flex-col bg-white overflow-hidden">
          <BookingLists />
        </aside>
      </div>

      {/* Operational Modals */}
      <JobDetailsModal />
      <TimeoutJobsModal />
      <PaymentPendingJobsModal />
      <ClosedJobsModal />

      {/* Floating Global Toast */}
      {toast ? (
        <div
          role="status"
          className="bg-neutral-900 text-white fixed bottom-4 left-1/2 z-[60] max-w-sm -translate-x-1/2 rounded-lg px-4 py-2.5 text-xs font-semibold shadow-xl flex items-center gap-2 animate-fade-in"
        >
          <span className="size-2 rounded-full bg-emerald-400" />
          <span>{toast}</span>
        </div>
      ) : null}
    </div>
  )
}

function useBranchId() {
  const role = useSession((state) => state.profile?.role.name)
  const selected = useSession((state) => state.branchId)
  const own = useSession((state) => state.profile?.branch?.id)
  return role === 'super_admin' ? selected : (own ?? null)
}
