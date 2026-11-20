import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { DashboardPage } from '@/features/dashboard/dashboard-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'ada@bridgecabs.test',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'dispatcher' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Dashboard page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders admin operations dashboard with all KPI metrics and charts', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <DashboardPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByText('ACTIVE DRIVERS')).toBeTruthy()
    expect(screen.getByText('TRIPS TODAY')).toBeTruthy()
    expect(screen.getByText('REVENUE TODAY')).toBeTruthy()
    expect(screen.getByText('CANCELLED')).toBeTruthy()
    expect(screen.getByText('Rides over time')).toBeTruthy()
    expect(screen.getByText('Booking source')).toBeTruthy()
    expect(screen.getByText('Daily settlement breakdown')).toBeTruthy()
    expect(screen.getByText('Today by hour')).toBeTruthy()
    expect(screen.getByText('FRIDAY PEAK')).toBeTruthy()
    expect(screen.getByText('TOTAL RIDES')).toBeTruthy()
  })
})
