import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { NewJobPanel } from '@/features/dispatch/drafts/NewJobPanel'
import { blankForm } from '@/features/dispatch/drafts/schema'
import { useDrafts } from '@/features/dispatch/drafts/store'
import { server } from '@/test/server'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'ada@bridgecabs.test',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'dispatcher' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge', city: 'Lethbridge' },
}

function renderPanel() {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(
    <QueryClientProvider client={client}>
      <NewJobPanel />
    </QueryClientProvider>,
  )
}

describe('New Job panel', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
    const draft = {
      id: 'draft-1',
      form: blankForm(),
      quote: null,
      dirty: false,
      idem: null,
      errors: {},
      activeJob: null,
      autoName: null,
    }
    useDrafts.setState({ drafts: [draft], activeId: draft.id, panel: 'draft', selectedBookingId: null })
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
      http.get('http://localhost:3000/api/v1/vehicle-types', () =>
        HttpResponse.json({
          data: [{ id: 'suv', name: 'SUV', active: true }],
        }),
      ),
    )
  })

  it('shows New Job and Edit Job tabs, and Cash as the only payment', async () => {
    renderPanel()
    expect(screen.getByRole('heading', { name: 'Jobs Section' })).toBeTruthy()
    expect(screen.getByRole('tab', { name: /New Job #1/ })).toBeTruthy()
    expect(screen.getByRole('tab', { name: 'Edit Job' })).toBeTruthy()
    expect(screen.getByText('Cash')).toBeTruthy()
    expect(screen.getByText('Card').getAttribute('title')).toMatch(/payments/i)
    await waitFor(() => expect(screen.getByRole('button', { name: 'Book' })).toBeTruthy())
  })

  it('adds a second draft tab for a parallel call', () => {
    renderPanel()
    fireEvent.click(screen.getByRole('button', { name: 'New job' }))
    expect(screen.getByRole('tab', { name: /New Job #2/ })).toBeTruthy()
  })

  it('debounces quote requests and keeps only the latest result', async () => {
    const tokens: string[] = []
    server.use(
      http.post('http://localhost:3000/api/v1/fares/quotes', async ({ request }) => {
        const body = (await request.json()) as { stops: { lat: number }[] }
        const token = body.stops.at(-1)?.lat === 49.64 ? 'tok-late' : 'tok-early'
        tokens.push(token)
        return HttpResponse.json({
          distanceM: 8100,
          durationS: 1020,
          source: 'ROUTES',
          zone: 'INSIDE_TOWN',
          options: [
            {
              vehicleTypeId: 'suv',
              name: 'SUV',
              subtotalCents: 2500,
              taxCents: 125,
              totalCents: 2625,
              quoteToken: token,
              expiresAt: '2026-10-02T12:00:00.000Z',
              etaMinutes: null,
            },
          ],
        })
      }),
    )

    const draftId = useDrafts.getState().activeId
    renderPanel()
    useDrafts.getState().patch(draftId, {
      pickup: { address: 'A', placeId: 'a', lat: 49.69, lng: -112.84 },
      dropoff: { address: 'B', placeId: 'b', lat: 49.63, lng: -112.8 },
      vehicleTypeId: 'suv',
    })
    useDrafts.getState().patch(draftId, {
      dropoff: { address: 'C', placeId: 'c', lat: 49.64, lng: -112.79 },
    })

    await waitFor(
      () =>
        expect(
          useDrafts.getState().drafts.find((row) => row.id === draftId)?.quote?.options[0]
            ?.quoteToken,
        ).toBe('tok-late'),
      { timeout: 2000 },
    )
    // Debounce collapsed the first edit; only the latest stop set is quoted.
    expect(tokens.at(-1)).toBe('tok-late')
  })
})
