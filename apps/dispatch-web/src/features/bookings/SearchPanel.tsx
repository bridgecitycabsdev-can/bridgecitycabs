import { useQuery } from '@tanstack/react-query'
import { useState } from 'react'
import { z } from 'zod'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import {
  BOOKING_STATUSES,
  formatBranchTime,
  pickupStop,
  type BookingDetail,
} from '@/features/bookings/booking-detail'
import { useBookingUi } from '@/features/bookings/selection'
import { useBookingDetail } from '@/features/bookings/use-booking-detail'
import { api, jsonBody } from '@/lib/api'

const fieldClass =
  'border-input bg-background h-8 w-full rounded-md border px-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring'

const listSchema = z.object({
  data: z.array(
    z.object({
      id: z.string(),
      trackingId: z.string(),
      status: z.string(),
      passengerName: z.string(),
      passengerPhone: z.string().optional(),
      driver: z
        .object({ firstName: z.string(), lastName: z.string() })
        .nullish(),
      stops: z
        .array(
          z.object({
            sequence: z.number(),
            address: z.string(),
            type: z.string().optional(),
            lat: z.number().optional(),
            lng: z.number().optional(),
          }),
        )
        .optional(),
    }),
  ),
})

type Filters = {
  q: string
  phone: string
  trackingId: string
  status: string
  driverId: string
}

const empty: Filters = { q: '', phone: '', trackingId: '', status: '', driverId: '' }

export function SearchPanel({ timezone }: { timezone: string }) {
  const [draft, setDraft] = useState<Filters>(empty)
  const [filters, setFilters] = useState<Filters | null>(null)
  const selectedId = useBookingUi((state) => state.selectedId)
  const setSelected = useBookingUi((state) => state.setSelected)
  const openJob = useBookingUi((state) => state.openJob)
  const branchId = useBranchId()
  const detail = useBookingDetail(selectedId)

  const search = useQuery({
    queryKey: ['bookings', 'search', filters, branchId],
    enabled: Boolean(filters),
    queryFn: async () => {
      const query: Record<string, string> = {}
      if (branchId) query.branchId = branchId
      if (filters!.q) query.q = filters!.q
      if (filters!.phone) query.phone = filters!.phone
      if (filters!.trackingId) query.trackingId = filters!.trackingId
      if (filters!.status) query.status = filters!.status
      if (filters!.driverId) query.driverId = filters!.driverId
      const result = await api.GET('/api/v1/bookings', {
        params: { query: query as never },
      })
      if (!result.response.ok) throw new Error('Search failed')
      return listSchema.parse(await jsonBody(result))
    },
  })

  return (
    <div className="grid min-h-0 flex-1 gap-3 md:grid-cols-[minmax(0,1.1fr)_minmax(0,1fr)]">
      <div className="space-y-2">
        <form
          className="grid gap-2 sm:grid-cols-2"
          onSubmit={(event) => {
            event.preventDefault()
            setFilters({ ...draft })
          }}
        >
          <Field
            label="Passenger"
            value={draft.q}
            onChange={(q) => setDraft((state) => ({ ...state, q }))}
          />
          <Field
            label="Phone"
            value={draft.phone}
            onChange={(phone) => setDraft((state) => ({ ...state, phone }))}
          />
          <Field
            label="Tracking ID"
            value={draft.trackingId}
            onChange={(trackingId) => setDraft((state) => ({ ...state, trackingId }))}
          />
          <label className="block text-xs">
            <span className="text-muted-foreground">Status</span>
            <select
              className={fieldClass}
              value={draft.status}
              onChange={(event) => setDraft((state) => ({ ...state, status: event.target.value }))}
            >
              <option value="">Any</option>
              {BOOKING_STATUSES.map((status) => (
                <option key={status} value={status}>
                  {status}
                </option>
              ))}
            </select>
          </label>
          <Field
            label="Driver ID"
            value={draft.driverId}
            onChange={(driverId) => setDraft((state) => ({ ...state, driverId }))}
          />
          <div className="flex items-end">
            <Button type="submit" size="sm">
              Search
            </Button>
          </div>
        </form>
        <div className="max-h-80 overflow-auto rounded-md border">
          <table className="w-full text-left text-xs">
            <thead className="bg-muted/50 sticky top-0">
              <tr>
                <th className="px-2 py-1.5 font-medium">Tracking</th>
                <th className="px-2 py-1.5 font-medium">Passenger</th>
                <th className="px-2 py-1.5 font-medium">Status</th>
              </tr>
            </thead>
            <tbody>
              {search.data?.data.map((row) => (
                <tr
                  key={row.id}
                  className="hover:bg-muted/40 cursor-pointer border-t data-[on=true]:bg-primary/10"
                  data-on={selectedId === row.id}
                  onClick={() => setSelected(row.id)}
                >
                  <td className="px-2 py-1.5 font-medium">{row.trackingId}</td>
                  <td className="px-2 py-1.5">{row.passengerName}</td>
                  <td className="px-2 py-1.5">{row.status}</td>
                </tr>
              ))}
            </tbody>
          </table>
          {filters && search.data?.data.length === 0 ? (
            <p className="text-muted-foreground px-2 py-3 text-sm">No matching jobs.</p>
          ) : null}
          {!filters ? (
            <p className="text-muted-foreground px-2 py-3 text-sm">Search to list jobs.</p>
          ) : null}
        </div>
      </div>
      <div className="rounded-md border p-2 text-sm">
        {!selectedId ? (
          <p className="text-muted-foreground">Select a job from the results.</p>
        ) : detail.isPending ? (
          <p className="text-muted-foreground">Loading…</p>
        ) : detail.data ? (
          <SearchResultDetail
            booking={detail.data}
            timezone={timezone}
            onOpen={() => openJob(detail.data!.id)}
          />
        ) : (
          <p className="text-destructive">Could not load that job.</p>
        )}
      </div>
    </div>
  )
}

function SearchResultDetail({
  booking,
  timezone,
  onOpen,
}: {
  booking: BookingDetail
  timezone: string
  onOpen: () => void
}) {
  const pickup = pickupStop(booking.stops)
  return (
    <div className="space-y-2">
      <div className="flex items-start justify-between gap-2">
        <div>
          <p className="font-semibold">{booking.trackingId}</p>
          <p className="text-muted-foreground text-xs">{booking.status}</p>
        </div>
        <Button type="button" size="xs" onClick={onOpen}>
          Open
        </Button>
      </div>
      <p>{booking.passengerName}</p>
      <p className="text-muted-foreground">{booking.passengerPhone}</p>
      {pickup ? <p className="text-muted-foreground">From {pickup.address}</p> : null}
      <p className="text-muted-foreground text-xs">
        {booking.scheduledAt
          ? formatBranchTime(booking.scheduledAt, timezone)
          : `Created ${formatBranchTime(booking.createdAt, timezone)}`}
      </p>
    </div>
  )
}

function Field({
  label,
  value,
  onChange,
}: {
  label: string
  value: string
  onChange: (value: string) => void
}) {
  return (
    <label className="block text-xs">
      <span className="text-muted-foreground">{label}</span>
      <input
        className={fieldClass}
        value={value}
        onChange={(event) => onChange(event.target.value)}
      />
    </label>
  )
}

function useBranchId() {
  const role = useSession((state) => state.profile?.role.name)
  const selected = useSession((state) => state.branchId)
  const own = useSession((state) => state.profile?.branch?.id)
  return role === 'super_admin' ? selected : (own ?? null)
}
