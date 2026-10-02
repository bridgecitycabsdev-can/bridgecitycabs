import { useSession } from '@/app/session'
import { UserMenu } from '@/features/auth/user-menu'
import { BookingLists } from '@/features/bookings/booking-lists'
import { BranchSelect } from '@/features/fleet/branch-select'
import { FleetChips } from '@/features/fleet/chips'
import { DriverTable } from '@/features/fleet/driver-table'
import { FleetMap } from '@/features/fleet/fleet-map'
import { FleetSocketProvider } from '@/features/fleet/socket-provider'
import { FLEET_CONN_LABEL, useFleet, type FleetConn } from '@/features/fleet/store'
import { useFleetDrivers } from '@/features/fleet/use-fleet-drivers'

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
        </div>
        <div className="flex items-center gap-3">
          <span className="inline-flex items-center gap-2 text-sm font-medium" data-health={conn}>
            <span className="size-2 rounded-full" style={{ background: CONN_DOT[conn] }} />
            {FLEET_CONN_LABEL[conn]}
          </span>
          <UserMenu />
        </div>
      </header>
      <div className="grid min-h-0 flex-1 grid-cols-1 lg:grid-cols-[minmax(0,1fr)_24rem]">
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
    </div>
  )
}
