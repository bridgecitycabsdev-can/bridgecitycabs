import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { PayoutsPage } from '@/features/payouts/payouts-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Payouts page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders payouts list, KPI cards, and driver records', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <PayoutsPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByText('Frame 1: Payout List (Active)')).toBeTruthy()
    expect(screen.getAllByText('PENDING').length).toBeGreaterThan(0)
    expect(screen.getByText('$4,860.20')).toBeTruthy()
    expect(screen.getByText('SENT THIS WEEK')).toBeTruthy()
    expect(screen.getByText('$12,330.00')).toBeTruthy()
    expect(screen.getByText('Interac E-Transfer Only')).toBeTruthy()
    expect(screen.getByText('Harpreet Singh')).toBeTruthy()
    expect(screen.getByText('Sarah Jenkins')).toBeTruthy()
    expect(screen.getByText('Derek Miller')).toBeTruthy()
  })

  it('switches to Frame 3 and Frame 4 on interactive actions', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <PayoutsPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    // Click Frame 3
    fireEvent.click(screen.getByText('Frame 3: Status Actions (Mark Sent/Failed)'))
    expect(screen.getByText('Dual Financial State Transitions: Mark Sent & Mark Failed')).toBeTruthy()
    expect(screen.getByText('Audit Trail & State Transition Matrix')).toBeTruthy()

    // Click Frame 4
    fireEvent.click(screen.getByText('Frame 4: Failed Guidance & Reversal'))
    expect(screen.getByText('Critical Accounting Hold: Payout Failed')).toBeTruthy()
    expect(screen.getByText('Resolution Protocol & Reversal Procedure')).toBeTruthy()
    expect(screen.getByText('Proposed Reversal Journal Entry')).toBeTruthy()
  })
})
