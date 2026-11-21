import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { FareRulesPage } from '@/features/fares/fare-rules-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Fare rules page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders fare rules list, KPI cards, and tariff table', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <FareRulesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByRole('heading', { name: 'Fare rules', level: 1 })).toBeTruthy()
    expect(screen.getByText('Base Flag Drop')).toBeTruthy()
    expect(screen.getByText('Standard Meter - Downtown Core')).toBeTruthy()
    expect(screen.getByText('YQL-STD-DT')).toBeTruthy()
    expect(screen.getByText('WAV Wheelchair Accessible Tariff')).toBeTruthy()
  })

  it('filters fare rules by search query and resets filter', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <FareRulesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    const searchInput = screen.getByPlaceholderText(/Search rule title, zone/i)
    fireEvent.change(searchInput, { target: { value: 'Airport' } })

    expect(screen.getByText('Lethbridge Airport Flat Corridor')).toBeTruthy()
    expect(screen.queryByText('Standard Meter - Downtown Core')).toBeNull()

    const resetButton = screen.getByText('Reset')
    fireEvent.click(resetButton)

    expect(screen.getByText('Standard Meter - Downtown Core')).toBeTruthy()
  })

  it('opens create modal, submits new rule, and updates table', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <FareRulesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('+ New fare rule'))
    expect(screen.getByText('Create New Fare Rule')).toBeTruthy()

    const titleInput = screen.getByPlaceholderText(/e.g. Standard Meter/i)
    fireEvent.change(titleInput, { target: { value: 'Test Night Surcharge' } })

    fireEvent.click(screen.getByRole('button', { name: 'Create Fare Rule' }))

    expect(screen.getByText('Test Night Surcharge')).toBeTruthy()
  })
})
