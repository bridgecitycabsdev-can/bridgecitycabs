import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { PassengersPage } from '@/features/passengers/passengers-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Passengers page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders passenger list, count badges, search filters, and passenger records', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <PassengersPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByText('Frame 1: Passenger List')).toBeTruthy()
    expect(screen.getByText('1,284')).toBeTruthy()
    expect(screen.getByText('Active Riders: 1,246')).toBeTruthy()
    expect(screen.getByText('Blocked: 38')).toBeTruthy()
    expect(screen.getByText('Anita Rao')).toBeTruthy()
    expect(screen.getByText('Sarah Jenkins')).toBeTruthy()
    expect(screen.getByText('Derek Miller')).toBeTruthy()
    expect(screen.getByText('Add passenger')).toBeTruthy()
  })
})
