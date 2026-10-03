import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { TimeoutJobsModal } from '@/features/bookings/TimeoutJobsModal'
import { useOpsPanels } from '@/features/bookings/ops-panels'
import { useTimeoutAlerts } from '@/features/bookings/timeout-alerts'
import { server } from '@/test/server'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'ada@bridgecabs.test',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'dispatcher' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge', city: 'Lethbridge' },
}

const bookingId = '66666666-6666-4666-8666-666666666666'

function renderModal() {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(
    <QueryClientProvider client={client}>
      <TimeoutJobsModal />
    </QueryClientProvider>,
  )
}

describe('timeout jobs modal', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
    useOpsPanels.setState({ timeoutOpen: false, closedOpen: false })
    useTimeoutAlerts.setState({ badge: 2, soundEnabled: false, primed: false })
    localStorage.clear()
    server.use(
      http.get('http://localhost:3000/api/v1/config/dispatch', () =>
        HttpResponse.json({
          scheduleMinLeadMinutes: 15,
          scheduleMaxDays: 30,
          offerTimeoutSeconds: 15,
          fixedFareMaxCents: 50_000,
          timezone: 'America/Edmonton',
          autoDispatchDefault: true,
          branchCenter: { lat: 49.6935, lng: -112.8418 },
        }),
      ),
      http.get('http://localhost:3000/api/v1/bookings', ({ request }) => {
        const url = new URL(request.url)
        if (url.searchParams.get('tab') !== 'timeout') {
          return HttpResponse.json({ data: [], meta: { page: 1, pageSize: 20, total: 0, totalPages: 0 } })
        }
        return HttpResponse.json({
          data: [
            {
              id: bookingId,
              trackingId: 'LB-2001',
              status: 'NO_DRIVER_FOUND',
              source: 'DISPATCH',
              passengerName: 'Sam Rider',
              passengerPhone: '+14035550100',
              notes: null,
              createdAt: '2026-10-03T18:00:00.000Z',
              scheduledAt: null,
              stops: [
                { sequence: 1, type: 'PICKUP', address: '1 Main St' },
                { sequence: 2, type: 'DROPOFF', address: '9 Oak Ave' },
              ],
            },
          ],
          meta: { page: 1, pageSize: 20, total: 1, totalPages: 1 },
        })
      }),
    )
  })

  it('lists timeout jobs with assign, retry, and cancel actions', async () => {
    useOpsPanels.getState().openTimeout()
    renderModal()
    await waitFor(() => expect(screen.getByText('LB-2001')).toBeTruthy())
    expect(screen.getByText('Sam Rider')).toBeTruthy()
    expect(screen.getByText('1 Main St')).toBeTruthy()
    expect(screen.getByRole('button', { name: 'Assign' })).toBeTruthy()
    expect(screen.getByRole('button', { name: 'Retry search' })).toBeTruthy()
    expect(screen.getByRole('button', { name: 'Cancel' })).toBeTruthy()
    expect(useTimeoutAlerts.getState().badge).toBe(0)
  })

  it('primes audio when Sound alerts is enabled', () => {
    const prime = vi.spyOn(useTimeoutAlerts.getState(), 'primeAudio')
    useOpsPanels.getState().openTimeout()
    renderModal()
    const toggle = screen.getByLabelText('Sound alerts')
    fireEvent.click(toggle)
    expect(useTimeoutAlerts.getState().soundEnabled).toBe(true)
    expect(localStorage.getItem('bridgecabs.dispatch.soundAlerts')).toBe('1')
    expect(prime).toHaveBeenCalled()
  })
})
