import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { DriversPage } from '@/features/drivers/drivers-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'ada@bridgecabs.test',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'dispatcher' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Drivers page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders driver roster list, search filters, and driver records', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <DriversPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByText('Frame 1: Driver List')).toBeTruthy()
    expect(screen.getByText('Harpreet Singh')).toBeTruthy()
    expect(screen.getByText('U-214')).toBeTruthy()
    expect(screen.getByText('Anita Rao')).toBeTruthy()
    expect(screen.getByText('Marcus Vance')).toBeTruthy()
    expect(screen.getByText('Documents expiring:')).toBeTruthy()
  })
})
