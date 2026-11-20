import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { InvoicesPage } from '@/features/invoices/invoices-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Invoices page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders invoices list, 4 KPI cards, and batch records', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <InvoicesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByText('Frame 1: Invoices List (Active)')).toBeTruthy()
    expect(screen.getByText('OUTSTANDING')).toBeTruthy()
    expect(screen.getByText('OVERDUE')).toBeTruthy()
    expect(screen.getByText('PAID THIS MONTH')).toBeTruthy()
    expect(screen.getByText('DRAFTS')).toBeTruthy()
    expect(screen.getByText('INV-2026-0042')).toBeTruthy()
    expect(screen.getByText('INV-2026-0041')).toBeTruthy()
    expect(screen.getByText('INV-2026-0040')).toBeTruthy()
  })
})
