import { render, within } from '@testing-library/react'
import { MemoryRouter, Route, Routes } from 'react-router-dom'
import { beforeEach, describe, expect, it } from 'vitest'
import { DispatchGate } from '@/app/dispatch-gate'
import { useSession, type Profile } from '@/app/session'
import { NoAccessPage } from '@/features/auth/no-access-page'

function profile(role: string): Profile {
  return {
    id: '11111111-1111-4111-8111-111111111111',
    email: 'ada@bridgecabs.test',
    role: { id: '22222222-2222-4222-8222-222222222222', name: role },
    branch: null,
  }
}

function renderDispatch() {
  return render(
    <MemoryRouter initialEntries={['/dispatch']}>
      <Routes>
        <Route
          path="/dispatch"
          element={
            <DispatchGate>
              <p>Board</p>
            </DispatchGate>
          }
        />
        <Route path="/no-access" element={<NoAccessPage />} />
        <Route path="/login" element={<p>Login</p>} />
      </Routes>
    </MemoryRouter>,
  )
}

describe('dispatch route', () => {
  beforeEach(() => {
    useSession.getState().clear()
  })

  it.each(['super_admin', 'branch_admin', 'dispatcher', 'customer_care'])(
    'lets %s open /dispatch',
    (role) => {
      useSession.getState().setAccessToken('token')
      useSession.getState().setProfile(profile(role))
      const view = renderDispatch()
      expect(within(view.container).getByText('Board')).toBeTruthy()
    },
  )

  it.each(['driver', 'passenger'])('keeps a %s token off /dispatch', (role) => {
    useSession.getState().setAccessToken('token')
    useSession.getState().setProfile(profile(role))
    const view = renderDispatch()
    expect(within(view.container).getByRole('heading', { name: 'No access' })).toBeTruthy()
    expect(within(view.container).queryByText('Board')).toBeNull()
  })

  it('sends a signed-out visitor to login', () => {
    const view = renderDispatch()
    expect(within(view.container).getByText('Login')).toBeTruthy()
  })
})