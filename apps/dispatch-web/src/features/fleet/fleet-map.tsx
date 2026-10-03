import { APIProvider, AdvancedMarker, Map } from '@vis.gl/react-google-maps'
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

/**
 * Mounted once for the life of the console. `reuseMaps` keeps the Google map
 * instance if React remounts this component, so a reload is not billed again.
 */
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
    return (
      <div className="text-muted-foreground grid h-full place-items-center px-6 text-center text-sm">
        Add VITE_GOOGLE_MAPS_KEY and VITE_GOOGLE_MAPS_MAP_ID to load the map.
      </div>
    )
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
      </div>
    </APIProvider>
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
    <div className="absolute bottom-3 left-1/2 z-20 w-[min(22rem,calc(100%-1.5rem))] -translate-x-1/2 rounded-lg border bg-card p-3 shadow-lg">
      <p className="text-sm font-medium">
        Assign to Unit {prompt.unit} ({formatDistance(prompt.distanceM)} away)
      </p>
      <p className="text-muted-foreground text-xs">{prompt.name}</p>
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
