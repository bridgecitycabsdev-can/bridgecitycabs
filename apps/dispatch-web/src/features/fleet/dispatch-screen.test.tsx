import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor, within } from '@testing-library/react'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'
import type { FleetDriver } from '@bridgecabs/api-client'
import { useSession, type Profile } from '@/app/session'
import { BookingLists } from '@/features/bookings/booking-lists'
import { FleetChips } from '@/features/fleet/chips'
import { DriverTable } from '@/features/fleet/driver-table'
import { useFleet } from '@/features/fleet/store'
import { server } from '@/test/server'

const freeDriver = {
  id: '11111111-1111-4111-8111-111111111111',
  v: 1,
  status: 'AVAILABLE',
  lat: 49.69,
  lng: -112.84,
  heading: null,
  speedMps: null,
  accuracyM: null,
  ts: 1_700_000_000_000,
  name: 'Priya Nair',
  unit: '111',
  vehicleType: 'SUV',
  bookingId: null,
  stale: false,
} satisfies FleetDriver

const busyDriver = {
  ...freeDriver,
  id: '22222222-2222-4222-8222-222222222222',
  status: 'ON_TRIP',
  name: 'Jules Hart',
  unit: '123',
} satisfies FleetDriver

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'ada@bridgecabs.test',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'dispatcher' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge', city: 'Lethbridge' },
}

describe('dispatch screen', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useFleet.setState({ drivers: {}, conn: 'offline', chip: 'ALL' })
  })

  it('filters the driver table when a chip is selected', () => {
    useFleet.getState().replace([freeDriver, busyDriver])
    render(
      <>
        <FleetChips />
        <DriverTable />
      </>,
    )

    expect(screen.getByRole('cell', { name: '111' })).toBeTruthy()
    expect(screen.getByRole('cell', { name: '123' })).toBeTruthy()
    expect(screen.getByRole('button', { name: /FREE 1/ })).toBeTruthy()
    expect(screen.getByRole('button', { name: /BUSY 1/ })).toBeTruthy()

    fireEvent.click(screen.getByRole('button', { name: /FREE/ }))

    expect(screen.getByRole('cell', { name: '111' })).toBeTruthy()
    expect(screen.queryByRole('cell', { name: '123' })).toBeNull()
  })

  it('loads each town from its own booking tab', async () => {
    const seen: { tab: string | null; zone: string | null }[] = []
    server.use(
      http.get('http://localhost:3000/api/v1/bookings', ({ request }) => {
        const url = new URL(request.url)
        seen.push({ tab: url.searchParams.get('tab'), zone: url.searchParams.get('zone') })
        return HttpResponse.json({
          data: [
            {
              id: '66666666-6666-4666-8666-666666666666',
              trackingId: 'BC-TOWN01',
              status: 'CREATED',
              passengerName: 'Leila Hassan',
              scheduledAt: null,
              stops: [{ sequence: 0, type: 'PICKUP', address: '1 Ave S' }],
            },
          ],
          meta: { page: 1, pageSize: 20, total: 1, totalPages: 1 },
        })
      }),
    )
    useSession.getState().setAccessToken('token')
    useSession.getState().setProfile(profile)
    const client = new QueryClient({ defaultOptions: { queries: { retry: false } } })
    render(
      <QueryClientProvider client={client}>
        <BookingLists />
      </QueryClientProvider>,
    )

    await waitFor(() => {
      expect(screen.getAllByText('BC-TOWN01')).toHaveLength(2)
    })
    expect(screen.getByRole('heading', { name: 'Within Town' })).toBeTruthy()
    expect(screen.getByRole('heading', { name: 'Out of Town' })).toBeTruthy()
    expect(screen.queryByRole('button', { name: /new job/i })).toBeNull()
    expect(screen.queryByRole('button', { name: /assign/i })).toBeNull()
    expect(seen).toEqual(
      expect.arrayContaining([
        { tab: 'unassigned', zone: 'INSIDE_TOWN' },
        { tab: 'unassigned', zone: 'OUT_OF_TOWN' },
      ]),
    )

    const withinTown = screen.getByRole('heading', { name: 'Within Town' }).closest('section')
    if (!withinTown) throw new Error('missing Within Town')
    fireEvent.click(within(withinTown).getByRole('tab', { name: 'Assigned' }))

    await waitFor(() => {
      expect(seen).toEqual(expect.arrayContaining([{ tab: 'assigned', zone: 'INSIDE_TOWN' }]))
    })
  })
})
