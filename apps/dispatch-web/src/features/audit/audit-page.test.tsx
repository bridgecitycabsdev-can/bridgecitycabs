import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { AuditPage } from '@/features/audit/audit-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Audit page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders Frame 1: Audit Log Directory with logs and filters', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <AuditPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByRole('heading', { name: 'Audit log', level: 1 })).toBeTruthy()
    expect(screen.getByText('Super admin only')).toBeTruthy()
    expect(screen.getByText('Total Records: 48,219')).toBeTruthy()

    // Log entries
    expect(screen.getByText('fr_rule_8812')).toBeTruthy()
    expect(screen.getByText('bk_10492')).toBeTruthy()
    expect(screen.getByText('pay_2026_w46')).toBeTruthy()
  })

  it('navigates to Frame 2: Entry Detail Side Panel and filters by entity', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <AuditPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 2: Entry Detail Side Panel'))
    expect(screen.getByText('Audit Entry Detail')).toBeTruthy()
    expect(screen.getByText('EVENT DOSSIER')).toBeTruthy()
    expect(screen.getByText('WORM Verified')).toBeTruthy()
    expect(screen.getByText('Filter by this entity')).toBeTruthy()
  })

  it('navigates to Frame 3: Empty & Error States with cluster outage banner', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <AuditPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 3: Empty & Error States'))
    expect(screen.getByText('STATE 01: Empty Search Results')).toBeTruthy()
    expect(screen.getByText('STATE 02: Cluster Outage / Error')).toBeTruthy()
    expect(screen.getByText('Could not load the audit log.')).toBeTruthy()
    expect(screen.getByText('ERR_AUDIT_SERVICE_TIMEOUT')).toBeTruthy()
    expect(screen.getByText('504 GATEWAY TIMEOUT')).toBeTruthy()
  })

  it('navigates to Frame 4: No-Access Gated State and RBAC policy matrix', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <AuditPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 4: No-Access Gated State'))
    expect(screen.getByText('Access restricted')).toBeTruthy()
    expect(screen.getByText('The audit log is for super admins only.')).toBeTruthy()
    expect(screen.getByText(/Dave Vance \(Callsign DISP-04\)/)).toBeTruthy()
    expect(screen.getByText('RBAC Policy Matrix')).toBeTruthy()
  })
})
