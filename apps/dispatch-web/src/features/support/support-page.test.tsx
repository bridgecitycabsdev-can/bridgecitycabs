import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { SupportPage } from '@/features/support/support-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Support page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders ticket queue, KPI cards, and ticket list', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <SupportPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByText('Frame 1: Ticket List')).toBeTruthy()
    expect(screen.getByText('New ticket')).toBeTruthy()
    expect(screen.getAllByText('OPEN').length).toBeGreaterThan(0)
    expect(screen.getByText('Unassigned queue')).toBeTruthy()
    expect(screen.getByText('In active triage')).toBeTruthy()
    expect(screen.getByText('RESOLVED TODAY')).toBeTruthy()
    expect(screen.getByText('AVG FIRST REPLY')).toBeTruthy()
    expect(screen.getByText('TCK-1042')).toBeTruthy()
    expect(screen.getByText('Driver did not arrive at pickup')).toBeTruthy()
  })
})
