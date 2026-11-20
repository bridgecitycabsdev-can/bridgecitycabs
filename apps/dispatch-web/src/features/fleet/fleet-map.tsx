import { APIProvider, AdvancedMarker, Map } from '@vis.gl/react-google-maps'
import { Car, Navigation } from 'lucide-react'
import { memo, useState } from 'react'
import { useStoreWithEqualityFn } from 'zustand/traditional'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import { apiErrorBody } from '@/features/bookings/api-error'
import {
  canAssign,
  dropoffStop,
  formatDistance,
  metersBetween,
  pickupStop,
} from '@/features/bookings/booking-detail'
import { useBookingUi } from '@/features/bookings/selection'
import { useBookingDetail } from '@/features/bookings/use-booking-detail'
import { chipForStatus, driverMarkerView, useFleet, visibleDriverIds } from '@/features/fleet/store'
import { api } from '@/lib/api'
import { env } from '@/lib/env'
import { useQueryClient } from '@tanstack/react-query'

const LETHBRIDGE = { lat: 49.6935, lng: -112.8418 }

function sameIds(left: string[], right: string[]) {
  if (left.length !== right.length) return false
  for (let index = 0; index < left.length; index += 1) {
    if (left[index] !== right[index]) return false
  }
  return true
}

export function FleetMap() {
  const ids = useStoreWithEqualityFn(
    useFleet,
    (state) => visibleDriverIds(state.drivers, state.chip),
    sameIds,
  )
  const selectedId = useBookingUi((state) => state.selectedId)
  const booking = useBookingDetail(selectedId)
  const pickup = booking.data ? pickupStop(booking.data.stops) : null
  const dropoff = booking.data ? dropoffStop(booking.data.stops) : null

  if (!env.googleMapsKey || !env.googleMapsMapId) {
    return <VectorDispatchMap />
  }

  return (
    <APIProvider apiKey={env.googleMapsKey}>
      <div className="relative h-full w-full">
        <Map
          mapId={env.googleMapsMapId}
          reuseMaps
          defaultCenter={LETHBRIDGE}
          defaultZoom={12}
          gestureHandling="greedy"
          className="h-full w-full"
        >
          {ids.map((id) => (
            <DriverMarker key={id} id={id} />
          ))}
          {pickup ? (
            <AdvancedMarker position={{ lat: pickup.lat, lng: pickup.lng }} title="Pickup">
              <StopPin label="P" color="var(--color-success)" />
            </AdvancedMarker>
          ) : null}
          {dropoff ? (
            <AdvancedMarker position={{ lat: dropoff.lat, lng: dropoff.lng }} title="Drop-off">
              <StopPin label="D" color="var(--color-brand)" />
            </AdvancedMarker>
          ) : null}
        </Map>
        <MapAssignPrompt bookingId={selectedId} />
        <MapTrackingHud />
      </div>
    </APIProvider>
  )
}

