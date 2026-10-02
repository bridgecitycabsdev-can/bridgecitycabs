import { useQuery } from '@tanstack/react-query'
import { useEffect } from 'react'
import { useSession } from '@/app/session'
import { fleetDriversSchema, toFleetDriver } from '@/features/fleet/driver'
import { useFleet } from '@/features/fleet/store'
import { api, jsonBody } from '@/lib/api'

export function useFleetDrivers() {
  const role = useSession((state) => state.profile?.role.name)
  const profileBranchId = useSession((state) => state.profile?.branch?.id)
  const selectedBranchId = useSession((state) => state.branchId)
  const branchId = role === 'super_admin' ? selectedBranchId : profileBranchId
  const replace = useFleet((state) => state.replace)
  const query = useQuery({
    queryKey: ['fleet', 'drivers', branchId ?? null],
    enabled: role !== 'super_admin' || Boolean(branchId),
    queryFn: async () => {
      const result = await api.GET('/api/v1/fleet/drivers', {
        params: { query: branchId ? { branchId } : {} },
      })
      if (!result.response.ok) throw new Error('Could not load drivers')
      return fleetDriversSchema.parse(await jsonBody(result))
    },
  })

  useEffect(() => {
    if (!query.data) return
    replace(query.data.drivers.flatMap((driver) => {
      const fleet = toFleetDriver(driver)
      return fleet ? [fleet] : []
    }))
  }, [query.data, replace])

  return query
}
