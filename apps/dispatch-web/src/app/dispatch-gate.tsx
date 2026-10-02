import type { ReactNode } from 'react'
import { Navigate } from 'react-router-dom'
import { useSession } from '@/app/session'

const DISPATCH_ROLES = new Set(['super_admin', 'branch_admin', 'dispatcher', 'customer_care'])

export function canOpenDispatch(role: string | undefined) {
  return role !== undefined && DISPATCH_ROLES.has(role)
}

export function DispatchGate({ children }: { children: ReactNode }) {
  const accessToken = useSession((state) => state.accessToken)
  const role = useSession((state) => state.profile?.role.name)
  if (!accessToken) return <Navigate to="/login" replace />
  if (!canOpenDispatch(role)) return <Navigate to="/no-access" replace />
  return children
}
