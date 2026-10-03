import { useQuery } from '@tanstack/react-query'
import { useEffect } from 'react'
import { useSession } from '@/app/session'
import { UserMenu } from '@/features/auth/user-menu'
import { BookingLists } from '@/features/bookings/booking-lists'
import { BranchClock } from '@/features/bookings/BranchClock'
import { ClosedJobsModal } from '@/features/bookings/ClosedJobsModal'
import { JobDetailsModal } from '@/features/bookings/JobDetailsModal'
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

  return (
    <div className="flex h-full flex-col">
      <header className="flex items-center justify-between gap-3 border-b px-4 py-2.5">
        <div className="flex min-w-0 items-center gap-4">
          <p className="text-sm font-semibold">BridgeCabs Dispatch</p>
          {profile?.role.name === 'super_admin' ? (
            <BranchSelect />
          ) : (
            <p className="text-muted-foreground truncate text-sm">
              {profile?.branch?.name ?? profile?.role.name ?? 'Dispatch'}
            </p>
          )}
          <BranchClock timezone={timezone} />
        </div>
        <div className="flex items-center gap-3">
          <span className="inline-flex items-center gap-2 text-sm font-medium" data-health={conn}>
            <span className="size-2 rounded-full" style={{ background: CONN_DOT[conn] }} />
            {FLEET_CONN_LABEL[conn]}
          </span>
          <UserMenu />
        </div>
      </header>
      <div className="grid min-h-0 flex-1 grid-cols-1 lg:grid-cols-[22rem_minmax(0,1fr)_24rem]">
        <aside className="flex min-h-0 flex-col border-b lg:border-r lg:border-b-0">
          <NewJobPanel />
        </aside>
        <section className="flex min-h-0 flex-col">
          <div className="relative min-h-80 flex-1">
            <FleetMap />
            <div className="pointer-events-none absolute inset-x-0 top-0 z-10 p-3">
              <div className="pointer-events-auto">
                <FleetChips />
              </div>
            </div>
          </div>
          <div className="bg-card flex h-52 shrink-0 flex-col border-t">
            {fleet.isError ? (
              <p className="text-destructive px-3 py-2 text-sm">Could not load the fleet.</p>
            ) : null}
            <div className="min-h-0 flex-1">
              <DriverTable />
            </div>
          </div>
        </section>
        <aside className="flex min-h-0 flex-col border-t lg:border-t-0 lg:border-l">
          <BookingLists />
        </aside>
      </div>
      <JobDetailsModal />
      <TimeoutJobsModal />
      <ClosedJobsModal />
      {toast ? (
        <div
          role="status"
          className="bg-foreground text-background fixed bottom-4 left-1/2 z-[60] max-w-sm -translate-x-1/2 rounded-md px-3 py-2 text-sm shadow-lg"
        >
          {toast}
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
