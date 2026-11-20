import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { WeeklyClosingPage } from '@/features/weekly-closing/weekly-closing-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Weekly closing page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders weekly closing period list, Week 47, and Week 46', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <WeeklyClosingPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByText('Frame 1: Period List (Active)')).toBeTruthy()
    expect(screen.getByText('26 periods')).toBeTruthy()
    expect(screen.getByText('Week 47')).toBeTruthy()
    expect(screen.getByText('Week 46')).toBeTruthy()
    expect(screen.getByText('Weekly Reconciliation Cadence')).toBeTruthy()
  })

  it('navigates to Period Detail and Run & Finalize Dialogs', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <WeeklyClosingPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    // Click Audit Sheet on Week 46
    fireEvent.click(screen.getByText('Audit Sheet'))
    expect(screen.getByText('Mon 9 Nov – Sun 15 Nov 2026')).toBeTruthy()
    expect(screen.getByText('TOTAL OPENING')).toBeTruthy()
    expect(screen.getByText('TOTAL MOVEMENT')).toBeTruthy()
    expect(screen.getByText('TOTAL CLOSING')).toBeTruthy()
    expect(screen.getByText('2100 · Driver Payables Ledger (4 accounts)')).toBeTruthy()

    // Click Frame 3
    fireEvent.click(screen.getByText('Frame 3: Run & Finalize Dialogs'))
    expect(screen.getByText('Run weekly closing')).toBeTruthy()
    expect(screen.getByText('Finalize Week')).toBeTruthy()
    expect(screen.getByText('CLOSING PROTOCOL PIPELINE')).toBeTruthy()

    // Click Frame 4
    fireEvent.click(screen.getByText('Frame 4: Locked & Read-Only'))
    expect(screen.getByText('Role View: Branch Admin (View Only)')).toBeTruthy()
    expect(screen.getByText('Active Rollup: Week 47 (Draft)')).toBeTruthy()
    expect(screen.getByText('No closing periods yet.')).toBeTruthy()
  })
})
