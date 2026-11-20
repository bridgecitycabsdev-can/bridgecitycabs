import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { UsersPage } from '@/features/users/users-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Users page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders Frame 1: User Directory with staff list and federation status', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <UsersPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByRole('heading', { name: 'Users', level: 1 })).toBeTruthy()
    expect(screen.getByText('Super admin only')).toBeTruthy()
    expect(screen.getByText('Federated Provisioning (Okta Active)')).toBeTruthy()

    // Staff names
    expect(screen.getAllByText('Priya V.').length).toBeGreaterThanOrEqual(1)
    expect(screen.getByText('Dave Vance')).toBeTruthy()
    expect(screen.getByText('Marcus Vance')).toBeTruthy()
    expect(screen.getByText('Tariq Al-Mansoor')).toBeTruthy()
  })

  it('navigates to Frame 2: Change Role Dialog and selects role tier', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <UsersPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 2: Change Role Dialog'))
    expect(screen.getByText('Change User Role')).toBeTruthy()
    expect(screen.getByText('Select New Role')).toBeTruthy()
    expect(screen.getByText('Tier 1 (Branch Head)')).toBeTruthy()
    expect(screen.getByText(/Confirm & Update Role/i)).toBeTruthy()
  })

  it('navigates to Frame 3: Result & Edge States', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <UsersPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText(/Frame 3: Result/))
    expect(screen.getByText('System State Responses')).toBeTruthy()
    expect(screen.getByText('Panel 1: Direct Row Transition')).toBeTruthy()
    expect(screen.getByText(/Role updated to Branch admin for Dave Vance/)).toBeTruthy()
    expect(screen.getByText('Panel 2: SSO Gateway Failure')).toBeTruthy()
    expect(screen.getByText('Panel 3: Zero Match Intercept')).toBeTruthy()
  })

  it('navigates to Frame 4: No-Access Gated State', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <UsersPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 4: No-Access Gated State'))
    expect(screen.getByText('Access restricted')).toBeTruthy()
    expect(screen.getByText('Users are managed by super admins only.')).toBeTruthy()
    expect(screen.getByText(/Dave Vance \(Callsign DISP-04\)/)).toBeTruthy()
    expect(screen.getByText(/RBAC Policy Matrix/i)).toBeTruthy()
  })
})
