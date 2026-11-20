import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { CorporatePage } from '@/features/corporate/corporate-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Corporate accounts page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders corporate accounts roster, KPI tags, and company rows', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <CorporatePage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByText('Frame 1: Account List (ACTIVE)')).toBeTruthy()
    expect(screen.getByText('38 active accounts')).toBeTruthy()
    expect(screen.getByText('YQL LETHBRIDGE FLEET')).toBeTruthy()
    expect(screen.getByText('Prairie Health Group')).toBeTruthy()
    expect(screen.getByText('ACC-014')).toBeTruthy()
    expect(screen.getByText('Lethbridge College')).toBeTruthy()
    expect(screen.getByText('Galt Museum & Archives')).toBeTruthy()
    expect(screen.getByText('Cavendish Farms Corp')).toBeTruthy()
  })
})
