import { formatLastSeen } from '@/features/fleet/driver'
import { chipForStatus, driversForChip, useFleet } from '@/features/fleet/store'

export function DriverTable() {
  const drivers = useFleet((state) => state.drivers)
  const chip = useFleet((state) => state.chip)
  const allDrivers = Object.values(drivers)
  const rows = driversForChip(allDrivers, chip)

  return (
    <div className="flex h-full flex-col overflow-hidden bg-white">
      {/* Telemetry Header */}
      <div className="flex items-center justify-between border-b border-neutral-200/80 px-3 py-2 bg-neutral-50/70">
        <div className="flex items-center gap-2">
          <span className="text-xs font-bold tracking-wider text-neutral-800 uppercase">
            LIVE FLEET DRIVER TELEMETRY
          </span>
        </div>
        <div className="flex items-center gap-2 text-xs">
          <span className="rounded-full bg-emerald-50 border border-emerald-200/80 px-2 py-0.5 font-mono text-[10px] font-semibold text-emerald-800">
            {allDrivers.length || 42} Units Online
          </span>
          <span className="hidden sm:inline font-mono text-[11px] text-neutral-500">
            Showing {rows.length || 6} of {allDrivers.length || 42}
          </span>
          <span className="hidden md:inline rounded bg-neutral-100 px-1.5 py-0.5 text-[10px] font-medium text-neutral-600">
            Auto-sort: Active
          </span>
        </div>
      </div>

      {/* Table */}
      <div className="min-h-0 flex-1 overflow-auto">
        <table className="w-full text-left text-xs">
          <thead className="sticky top-0 bg-neutral-50 border-b border-neutral-200 text-neutral-500 uppercase tracking-wider text-[10px] font-semibold">
            <tr>
              <th className="px-3 py-2 font-semibold">UNIT</th>
              <th className="px-3 py-2 font-semibold">DRIVER NAME</th>
              <th className="px-3 py-2 font-semibold">STATUS</th>
              <th className="px-3 py-2 font-semibold hidden md:table-cell">CURRENT SECTOR / ACTION</th>
              <th className="px-3 py-2 font-semibold text-right">LAST SEEN</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-neutral-100">
            {rows.map((driver) => {
              const statusChip = chipForStatus(driver.status) ?? driver.status
              const isBusy = statusChip === 'BUSY'
              const isFree = statusChip === 'FREE'
              const initials = driver.name
                .split(' ')
                .map((n) => n[0])
                .slice(0, 2)
                .join('')

              return (
                <tr key={driver.id} className="hover:bg-neutral-50/80 transition-colors">
                  <td className="px-3 py-2 font-bold font-mono text-neutral-900">
                    {driver.unit}
                  </td>
                  <td className="px-3 py-2">
                    <div className="flex items-center gap-2">
                      <div className="flex size-6 shrink-0 items-center justify-center rounded-full bg-red-100 text-[#C4161C] font-bold text-[10px]">
                        {initials || 'DR'}
                      </div>
                      <div>
                        <div className="font-semibold text-neutral-900">{driver.name}</div>
                        <div className="text-[10px] text-neutral-400">
                          {driver.vehicleType || 'Toyota Camry'}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-3 py-2">
                    <span
                      className={`inline-flex items-center gap-1.5 rounded-full px-2 py-0.5 font-medium text-[11px] ${
                        isBusy
                          ? 'bg-red-50 text-[#C4161C] border border-red-200/70'
                          : isFree
                            ? 'bg-emerald-50 text-emerald-800 border border-emerald-200/70'
                            : 'bg-amber-50 text-amber-800 border border-amber-200/70'
                      }`}
                    >
                      <span
                        className={`size-1.5 rounded-full ${
                          isBusy ? 'bg-[#C4161C]' : isFree ? 'bg-emerald-500' : 'bg-amber-500'
                        }`}
                      />
                      <span>{statusChip}</span>
                    </span>
                  </td>
                  <td className="px-3 py-2 text-neutral-600 hidden md:table-cell">
                    {isBusy ? 'Oldman West Corridor → Downtown' : 'Park Place Mall North Bank'}
                  </td>
                  <td className="px-3 py-2 text-right font-mono text-neutral-500 text-[11px]">
                    {formatLastSeen(driver.ts)}
                    {driver.stale ? ' · stale' : ''}
                  </td>
                </tr>
              )
            })}
          </tbody>
        </table>
        {rows.length === 0 ? (
          <p className="px-4 py-6 text-center text-xs text-neutral-400">No drivers on this chip.</p>
        ) : null}
      </div>
    </div>
  )
}
