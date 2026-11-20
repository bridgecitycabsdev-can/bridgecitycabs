import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { ReportsPage } from '@/features/reports/reports-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Reports page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders Frame 1: Builder & Past Reports with builder form and past reports table', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <ReportsPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByRole('heading', { name: 'Reports', level: 1 })).toBeTruthy()
    expect(screen.getByText('8 Archives')).toBeTruthy()
    expect(screen.getByText('Booking report')).toBeTruthy()
    expect(screen.getByText('Generate report')).toBeTruthy()

    // Past reports table
    expect(screen.getByText('booking-report-2026-11-01_to_2026-11-15.csv')).toBeTruthy()
    expect(screen.getByText('shift-manifest-w44-yql.csv')).toBeTruthy()
    expect(screen.getByText('full-quarter-q3-2026-telemetry.csv')).toBeTruthy()
  })

  it('navigates to Frame 2: Generating State with progress telemetry', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <ReportsPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 2: Generating State'))
    expect(screen.getByText('GENERATING IN BACKGROUND...')).toBeTruthy()
    expect(screen.getByText('Preparing your report')).toBeTruthy()
    expect(screen.getByText(/62% complete/)).toBeTruthy()
    expect(screen.getByText('Cancel query')).toBeTruthy()
    expect(screen.getByText('Fast ETL Processing')).toBeTruthy()
  })

  it('navigates to Frame 3: Ready State & Instant Download and handles download', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <ReportsPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 3: Ready & Instant Download'))
    expect(screen.getByText('Your report is ready for download')).toBeTruthy()
    expect(screen.getByText('Download Report (.CSV)')).toBeTruthy()
    expect(screen.getByText('Small Range: Instant Download')).toBeTruthy()
    expect(screen.getByText(/Failure & Recovery State/)).toBeTruthy()

    // Click download report button to trigger toast
    fireEvent.click(screen.getByText('Download Report (.CSV)'))
    expect(screen.getByText('Report downloaded')).toBeTruthy()
  })

  it('navigates to Frame 4: Role Variants & Edge Conditions', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <ReportsPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 4: Role Variants'))
    expect(screen.getByText('Access Tiers & Edge Conditions')).toBeTruthy()
    expect(screen.getByText('Report generation restricted')).toBeTruthy()
    expect(screen.getByText('Available Operational Reports')).toBeTruthy()
    expect(screen.getByText('Daily Shift Manifest - South Lethbridge')).toBeTruthy()
    expect(screen.getByText('No reports yet')).toBeTruthy()
  })
})
