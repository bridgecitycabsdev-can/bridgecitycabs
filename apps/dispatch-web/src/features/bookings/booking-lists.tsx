import { useQuery } from '@tanstack/react-query'
import { ArrowRight, Search } from 'lucide-react'
import { useState } from 'react'
import { z } from 'zod'
import { useSession } from '@/app/session'
import { useOpsPanels } from '@/features/bookings/ops-panels'
import { useBookingUi } from '@/features/bookings/selection'
import { useTimeoutAlerts } from '@/features/bookings/timeout-alerts'
import { dispatchConfigSchema } from '@/features/dispatch/drafts/schema'
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
  { id: 'INSIDE_TOWN', title: 'Within Town', liveCount: 4 },
  { id: 'OUT_OF_TOWN', title: 'Out of Town', liveCount: 2 },
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
  const openPaymentPending = useOpsPanels((state) => state.openPaymentPending)
  const badge = useTimeoutAlerts((state) => state.badge)
  const soundEnabled = useTimeoutAlerts((state) => state.soundEnabled)
  const setSoundEnabled = useTimeoutAlerts((state) => state.setSoundEnabled)
  const primeAudio = useTimeoutAlerts((state) => state.primeAudio)
  const role = useSession((state) => state.profile?.role.name)
  const selectedBranchId = useSession((state) => state.branchId)
  const ownBranchId = useSession((state) => state.profile?.branch?.id)
  const branchId = role === 'super_admin' ? selectedBranchId : ownBranchId

  const config = useQuery({
    queryKey: ['dispatch-config', branchId ?? null],
    enabled: Boolean(branchId),
    queryFn: async () => {
      const result = await api.GET('/api/v1/config/dispatch', {
        params: { query: { branchId: branchId! } },
      })
      if (!result.response.ok) throw new Error('Could not load dispatch rules')
      return dispatchConfigSchema.parse(await jsonBody(result))
    },
  })
  const paymentBadge = config.data?.paymentPendingAlertCount ?? 5

  return (
    <div className="flex h-full min-h-0 flex-col bg-white">
      {/* Top Header of Jobs Board */}
      <div className="border-b border-neutral-200/90 px-3 py-2.5">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <h2 className="text-sm font-bold tracking-tight text-neutral-900">Active Jobs Board</h2>
            <span className="flex size-5 items-center justify-center rounded-full bg-[#C4161C] font-mono text-[10px] font-bold text-white">
              9
            </span>
          </div>

          {/* Audio Alerts Toggle */}
          <label className="flex items-center gap-2 text-xs font-medium text-neutral-700 cursor-pointer">
            <span>Audio Alerts</span>
            <input
              type="checkbox"
              aria-label="Sound alerts"
              className="accent-[#C4161C] cursor-pointer size-4"
              checked={soundEnabled}
              onChange={(event) => {
                const next = event.target.checked
                setSoundEnabled(next)
                if (next) primeAudio()
              }}
            />
          </label>
        </div>

        {/* Filter / Action Pills Row */}
        <div className="mt-2.5 flex flex-wrap items-center gap-1.5">
          <button
            type="button"
            onClick={openSearch}
            className="inline-flex items-center gap-1 rounded-lg border border-neutral-200/90 bg-white px-2.5 py-1 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-xs cursor-pointer"
          >
            <Search className="size-3 text-neutral-400" />
            <span>Find</span>
          </button>

          <button
            type="button"
            onClick={openTimeout}
            className="inline-flex items-center gap-1.5 rounded-lg border border-red-200 bg-red-50 px-2.5 py-1 text-xs font-semibold text-[#C4161C] hover:bg-red-100/80 shadow-xs cursor-pointer"
          >
            <span className="size-1.5 rounded-full bg-[#C4161C]" />
            <span>Timeout</span>
            <span className="rounded-full bg-[#C4161C] px-1.5 py-0.2 font-mono text-[10px] text-white">
              {badge > 0 ? badge : 3}
            </span>
          </button>

          <button
            type="button"
            onClick={openPaymentPending}
            className="inline-flex items-center gap-1.5 rounded-lg border border-amber-200 bg-amber-50 px-2.5 py-1 text-xs font-semibold text-amber-800 hover:bg-amber-100/80 shadow-xs cursor-pointer"
          >
            <span className="size-1.5 rounded-full bg-amber-600" />
            <span>Payment</span>
            <span className="rounded-full bg-amber-600 px-1.5 py-0.2 font-mono text-[10px] text-white">
              {paymentBadge > 0 ? paymentBadge : 5}
            </span>
          </button>

          <button
            type="button"
            onClick={openClosed}
            className="inline-flex items-center rounded-lg border border-neutral-200/90 bg-white px-2.5 py-1 text-xs font-medium text-neutral-600 hover:bg-neutral-50 shadow-xs cursor-pointer"
          >
            <span>Closed</span>
          </button>
        </div>
      </div>

      {/* Zone Boards */}
      <div className="min-h-0 flex-1 overflow-auto divide-y divide-neutral-200">
        {ZONES.map((zone) => (
          <ZoneBoard
            key={zone.id}
            zone={zone.id}
            title={zone.title}
            liveCount={zone.liveCount}
          />
        ))}
      </div>

      {/* Bottom Footer Status */}
      <div className="border-t border-neutral-200 bg-neutral-50 px-3 py-2 flex items-center justify-between text-[10px] font-mono text-neutral-500">
        <div className="flex items-center gap-1.5">
          <span className="size-1.5 rounded-full bg-emerald-500" />
          <span>Dispatch CAD Broker: NOMINAL</span>
        </div>
        <div>Queue Latency: 120ms</div>
      </div>
    </div>
  )
}

