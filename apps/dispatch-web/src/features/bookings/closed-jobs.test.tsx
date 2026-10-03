import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { render, screen, waitFor } from '@testing-library/react'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { ClosedJobsModal } from '@/features/bookings/ClosedJobsModal'
import { useOpsPanels } from '@/features/bookings/ops-panels'
import { server } from '@/test/server'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'ada@bridgecabs.test',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'dispatcher' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge', city: 'Lethbridge' },
}

describe('closed jobs modal', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
    useOpsPanels.setState({ timeoutOpen: false, closedOpen: false })
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
        if (url.searchParams.get('tab') !== 'closed') {
          return HttpResponse.json({ data: [], meta: { page: 1, pageSize: 20, total: 0, totalPages: 0 } })
        }
        if (!url.searchParams.get('from')?.includes('T')) {
          return new HttpResponse('from must be a UTC instant', { status: 400 })
        }
        if (!url.searchParams.get('to')?.includes('T')) {
          return new HttpResponse('to must be a UTC instant', { status: 400 })
        }
        return HttpResponse.json({
          data: [
            {
              id: '66666666-6666-4666-8666-666666666666',
              trackingId: 'LB-3001',
              status: 'CANCELLED',
              source: 'DISPATCH',
              passengerName: 'Closed Rider',
              passengerPhone: '+14035550999',
              notes: 'plain note',
              createdAt: '2026-10-03T12:00:00.000Z',
              scheduledAt: null,
              stops: [
                { sequence: 1, type: 'PICKUP', address: 'A St' },
                { sequence: 2, type: 'DROPOFF', address: 'B St' },
              ],
            },
          ],
          meta: { page: 1, pageSize: 20, total: 1, totalPages: 1 },
        })
      }),
    )
  })

  it('loads today in branch time as UTC from/to and shows closed rows', async () => {
    useOpsPanels.getState().openClosed()
    const client = new QueryClient({ defaultOptions: { queries: { retry: false } } })
    render(
      <QueryClientProvider client={client}>
        <ClosedJobsModal />
      </QueryClientProvider>,
    )
    await waitFor(() => expect(screen.getByText('LB-3001')).toBeTruthy())
    expect(screen.getByText('Closed Rider')).toBeTruthy()
    expect(screen.queryByText('plain note')).toBeNull()
    expect(screen.getByRole('button', { name: 'Open' })).toBeTruthy()
    expect(screen.getByLabelText('Status')).toBeTruthy()
  })
})
