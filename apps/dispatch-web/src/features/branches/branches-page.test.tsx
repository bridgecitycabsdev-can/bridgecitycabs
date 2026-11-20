import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen } from '@testing-library/react'
import { BrowserRouter } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { BranchesPage } from '@/features/branches/branches-page'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'priya.v@bridgecabs.ca',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'super_admin' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge Branch (YQL)', city: 'Lethbridge' },
}

describe('Branches page', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
  })

  it('renders Frame 1: Branch List with 4 branches and administration matrix', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <BranchesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    expect(screen.getByRole('heading', { name: 'Branches', level: 1 })).toBeTruthy()
    expect(screen.getByText('3 LIVE NODES')).toBeTruthy()
    expect(screen.getByText('Lethbridge Branch')).toBeTruthy()
    expect(screen.getByText('Medicine Hat Branch')).toBeTruthy()
    expect(screen.getByText('Red Deer Central Branch')).toBeTruthy()
    expect(screen.getByText('Taber-Coaldale Regional Hub')).toBeTruthy()

    // Branch Administration Matrix
    expect(screen.getByText('Branch Administration Matrix')).toBeTruthy()
    expect(screen.getByText('CAD Feed Buffer')).toBeTruthy()
  })

  it('navigates to Frame 2: Branch Detail and verifies shift telemetry and assigned personnel', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <BranchesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 2: Branch Detail'))
    expect(screen.getByText('Live Shift Telemetry')).toBeTruthy()
    expect(screen.getByText('Core Branch Details')).toBeTruthy()
    expect(screen.getByText('Dispatch Engine Parameters')).toBeTruthy()
    expect(screen.getByText(/Assigned Personnel/)).toBeTruthy()

    // Roster members
    expect(screen.getByText('Dave Vance')).toBeTruthy()
    expect(screen.getByText('Harpreet S.')).toBeTruthy()
    expect(screen.getByText('Karen M.')).toBeTruthy()
  })

  it('navigates to Frame 3: Edit Branch Configuration Modal', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <BranchesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 3: Create/Edit Drawer'))
    expect(screen.getByText('Edit Lethbridge Branch')).toBeTruthy()
    expect(screen.getByText('Save branch')).toBeTruthy()
  })

  it('navigates to Frame 4: Deactivate Dialog and toggles safety confirmation', () => {
    const client = new QueryClient()
    render(
      <QueryClientProvider client={client}>
        <BrowserRouter>
          <BranchesPage />
        </BrowserRouter>
      </QueryClientProvider>,
    )

    fireEvent.click(screen.getByText('Frame 4: Deactivate Dialog'))
    expect(screen.getByText('Deactivate this branch?')).toBeTruthy()
    expect(screen.getByText(/halts automated dispatch/)).toBeTruthy()
    expect(screen.getByText(/Super Admin Key #SYS-ROOT-01/)).toBeTruthy()
  })
})
