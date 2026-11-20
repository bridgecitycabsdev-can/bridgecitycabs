import { Navigate, Route, Routes } from 'react-router-dom'
import { canOpenDispatch, DispatchGate } from '@/app/dispatch-gate'
import { useSession } from '@/app/session'
import { LoginPage } from '@/features/auth/login-page'
import { NoAccessPage } from '@/features/auth/no-access-page'
import { AuditPage } from '@/features/audit/audit-page'
import { BranchesPage } from '@/features/branches/branches-page'
import { CorporatePage } from '@/features/corporate/corporate-page'
import { DashboardPage } from '@/features/dashboard/dashboard-page'
import { DriversPage } from '@/features/drivers/drivers-page'
import { ConsolePage } from '@/features/fleet/console-page'
import { InvoicesPage } from '@/features/invoices/invoices-page'
import { LeasesPage } from '@/features/leases/leases-page'
import { LedgerPage } from '@/features/ledger/ledger-page'
import { PassengersPage } from '@/features/passengers/passengers-page'
import { PayoutsPage } from '@/features/payouts/payouts-page'
import { ReportsPage } from '@/features/reports/reports-page'
import { SupportPage } from '@/features/support/support-page'
import { UsersPage } from '@/features/users/users-page'
import { VehiclesPage } from '@/features/vehicles/vehicles-page'
import { WeeklyClosingPage } from '@/features/weekly-closing/weekly-closing-page'

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
      <Route path="/dashboard" element={<DispatchGate><DashboardPage /></DispatchGate>} />
      <Route path="/drivers" element={<DispatchGate><DriversPage /></DispatchGate>} />
      <Route path="/passengers" element={<DispatchGate><PassengersPage /></DispatchGate>} />
      <Route path="/vehicles" element={<DispatchGate><VehiclesPage /></DispatchGate>} />
      <Route path="/support" element={<DispatchGate><SupportPage /></DispatchGate>} />
      <Route path="/corporate" element={<DispatchGate><CorporatePage /></DispatchGate>} />
      <Route path="/invoices" element={<DispatchGate><InvoicesPage /></DispatchGate>} />
      <Route path="/payouts" element={<DispatchGate><PayoutsPage /></DispatchGate>} />
      <Route path="/weekly-closing" element={<DispatchGate><WeeklyClosingPage /></DispatchGate>} />
      <Route path="/ledger" element={<DispatchGate><LedgerPage /></DispatchGate>} />
      <Route path="/leases" element={<DispatchGate><LeasesPage /></DispatchGate>} />
      <Route path="/branches" element={<DispatchGate><BranchesPage /></DispatchGate>} />
      <Route path="/reports" element={<DispatchGate><ReportsPage /></DispatchGate>} />
      <Route path="/audit" element={<DispatchGate><AuditPage /></DispatchGate>} />
      <Route path="/users" element={<DispatchGate><UsersPage /></DispatchGate>} />
      <Route path="/no-access" element={<NoAccessRoute />} />
      <Route path="/" element={<HomeRedirect />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