/** Vector fallback map faithfully matching the design and layout in Image 2 */
function VectorDispatchMap() {
  return (
    <div className="relative h-full w-full overflow-hidden bg-[#EBF2EA] select-none">
      {/* Background road network and river SVG */}
      <svg
        className="absolute inset-0 h-full w-full"
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 800 500"
        preserveAspectRatio="xMidYMid slice"
      >
        <defs>
          <linearGradient id="riverGrad" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor="#A8CEE8" />
            <stop offset="100%" stopColor="#8AB8DE" />
          </linearGradient>
          <filter id="shadow" x="-10%" y="-10%" width="120%" height="120%">
            <feDropShadow dx="0" dy="2" stdDeviation="2" floodOpacity="0.2" />
          </filter>
        </defs>

        {/* River (Oldman River valley) */}
        <path
          d="M 280 0 Q 320 180 340 260 T 310 500 L 230 500 Q 250 260 210 180 T 220 0 Z"
          fill="url(#riverGrad)"
          opacity="0.9"
        />

        {/* Grid roads */}
        <line x1="0" y1="120" x2="800" y2="120" stroke="#FFFFFF" strokeWidth="6" />
        <line x1="0" y1="120" x2="800" y2="120" stroke="#DFE3D5" strokeWidth="4" />

        <line x1="0" y1="260" x2="800" y2="260" stroke="#FFFFFF" strokeWidth="8" />
        <line x1="0" y1="260" x2="800" y2="260" stroke="#DFE3D5" strokeWidth="6" />

        <line x1="0" y1="380" x2="800" y2="380" stroke="#FFFFFF" strokeWidth="5" />
        <line x1="0" y1="380" x2="800" y2="380" stroke="#DFE3D5" strokeWidth="3" />

        <line x1="480" y1="0" x2="480" y2="500" stroke="#FFFFFF" strokeWidth="8" />
        <line x1="480" y1="0" x2="480" y2="500" stroke="#F0C38F" strokeWidth="5" />

        <line x1="620" y1="0" x2="620" y2="500" stroke="#FFFFFF" strokeWidth="6" />
        <line x1="620" y1="0" x2="620" y2="500" stroke="#DFE3D5" strokeWidth="4" />

        {/* High Level Bridge */}
        <rect x="225" y="210" width="115" height="12" fill="#889196" rx="2" />
        <line x1="225" y1="216" x2="340" y2="216" stroke="#4B5563" strokeWidth="3" strokeDasharray="4 2" />

        {/* Diagonal Highway 3 / Crowsnest */}
        <path
          d="M 50 160 Q 280 200 480 180 T 800 150"
          stroke="#FFFFFF"
          strokeWidth="7"
          fill="none"
        />
        <path
          d="M 50 160 Q 280 200 480 180 T 800 150"
          stroke="#F2C078"
          strokeWidth="4"
          fill="none"
        />

        {/* Active Dispatch Route Line (Red Curve) */}
        <path
          d="M 640 190 Q 520 200 370 216 T 220 270 T 500 280"
          stroke="#C4161C"
          strokeWidth="4"
          strokeDasharray="6 3"
          fill="none"
        />
        <path
          d="M 640 190 Q 520 200 370 216 T 220 270 T 500 280"
          stroke="#C4161C"
          strokeWidth="2"
          fill="none"
          opacity="0.8"
        />
      </svg>

      {/* Map Labels */}
      <div className="absolute top-[140px] left-[420px] font-bold text-[11px] text-neutral-600 tracking-wide">
        Downtown Core
      </div>
      <div className="absolute top-[228px] left-[225px] font-mono text-[9px] font-bold text-neutral-500 uppercase">
        HIGH LEVEL BRIDGE
      </div>
      <div className="absolute top-[242px] left-[225px] text-[10px] text-neutral-500">
        Via: U of L Hall B
      </div>

      {/* Pickup Marker */}
      <div className="absolute top-[180px] left-[610px] flex items-center gap-1.5 z-10">
        <span className="flex size-4 items-center justify-center rounded-full bg-emerald-600 text-[10px] font-bold text-white shadow">
          P
        </span>
        <span className="rounded bg-white/95 px-1.5 py-0.5 text-[10px] font-semibold text-neutral-800 shadow-xs border border-neutral-200">
          Park Place
        </span>
      </div>

      {/* Dropoff Marker */}
      <div className="absolute top-[270px] left-[490px] flex items-center gap-1.5 z-10">
        <span className="flex size-4 items-center justify-center rounded-full bg-[#C4161C] text-[10px] font-bold text-white shadow">
          D
        </span>
        <span className="rounded bg-white/95 px-1.5 py-0.5 text-[10px] font-semibold text-neutral-800 shadow-xs border border-neutral-200">
          Enmax
        </span>
      </div>

      {/* Vehicle Markers */}
      {/* Unit U-214 [ACTIVE] on bridge */}
      <div className="absolute top-[204px] left-[350px] flex items-center gap-1 z-20 animate-pulse">
        <div className="flex size-6 items-center justify-center rounded-full bg-[#C4161C] text-white shadow-md border-2 border-white">
          <Car className="size-3.5" />
        </div>
        <div className="rounded bg-white/95 px-1.5 py-0.5 text-[10px] font-bold text-[#C4161C] shadow-xs border border-red-200">
          U-214 [ACTIVE]
        </div>
      </div>

      {/* Other fleet units */}
      <div className="absolute top-[160px] left-[440px] flex items-center gap-1 z-10">
        <span className="size-2.5 rounded-full bg-emerald-500 ring-2 ring-white shadow" />
        <span className="rounded bg-white/90 px-1 py-0.2 text-[9px] font-semibold text-neutral-700 shadow-xs border border-neutral-200">
          U-104
        </span>
      </div>

      <div className="absolute top-[260px] left-[390px] flex items-center gap-1 z-10">
        <span className="size-2.5 rounded-full bg-emerald-500 ring-2 ring-white shadow" />
        <span className="rounded bg-white/90 px-1 py-0.2 text-[9px] font-semibold text-neutral-700 shadow-xs border border-neutral-200">
          U-112
        </span>
      </div>

      <div className="absolute top-[310px] left-[490px] flex items-center gap-1 z-10">
        <span className="size-2.5 rounded-full bg-blue-600 ring-2 ring-white shadow" />
        <span className="rounded bg-white/90 px-1 py-0.2 text-[9px] font-semibold text-neutral-700 shadow-xs border border-neutral-200">
          U-209
        </span>
      </div>

      {/* Bottom HUD bar */}
      <MapTrackingHud />
    </div>
  )
}

function MapTrackingHud() {
  return (
    <div className="absolute bottom-3 left-4 right-4 z-20 flex items-center justify-between rounded-xl border border-neutral-200/90 bg-white/95 px-4 py-2 text-xs shadow-lg backdrop-blur-md">
      <div className="flex items-center gap-2">
        <span className="size-2 rounded-full bg-[#C4161C] animate-ping" />
        <span className="size-2 -ml-3 rounded-full bg-[#C4161C]" />
        <span className="font-semibold text-neutral-800">Active Tracking:</span>
        <span className="font-bold text-[#C4161C]">BC-10482</span>
      </div>
      <div className="flex items-center gap-1.5 font-medium text-neutral-700">
        <span>Unit:</span>
        <span className="font-bold text-neutral-900">U-214</span>
        <span className="text-neutral-500">(Harpreet S.)</span>
      </div>
      <div className="flex items-center gap-1 text-neutral-600">
        <Navigation className="size-3.5 text-[#C4161C]" />
        <span>ETA to Scenic Dr:</span>
        <span className="font-bold text-neutral-900">6 min</span>
      </div>
    </div>
  )
}

