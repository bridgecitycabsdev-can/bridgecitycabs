import { useQuery } from '@tanstack/react-query'
import { useState } from 'react'
import { z } from 'zod'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import { useOpsPanels } from '@/features/bookings/ops-panels'
import { useBookingUi } from '@/features/bookings/selection'
import { useTimeoutAlerts } from '@/features/bookings/timeout-alerts'
import { useDrafts } from '@/features/dispatch/drafts/store'
import { api, jsonBody } from '@/lib/api'

const TABS = ['unassigned', 'assigned', 'active'] as const
type BookingTab = (typeof TABS)[number]

const TAB_LABEL: Record<BookingTab, string> = {
  unassigned: 'Unassigned',
  assigned: 'Assigned',
  active: 'Active',
}

const ZONES = [
  { id: 'INSIDE_TOWN', title: 'Within Town' },
  { id: 'OUT_OF_TOWN', title: 'Out of Town' },
] as const

type ZoneId = (typeof ZONES)[number]['id']

const bookingSchema = z.object({
  id: z.string(),
  trackingId: z.string(),
  status: z.string(),
  passengerName: z.string(),
  scheduledAt: z.string().nullable().optional(),
  vehicleType: z.object({ name: z.string() }).nullish(),
  driver: z
    .object({
      firstName: z.string(),
      lastName: z.string(),
    })
    .nullish(),
  stops: z
    .array(
      z.object({
        sequence: z.number(),
        address: z.string(),
        type: z.string().optional(),
      }),
    )
    .optional(),
})

const pageSchema = z.object({
  data: z.array(bookingSchema),
})

export function BookingLists() {
  const openSearch = useBookingUi((state) => state.openSearch)
  const openTimeout = useOpsPanels((state) => state.openTimeout)
  const openClosed = useOpsPanels((state) => state.openClosed)
  const badge = useTimeoutAlerts((state) => state.badge)
  const soundEnabled = useTimeoutAlerts((state) => state.soundEnabled)
  const setSoundEnabled = useTimeoutAlerts((state) => state.setSoundEnabled)
  const primeAudio = useTimeoutAlerts((state) => state.primeAudio)

  return (
    <div className="flex h-full min-h-0 flex-col">
      <div className="flex flex-wrap items-center justify-between gap-2 border-b px-3 py-2">
        <h2 className="text-sm font-semibold">Jobs</h2>
        <div className="flex flex-wrap items-center gap-1.5">
          <label className="text-muted-foreground inline-flex items-center gap-1 text-[11px]">
            <input
              type="checkbox"
              aria-label="Sound alerts"
              checked={soundEnabled}
              onChange={(event) => {
                const next = event.target.checked
                setSoundEnabled(next)
                if (next) primeAudio()
              }}
            />
            Sound alerts
          </label>
          <Button type="button" size="xs" variant="outline" onClick={openSearch}>
            Search
          </Button>
          <Button type="button" size="xs" variant="outline" onClick={openTimeout}>
            Timeout
            {badge > 0 ? (
              <span className="bg-destructive text-destructive-foreground ml-1 inline-flex min-w-4 justify-center rounded-full px-1 text-[10px] leading-4">
                {badge > 99 ? '99+' : badge}
              </span>
            ) : null}
          </Button>
          <Button type="button" size="xs" variant="outline" onClick={openClosed}>
            Closed
          </Button>
        </div>
      </div>
      {ZONES.map((zone) => (
        <ZoneBoard key={zone.id} zone={zone.id} title={zone.title} />
      ))}
    </div>
  )
}