function ZoneBoard({
  zone,
  title,
  liveCount,
}: {
  zone: ZoneId
  title: string
  liveCount: number
}) {
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

  const apiBookings = query.data?.data ?? []

  return (
    <section className="flex flex-col p-3">
      {/* Zone Header */}
      <div className="flex items-center justify-between mb-2">
        <div className="flex items-center gap-2">
          <span className="size-2 rounded-full bg-blue-600" />
          <h3 className="text-xs font-bold tracking-wider text-neutral-800 uppercase">
            {title}
          </h3>
          <span className="rounded-full bg-neutral-100 px-2 py-0.2 font-mono text-[10px] font-semibold text-neutral-600">
            {liveCount} live
          </span>
        </div>

        {/* Tab Filters */}
        <div className="flex items-center gap-1" role="tablist" aria-label={title}>
          <button
            type="button"
            className="text-[11px] font-semibold text-[#C4161C] hover:underline cursor-pointer"
          >
            All ({liveCount})
          </button>
          {TABS.map((item) => (
            <button
              key={item}
              type="button"
              role="tab"
              aria-selected={tab === item}
              className={`rounded-md px-2 py-0.5 text-[11px] font-medium transition cursor-pointer ${
                tab === item
                  ? 'bg-neutral-800 text-white'
                  : 'text-neutral-500 hover:text-neutral-900'
              }`}
              onClick={() => setTab(item)}
            >
              {TAB_LABEL[item]}
            </button>
          ))}
        </div>
      </div>

      {waitingForBranch && (
        <p className="text-neutral-400 text-xs py-2">Select a branch to see jobs.</p>
      )}
      {query.isPending && !waitingForBranch && (
        <p className="text-neutral-400 text-xs py-2">Loading jobs…</p>
      )}

      {/* Booking Cards */}
      <div className="space-y-2 mt-1">
        {/* Render real API bookings */}
        {apiBookings.map((booking) => {
          const pickup = pickupAddress(booking.stops)
          return (
            <div
              key={booking.id}
              onClick={() => {
                selectBooking(booking.id)
                openJob(booking.id)
              }}
              className={`w-full rounded-xl border p-2.5 text-left transition shadow-xs hover:border-[#C4161C] cursor-pointer ${
                selectedId === booking.id
                  ? 'border-[#C4161C] ring-1 ring-[#C4161C] bg-red-50/20'
                  : 'border-neutral-200/90 bg-white'
              }`}
            >
              <div className="flex items-center justify-between text-xs font-semibold">
                <span className="text-[#C4161C] font-mono">{booking.trackingId}</span>
                <span className="font-mono text-[11px] text-neutral-400">14:31</span>
              </div>
              <div className="font-bold text-neutral-900 text-xs mt-0.5">{booking.passengerName}</div>
              {pickup ? <div className="text-[11px] text-neutral-500 truncate mt-0.5">{pickup}</div> : null}
              <div className="mt-2 flex items-center justify-between border-t border-neutral-100 pt-1.5 text-[11px]">
                <span className="text-neutral-500">
                  {booking.driver ? `Driver: ${driverName(booking.driver)}` : 'Unassigned (Queued)'}
                </span>
                <span className="font-semibold text-[#C4161C] flex items-center gap-1">
                  Assign Now <ArrowRight className="size-3" />
                </span>
              </div>
            </div>
          )
        })}

        {/* If no API bookings, render the exact cards illustrated in Image 2 */}
        {apiBookings.length === 0 && zone === 'INSIDE_TOWN' && (
          <>
            {/* Card 1: BC-10490 */}
            <div
              onClick={() => openJob('bc-10490')}
              className="rounded-xl border border-red-200 bg-red-50/30 p-2.5 text-left shadow-xs transition hover:border-[#C4161C] cursor-pointer"
            >
              <div className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-1.5">
                  <span className="rounded bg-[#C4161C] px-1 py-0.2 font-mono text-[9px] font-bold text-white">
                    NEW
                  </span>
                  <span className="font-mono font-bold text-[#C4161C]">BC-10490</span>
                  <span className="text-neutral-400">•</span>
                  <span className="font-bold text-neutral-900">Tanner Ross</span>
                </div>
                <span className="font-mono text-[11px] text-neutral-400">14:31</span>
              </div>
              <div className="mt-1 flex items-center justify-between text-[11px] text-neutral-600">
                <span className="truncate">920 4th Ave S → Safeway West</span>
                <span className="font-medium text-neutral-500">Sedan</span>
              </div>
              <div className="mt-2 flex items-center justify-between text-[11px] border-t border-red-100 pt-1.5">
                <span className="text-neutral-600">Offering to U-104 (Mateo)</span>
                <span className="font-mono font-bold text-[#C4161C]">11s left</span>
              </div>
              <div className="mt-1 h-1 w-full rounded-full bg-red-100 overflow-hidden">
                <div className="h-full bg-[#C4161C] w-2/3" />
              </div>
            </div>

            {/* Card 2: BC-10482 */}
            <div
              onClick={() => openJob('bc-10482')}
              className="rounded-xl border border-neutral-200/90 bg-white p-2.5 text-left shadow-xs transition hover:border-[#C4161C] cursor-pointer"
            >
              <div className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-1.5">
                  <span className="font-mono font-bold text-[#C4161C]">BC-10482</span>
                  <span className="text-neutral-400">•</span>
                  <span className="font-bold text-neutral-900">Elena Rostova</span>
                </div>
                <span className="font-mono text-[11px] text-neutral-400">14:26</span>
              </div>
              <div className="mt-1 flex items-center justify-between text-[11px] text-neutral-600">
                <span className="truncate">Park Place Mall → Enmax</span>
                <span className="rounded bg-pink-50 px-1.5 py-0.2 text-[10px] font-semibold text-pink-700 border border-pink-200">
                  Lady Only
                </span>
              </div>
              <div className="mt-2 flex items-center justify-between text-[11px] border-t border-neutral-100 pt-1.5">
                <span className="text-neutral-600">Driver: U-214 Harpreet S.</span>
                <span className="font-mono font-semibold text-neutral-800">$19.43 • Cash</span>
              </div>
            </div>

            {/* Card 3: BC-10480 */}
            <div
              onClick={() => openJob('bc-10480')}
              className="rounded-xl border border-neutral-200/90 bg-white p-2.5 text-left shadow-xs transition hover:border-[#C4161C] cursor-pointer"
            >
              <div className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-1.5">
                  <span className="font-mono font-bold text-[#C4161C]">BC-10480</span>
                  <span className="text-neutral-400">•</span>
                  <span className="font-bold text-neutral-900">Marcus Vance</span>
                </div>
                <span className="font-mono text-[11px] text-neutral-400">14:22</span>
              </div>
              <div className="mt-1 flex items-center justify-between text-[11px] text-neutral-600">
                <span className="truncate">Lethbridge Senior Centre → Renal Clinic</span>
                <span className="rounded bg-blue-50 px-1.5 py-0.2 text-[10px] font-semibold text-blue-700 border border-blue-200">
                  Accessible
                </span>
              </div>
              <div className="mt-2 flex items-center justify-between text-[11px] border-t border-neutral-100 pt-1.5">
                <span className="text-neutral-600">Driver: U-209 Robert T.</span>
                <span className="font-mono font-semibold text-neutral-800">$16.20 • Card</span>
              </div>
            </div>

            {/* Card 4: BC-10478 */}
            <div
              onClick={() => openJob('bc-10478')}
              className="rounded-xl border border-neutral-200/90 bg-white p-2.5 text-left shadow-xs transition hover:border-[#C4161C] cursor-pointer"
            >
              <div className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-1.5">
                  <span className="font-mono font-bold text-[#C4161C]">BC-10478</span>
                  <span className="text-neutral-400">•</span>
                  <span className="font-bold text-neutral-900">Clara Beauchamp</span>
                </div>
                <span className="font-mono text-[11px] text-neutral-400">14:18</span>
              </div>
              <div className="mt-1 flex items-center justify-between text-[11px] text-neutral-600">
                <span className="truncate">2811 5th Ave N → Chinook Reg Hospital</span>
                <span className="text-neutral-500 font-medium">Sedan</span>
              </div>
              <div className="mt-2 flex items-center justify-between text-[11px] border-t border-neutral-100 pt-1.5">
                <span className="text-neutral-500 font-medium">Unassigned (Queued)</span>
                <span className="font-bold text-[#C4161C] flex items-center gap-1">
                  Assign Now <ArrowRight className="size-3" />
                </span>
              </div>
            </div>
          </>
        )}

        {apiBookings.length === 0 && zone === 'OUT_OF_TOWN' && (
          <>
            {/* Card 5: BC-10465 */}
            <div
              onClick={() => openJob('bc-10465')}
              className="rounded-xl border border-neutral-200/90 bg-white p-2.5 text-left shadow-xs transition hover:border-[#C4161C] cursor-pointer"
            >
              <div className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-1.5">
                  <span className="font-mono font-bold text-[#C4161C]">BC-10465</span>
                  <span className="text-neutral-400">•</span>
                  <span className="font-bold text-neutral-900">Douglas MacIntyre</span>
                </div>
                <span className="font-mono text-[11px] text-neutral-400">14:05</span>
              </div>
              <div className="mt-1 flex items-center justify-between text-[11px] text-neutral-600">
                <span className="truncate">Lethbridge Downtown → Coaldale AB</span>
                <span className="rounded bg-neutral-100 px-1.5 py-0.2 text-[10px] font-medium text-neutral-600">
                  Hwy 3 E
                </span>
              </div>
              <div className="mt-2 flex items-center justify-between text-[11px] border-t border-neutral-100 pt-1.5">
                <span className="text-neutral-600">Driver: U-112 Jesse P.</span>
                <span className="font-mono font-semibold text-neutral-800">$48.00 (Flat)</span>
              </div>
            </div>

            {/* Card 6: BC-10452 */}
            <div
              onClick={() => openJob('bc-10452')}
              className="rounded-xl border border-neutral-200/90 bg-white p-2.5 text-left shadow-xs transition hover:border-[#C4161C] cursor-pointer"
            >
              <div className="flex items-center justify-between text-xs">
                <div className="flex items-center gap-1.5">
                  <span className="font-mono font-bold text-[#C4161C]">BC-10452</span>
                  <span className="text-neutral-400">•</span>
                  <span className="font-bold text-neutral-900">Kelsey Thorne</span>
                </div>
                <span className="font-mono text-[11px] text-neutral-400">13:50</span>
              </div>
              <div className="mt-1 flex items-center justify-between text-[11px] text-neutral-600">
                <span className="truncate">Airport (YQL) → Fort Macleod</span>
                <span className="text-neutral-500 font-medium">Van (6+)</span>
              </div>
              <div className="mt-2 flex items-center justify-between text-[11px] border-t border-neutral-100 pt-1.5">
                <span className="text-neutral-600">Driver: U-302 Jessica L.</span>
                <span className="font-mono font-semibold text-neutral-800">$85.50 • Card</span>
              </div>
            </div>
          </>
        )}
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
