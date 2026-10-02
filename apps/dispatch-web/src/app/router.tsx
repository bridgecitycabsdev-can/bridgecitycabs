import { Navigate, Route, Routes } from 'react-router-dom'
import { canOpenDispatch, DispatchGate } from '@/app/dispatch-gate'
import { useSession } from '@/app/session'
import { LoginPage } from '@/features/auth/login-page'
import { NoAccessPage } from '@/features/auth/no-access-page'
import { ConsolePage } from '@/features/fleet/console-page'

function HomeRedirect() {
  const accessToken = useSession((state) => state.accessToken)
  const role = useSession((state) => state.profile?.role.name)
  if (!accessToken) return <Navigate to="/login" replace />
  if (!canOpenDispatch(role)) return <Navigate to="/no-access" replace />
  return <Navigate to="/dispatch" replace />
}

function NoAccessRoute() {
  const accessToken = useSession((state) => state.accessToken)
  const role = useSession((state) => state.profile?.role.name)
  if (!accessToken) return <Navigate to="/login" replace />
  if (canOpenDispatch(role)) return <Navigate to="/dispatch" replace />
  return <NoAccessPage />
}

export function AppRouter() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/dispatch" element={<DispatchGate><ConsolePage /></DispatchGate>} />
      <Route path="/no-access" element={<NoAccessRoute />} />
      <Route path="/" element={<HomeRedirect />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