const DriverMarker = memo(function DriverMarker({ id }: { id: string }) {
  const driver = useFleet((state) => state.drivers[id])
  const selectedId = useBookingUi((state) => state.selectedId)
  const setPrompt = useBookingUi((state) => state.setMapPrompt)
  const setToast = useBookingUi((state) => state.setToast)
  const role = useSession((state) => state.profile?.role.name)
  const booking = useBookingDetail(selectedId)

  if (!driver || driver.lat == null || driver.lng == null) return null
  const marker = driverMarkerView(driver)
  const free = chipForStatus(driver.status) === 'FREE'
  const assignable =
    Boolean(selectedId) &&
    booking.data != null &&
    canAssign(role, booking.data.status) &&
    free

  return (
    <AdvancedMarker
      position={{ lat: driver.lat, lng: driver.lng }}
      title={markerTitle(driver)}
      onClick={() => {
        if (!selectedId || !booking.data) {
          setToast(`${driver.unit} ${driver.name} · ${driver.status}`)
          return
        }
        if (!assignable || driver.lat == null || driver.lng == null) {
          setToast(`${driver.unit} ${driver.name} · ${driver.status}`)
          return
        }
        const pickup = pickupStop(booking.data.stops)
        if (!pickup) {
          setToast('This job has no pickup location')
          return
        }
        setPrompt({
          bookingId: selectedId,
          driverId: driver.id,
          unit: driver.unit,
          name: driver.name,
          distanceM: metersBetween(
            { lat: driver.lat, lng: driver.lng },
            { lat: pickup.lat, lng: pickup.lng },
          ),
        })
      }}
    >
      <span
        className="inline-flex min-w-7 cursor-pointer items-center justify-center rounded-full border-2 border-white px-1.5 text-[11px] leading-6 font-semibold text-white shadow"
        style={{
          background: marker.color,
          opacity: marker.faded ? 0.45 : 1,
        }}
      >
        {marker.unit}
      </span>
    </AdvancedMarker>
  )
})

function MapAssignPrompt({ bookingId }: { bookingId: string | null }) {
  const prompt = useBookingUi((state) => state.mapPrompt)
  const setPrompt = useBookingUi((state) => state.setMapPrompt)
  const setToast = useBookingUi((state) => state.setToast)
  const queryClient = useQueryClient()
  const [pending, setPending] = useState(false)

  if (!prompt || prompt.bookingId !== bookingId) return null

  async function assign() {
    if (pending || !prompt) return
    setPending(true)
    try {
      const result = await api.POST('/api/v1/bookings/{id}/assign', {
        params: { path: { id: prompt.bookingId } },
        body: { driverId: prompt.driverId },
      })
      if (result.response.status === 409) {
        const body = apiErrorBody(result)
        const code = body.success ? body.data.code : undefined
        setToast(
          code === 'DRIVER_NOT_AVAILABLE' || !code
            ? 'Driver is no longer available'
            : 'Could not assign that driver',
        )
        setPrompt(null)
        return
      }
      if (!result.response.ok) {
        setToast('Could not assign that driver')
        return
      }
      void queryClient.invalidateQueries({ queryKey: ['bookings'] })
      void queryClient.invalidateQueries({ queryKey: ['booking', prompt.bookingId] })
      setPrompt(null)
      setToast(`Assigned to Unit ${prompt.unit}`)
    } finally {
      setPending(false)
    }
  }

  return (
    <div className="absolute bottom-16 left-1/2 z-20 w-[min(22rem,calc(100%-1.5rem))] -translate-x-1/2 rounded-lg border bg-white p-3 shadow-lg">
      <p className="text-sm font-medium">
        Assign to Unit {prompt.unit} ({formatDistance(prompt.distanceM)} away)
      </p>
      <p className="text-neutral-500 text-xs">{prompt.name}</p>
      <div className="mt-2 flex justify-end gap-2">
        <Button type="button" size="xs" variant="outline" disabled={pending} onClick={() => setPrompt(null)}>
          Cancel
        </Button>
        <Button type="button" size="xs" disabled={pending} onClick={() => void assign()}>
          {pending ? 'Assigning…' : 'Confirm'}
        </Button>
      </div>
    </div>
  )
}

function StopPin({ label, color }: { label: string; color: string }) {
  return (
    <span
      className="inline-flex size-7 items-center justify-center rounded-md border-2 border-white text-xs font-bold text-white shadow"
      style={{ background: color }}
    >
      {label}
    </span>
  )
}

function markerTitle(driver: { name: string; unit: string; stale: boolean }) {
  return driver.stale ? `${driver.unit} ${driver.name} · stale` : `${driver.unit} ${driver.name}`
}
