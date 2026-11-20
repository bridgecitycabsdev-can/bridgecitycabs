import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { LedgerPage } from '@/features/ledger/ledger-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('General Ledger page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders ledger header, driver balance, and double-entry transaction rows', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <LedgerPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByText('General Ledger')).toBeTruthy()
    expect(screen.getByText('DOUBLE-ENTRY V3.4')).toBeTruthy()
    expect(screen.getByText('SETTLED CASH POSITION')).toBeTruthy()
    expect(screen.getByText('$128.40')).toBeTruthy()
    expect(screen.getByText('Company owes driver')).toBeTruthy()
    expect(screen.getByText('DRIVER_BALANCE:drv_8441')).toBeTruthy()
    expect(screen.getByText('TXN-2026-98124')).toBeTruthy()
    expect(screen.getByText('TXN-2026-98041')).toBeTruthy()
  })

  it('switches between Frame 2, Frame 3, and Frame 4', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <LedgerPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    // Navigate to Frame 2
    fireEvent.click(screen.getByText('Frame 2: Entry Detail Panel'))
    expect(screen.getByText('Ledger Entry Detail')).toBeTruthy()
    expect(screen.getByText('Balanced Entry Verified')).toBeTruthy()

    // Navigate to Frame 3
    fireEvent.click(screen.getByText('Frame 3: Reverse Transaction'))
    expect(screen.getByText('LEDGER REMEDIATION MODE ·')).toBeTruthy()
    expect(screen.getByText('Reverse this transaction?')).toBeTruthy()
    expect(screen.getByText('Reversal Posted Successfully')).toBeTruthy()

    // Navigate to Frame 4
    fireEvent.click(screen.getByText('Frame 4: Specimen Deck'))
    expect(screen.getByText('Specimen Deck · Frame 4')).toBeTruthy()
    expect(screen.getByText('Role View: Branch Admin')).toBeTruthy()
    expect(screen.getByText('Reverse Transaction (Disabled)')).toBeTruthy()
  })
})
