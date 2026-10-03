import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { fireEvent, render, screen, waitFor } from '@testing-library/react'
import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'
import { useSession, type Profile } from '@/app/session'
import { JobDetailsModal } from '@/features/bookings/JobDetailsModal'
import { useBookingUi } from '@/features/bookings/selection'
import { useDrafts } from '@/features/dispatch/drafts/store'
import { server } from '@/test/server'

const bookingId = '66666666-6666-4666-8666-666666666666'
const driverId = '11111111-1111-4111-8111-111111111111'

const profile: Profile = {
  id: '33333333-3333-4333-8333-333333333333',
  email: 'ada@bridgecabs.test',
  role: { id: '44444444-4444-4444-8444-444444444444', name: 'dispatcher' },
  branch: { id: '55555555-5555-4555-8555-555555555555', name: 'Lethbridge', city: 'Lethbridge' },
}

const detail = {
  id: bookingId,
  trackingId: 'LB-1001',
  version: 2,
  status: 'SEARCHING_DRIVER',
  source: 'DISPATCH',
  assignMode: 'MANUAL',
  passengerName: 'Sam Rider',
  passengerPhone: '+14035550100',
  scheduledAt: null,
  createdAt: '2026-10-02T18:00:00.000Z',
  distanceMeters: 3200,
  durationSeconds: 540,
  quotedFareCents: 1800,
  quotedTaxCents: 90,
  fixedFareCents: null,
  paymentMethod: 'CASH',
  notes: null,
  vanOnly: false,
  ladyDriverOnly: false,
  zone: 'INSIDE_TOWN',
  vehicleTypeId: 'suv',
  vehicleType: { id: 'suv', name: 'SUV' },
  driver: null,
  vehicle: null,
  stops: [
    {
      sequence: 1,
      type: 'PICKUP',
      address: '1 Main St',
      lat: 49.69,
      lng: -112.84,
      placeId: 'p1',
    },
    {
      sequence: 2,
      type: 'DROPOFF',
      address: '9 Oak Ave',
      lat: 49.7,
      lng: -112.83,
      placeId: 'd1',
    },
  ],
  history: [
    {
      id: 'h1',
      fromStatus: null,
      toStatus: 'CREATED',
      actorType: 'STAFF',
      reason: null,
      createdAt: '2026-10-02T18:00:00.000Z',
    },
  ],
  createdBy: 'Ada Lovelace',
  assignedBy: null,
  driverName: null,
  driverUnit: null,
  openOffer: null,
  editableFields: ['notes', 'passengerName', 'passengerPhone', 'stops'],
}

function renderModal() {
  const client = new QueryClient({ defaultOptions: { queries: { retry: false } } })
  return render(
    <QueryClientProvider client={client}>
      <JobDetailsModal />
    </QueryClientProvider>,
  )
}

describe('job details modal', () => {
  beforeEach(() => {
    useSession.getState().clear()
    useSession.getState().setProfile(profile)
    useBookingUi.setState({
      selectedId: null,
      modalOpen: false,
      modalTab: 'job',
      toast: null,
      liveOffers: {},
      mapPrompt: null,
    })
    useDrafts.setState({ selectedBookingId: null, panel: 'draft' })
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
      http.get(`http://localhost:3000/api/v1/bookings/${bookingId}`, () =>
        HttpResponse.json(detail),
      ),
      http.get(`http://localhost:3000/api/v1/bookings/${bookingId}/candidates`, () =>
        HttpResponse.json([
          {
            driverId,
            name: 'Priya Nair',
            unit: '111',
            vehicleId: 'v1',
            distanceM: 800,
            eligible: true,
            reasons: [],
          },
          {
            driverId: '22222222-2222-4222-8222-222222222222',
            name: 'Jules Hart',
            unit: '123',
            vehicleId: 'v2',
            distanceM: 1200,
            eligible: false,
            reasons: ['VEHICLE_TYPE_MISMATCH'],
          },
        ]),
      ),
    )
  })

  it('shows legacy detail fields and opens assign candidates', async () => {
    useBookingUi.getState().openJob(bookingId)
    renderModal()

    await waitFor(() => expect(screen.getByText('LB-1001')).toBeTruthy())
    expect(screen.getByText('Sam Rider')).toBeTruthy()
    expect(screen.getByText('1 Main St')).toBeTruthy()
    expect(screen.getByText('Ada Lovelace')).toBeTruthy()
    expect(screen.getByText(/CREATED/)).toBeTruthy()

    fireEvent.click(screen.getByRole('button', { name: 'Assign' }))
    await waitFor(() => expect(screen.getByRole('button', { name: 'Assign Unit 111' })).toBeTruthy())
    expect(screen.getByText(/Wrong vehicle type/)).toBeTruthy()
  })

  it('keeps assign pending until the server confirms (no optimistic update)', async () => {
    let release!: () => void
    const gate = new Promise<void>((resolve) => {
      release = resolve
    })
    server.use(
      http.post(`http://localhost:3000/api/v1/bookings/${bookingId}/assign`, async () => {
        await gate
        return HttpResponse.json({ id: bookingId, status: 'DRIVER_ASSIGNED' })
      }),
    )

    useBookingUi.getState().openJob(bookingId, 'assign')
    renderModal()
    await waitFor(() => expect(screen.getByRole('button', { name: 'Assign Unit 111' })).toBeTruthy())

    fireEvent.click(screen.getByRole('button', { name: 'Assign Unit 111' }))
    expect(screen.getByRole('button', { name: 'Assigning Unit 111' })).toBeTruthy()
    expect(useBookingUi.getState().toast).toBeNull()

    release()
    await waitFor(() => expect(useBookingUi.getState().toast).toBe('Driver assigned'))
  })

  it('toasts DRIVER_NOT_AVAILABLE and refetches candidates', async () => {
    let candidateCalls = 0
    server.use(
      http.get(`http://localhost:3000/api/v1/bookings/${bookingId}/candidates`, () => {
        candidateCalls += 1
        return HttpResponse.json([
          {
            driverId,
            name: 'Priya Nair',
            unit: '111',
            vehicleId: 'v1',
            distanceM: 800,
            eligible: true,
            reasons: [],
          },
        ])
      }),
      http.post(`http://localhost:3000/api/v1/bookings/${bookingId}/assign`, () =>
        HttpResponse.json({ code: 'DRIVER_NOT_AVAILABLE', message: 'busy' }, { status: 409 }),
      ),
    )

    useBookingUi.getState().openJob(bookingId, 'assign')
    renderModal()
    await waitFor(() => expect(screen.getByRole('button', { name: 'Assign Unit 111' })).toBeTruthy())
    const before = candidateCalls
    fireEvent.click(screen.getByRole('button', { name: 'Assign Unit 111' }))
    await waitFor(() =>
      expect(useBookingUi.getState().toast).toBe('Driver is no longer available'),
    )
    await waitFor(() => expect(candidateCalls).toBeGreaterThan(before))
  })
})
