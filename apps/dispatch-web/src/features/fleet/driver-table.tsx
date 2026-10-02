import { formatLastSeen } from '@/features/fleet/driver'
import { chipForStatus, driversForChip, useFleet } from '@/features/fleet/store'

export function DriverTable() {
  const drivers = useFleet((state) => state.drivers)
  const chip = useFleet((state) => state.chip)
  const rows = driversForChip(Object.values(drivers), chip)

  return (
    <div className="h-full overflow-auto">
      <table className="w-full text-left text-sm">
        <thead className="text-muted-foreground sticky top-0 bg-card text-xs">
          <tr>
            <th className="px-3 py-2 font-medium">Unit</th>
            <th className="px-3 py-2 font-medium">Name</th>
            <th className="px-3 py-2 font-medium">Status</th>
            <th className="px-3 py-2 font-medium">Last seen</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((driver) => (
            <tr key={driver.id} className="border-t">
              <td className="px-3 py-1.5 font-medium">{driver.unit}</td>
              <td className="px-3 py-1.5">{driver.name}</td>
              <td className="px-3 py-1.5">{chipForStatus(driver.status) ?? driver.status}</td>
              <td className="text-muted-foreground px-3 py-1.5">
                {formatLastSeen(driver.ts)}
                {driver.stale ? ' · stale' : ''}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      {rows.length === 0 ? <p className="text-muted-foreground px-3 py-3 text-sm">No drivers on this chip.</p> : null}
    </div>
  )
}
