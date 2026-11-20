import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { VehiclesPage } from '@/features/vehicles/vehicles-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'ada@bridgecabs.test',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'dispatcher' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Vehicles page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders vehicle roster list, review states, and vehicle assets', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <VehiclesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByText('Frame 1: Vehicle List (Active)')).toBeTruthy()
    expect(screen.getByText('ABC-123')).toBeTruthy()
    expect(screen.getByText('2022 Toyota Camry')).toBeTruthy()
    expect(screen.getByText('YQL-882')).toBeTruthy()
    expect(screen.getByText('Inspection Due Soon:')).toBeTruthy()
    expect(screen.getByText('74 registered')).toBeTruthy()
  })
})
