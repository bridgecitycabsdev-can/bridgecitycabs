import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { PromoCodesPage } from '@/features/promos/promo-codes-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Promo codes page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders promo codes list, KPI cards, and promo table', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <PromoCodesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByRole('heading', { name: 'Promo codes', level: 1 })).toBeTruthy()
    expect(screen.getByText('Active Campaign Codes')).toBeTruthy()
    expect(screen.getByText('LETHBRIDGE15')).toBeTruthy()
    expect(screen.getAllByText('CAMPUS5').length).toBeGreaterThanOrEqual(1)
    expect(screen.getByText('AIRPORT10')).toBeTruthy()
  })

  it('filters promo codes by search query and resets filter', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <PromoCodesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    const searchInput = screen.getByPlaceholderText(/Search promo code/i)
    fireEvent.change(searchInput, { target: { value: 'CAMPUS' } })

    expect(screen.getAllByText('CAMPUS5').length).toBeGreaterThanOrEqual(1)
    expect(screen.queryByText('LETHBRIDGE15')).toBeNull()

    const resetButton = screen.getByText('Reset')
    fireEvent.click(resetButton)

    expect(screen.getByText('LETHBRIDGE15')).toBeTruthy()
  })

  it('opens create modal, submits new promo code, and updates table', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <PromoCodesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('+ New promo code'))
    expect(screen.getByText('Create New Promo Code')).toBeTruthy()

    const codeInput = screen.getByPlaceholderText(/e.g. SUMMER26/i)
    fireEvent.change(codeInput, { target: { value: 'NEWYEAR27' } })

    fireEvent.click(screen.getByRole('button', { name: 'Create Promo Code' }))

    expect(screen.getByText('NEWYEAR27')).toBeTruthy()
  })
})