function ZoneBoard({ zone, title }: { zone: ZoneId; title: string }) {
  const [tab, setTab] = useState<BookingTab>('unassigned')
  const role = useSession((state) => state.profile?.role.name)
  const selectedBranchId = useSession((state) => state.branchId)
  const ownBranchId = useSession((state) => state.profile?.branch?.id)
  const branchId = role === 'super_admin' ? selectedBranchId : ownBranchId
  const waitingForBranch = role === 'super_admin' && !branchId
  const selectedId = useBookingUi((state) => state.selectedId)
  const openJob = useBookingUi((state) => state.openJob)
  const selectBooking = useDrafts((state) => state.selectBooking)
  const query = useQuery({
    queryKey: ['bookings', tab, zone, branchId ?? null],
    enabled: !waitingForBranch,
    queryFn: async () => {
      const result = await api.GET('/api/v1/bookings', {
        params: {
          query: {
            tab,
            zone,
            ...(branchId ? { branchId } : {}),
          },
        },
      })
      if (!result.response.ok) throw new Error('Could not load bookings')
      return pageSchema.parse(await jsonBody(result))
    },
  })

  return (
    <section className="flex min-h-48 flex-1 flex-col border-b last:border-b-0">
      <header className="border-b px-3 py-2">
        <h2 className="text-sm font-semibold">{title}</h2>
        <div className="mt-2 flex gap-1" role="tablist" aria-label={title}>
          {TABS.map((item) => (
            <button
              key={item}
              type="button"
              role="tab"
              aria-selected={tab === item}
              className="rounded-md px-2 py-1 text-xs data-[on=true]:bg-primary data-[on=true]:text-primary-foreground"
              data-on={tab === item}
              onClick={() => setTab(item)}
            >
              {TAB_LABEL[item]}
            </button>
          ))}
        </div>
      </header>
      <div className="min-h-0 flex-1 overflow-auto px-3 py-2">
        {waitingForBranch ? (
          <p className="text-muted-foreground text-sm">Select a branch to see jobs.</p>
        ) : null}
        {query.isPending && !waitingForBranch ? (
          <p className="text-muted-foreground text-sm">Loading jobs…</p>
        ) : null}
        {query.isError ? <p className="text-destructive text-sm">Could not load bookings.</p> : null}
        <ul className="space-y-2">
          {query.data?.data.map((booking) => {
            const pickup = pickupAddress(booking.stops)
            const detail = [
              booking.vehicleType?.name,
              driverName(booking.driver),
              booking.scheduledAt ? formatWhen(booking.scheduledAt) : null,
            ]
              .filter(Boolean)
              .join(' · ')
            return (
              <li key={booking.id}>
                <button
                  type="button"
                  className="w-full rounded-md border px-2.5 py-2 text-left text-sm data-[on=true]:border-primary data-[on=true]:ring-1 data-[on=true]:ring-primary"
                  data-on={selectedId === booking.id}
                  onClick={() => {
                    selectBooking(booking.id)
                    openJob(booking.id)
                  }}
                >
                  <div className="flex items-baseline justify-between gap-2">
                    <span className="font-medium">{booking.trackingId}</span>
                    <span className="text-muted-foreground text-xs">{booking.status}</span>
                  </div>
                  <p>{booking.passengerName}</p>
                  {pickup ? <p className="text-muted-foreground">{pickup}</p> : null}
                  {detail ? <p className="text-muted-foreground text-xs">{detail}</p> : null}
                </button>
              </li>
            )
          })}
        </ul>
        {query.data?.data.length === 0 ? (
          <p className="text-muted-foreground text-sm">No bookings on this list.</p>
        ) : null}
      </div>
    </section>
  )
}

function pickupAddress(
  stops: { sequence: number; address: string; type?: string }[] | undefined,
) {
  if (!stops?.length) return null
  const pickup = stops.find((stop) => stop.type === 'PICKUP')
  if (pickup) return pickup.address
  return [...stops].sort((left, right) => left.sequence - right.sequence)[0]?.address ?? null
}

function driverName(driver: { firstName: string; lastName: string } | null | undefined) {
  if (!driver) return null
  return `${driver.firstName} ${driver.lastName}`.trim()
}

function formatWhen(iso: string) {
  const date = new Date(iso)
  if (Number.isNaN(date.getTime())) return null
  return new Intl.DateTimeFormat(undefined, {
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  }).format(date)
}
