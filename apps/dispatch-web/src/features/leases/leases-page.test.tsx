import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { LeasesPage } from '@/features/leases/leases-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Vehicle Leases page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders Frame 1: Lease Grid with KPIs and lease cards', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <LeasesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByRole('heading', { name: 'Leases', level: 1 })).toBeTruthy()
    expect(screen.getByText('ACTIVE LEASES')).toBeTruthy()
    expect(screen.getByText('WEEKLY TOTAL REVENUE')).toBeTruthy()
    expect(screen.getByText('$9,840.00')).toBeTruthy()
    expect(screen.getByText('ENDING IN 30 DAYS')).toBeTruthy()
    expect(screen.getByText('Lease contracts')).toBeTruthy()

    // Drivers on lease cards
    expect(screen.getByText('Harpreet Singh')).toBeTruthy()
    expect(screen.getByText('Sarah Jenkins')).toBeTruthy()
    expect(screen.getByText('Derek Miller')).toBeTruthy()
  })

  it('navigates to Frame 2: Lease Detail and checks deduction schedule & disputes', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <LeasesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 2: Lease Detail'))
    expect(screen.getByText('Harpreet Singh (LSE-0841)')).toBeTruthy()
    expect(screen.getByText(/Weekly deductions schedule/i)).toBeTruthy()
    expect(screen.getByText('Disputes & Financial Adjustments')).toBeTruthy()
    expect(screen.getByText('Open Ledger')).toBeTruthy()
  })

  it('navigates to Frame 3: Create / Edit Drawer and handles vehicle conflict detection', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <LeasesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 3: Create / Edit Drawer'))
    expect(screen.getByText('Create new lease')).toBeTruthy()
    expect(screen.getByText(/Establish a scheduled weekly lease deduction/)).toBeTruthy()
    expect(screen.getByText(/assigned to Sarah Jenkins/)).toBeTruthy()
    expect(screen.getByText(/Fleet #V-118/)).toBeTruthy()
  })

  it('navigates to Frame 4: Security Intercept & Fallback States', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <LeasesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 4: Security & Edge States'))
    expect(screen.getByText('Access restricted')).toBeTruthy()
    expect(screen.getByText('Leases are for branch admins and super admins.')).toBeTruthy()
    expect(screen.getByText(/Dispatcher #04/)).toBeTruthy()
    expect(screen.getByText('No leases yet')).toBeTruthy()
    expect(screen.getByText('Lethbridge Vehicle-For-Hire Bylaw #6141 Compliance')).toBeTruthy()
  })
})
