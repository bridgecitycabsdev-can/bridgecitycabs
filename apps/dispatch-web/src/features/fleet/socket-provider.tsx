import { useQueryClient } from '@tanstack/react-query'
import { useEffect, type ReactNode } from 'react'
import { useSession } from '@/app/session'
import { ensureFleetSocket, subscribeFleet } from '@/features/fleet/socket'

export function FleetSocketProvider({ children }: { children: ReactNode }) {
  const queryClient = useQueryClient()
  const branchId = useSession((state) => state.branchId)
  const role = useSession((state) => state.profile?.role.name)

  useEffect(() => {
    ensureFleetSocket(queryClient)
  }, [queryClient])

  useEffect(() => {
    if (role === 'super_admin' && branchId) subscribeFleet(branchId)
  }, [branchId, role])

  return children
}
