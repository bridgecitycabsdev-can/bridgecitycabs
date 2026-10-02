import { APIProvider, AdvancedMarker, Map } from '@vis.gl/react-google-maps'
import { memo } from 'react'
import { useStoreWithEqualityFn } from 'zustand/traditional'
import { driverMarkerView, useFleet, visibleDriverIds } from '@/features/fleet/store'
import { env } from '@/lib/env'

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

  if (!env.googleMapsKey || !env.googleMapsMapId) {
    return (
      <div className="text-muted-foreground grid h-full place-items-center px-6 text-center text-sm">
        Add VITE_GOOGLE_MAPS_KEY and VITE_GOOGLE_MAPS_MAP_ID to load the map.
      </div>
    )
  }

  return (
    <APIProvider apiKey={env.googleMapsKey}>
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
      </Map>
    </APIProvider>
  )
}

const DriverMarker = memo(function DriverMarker({ id }: { id: string }) {
  const driver = useFleet((state) => state.drivers[id])
  if (!driver || driver.lat == null || driver.lng == null) return null
  const marker = driverMarkerView(driver)
  return (
    <AdvancedMarker position={{ lat: driver.lat, lng: driver.lng }} title={markerTitle(driver)}>
      <span
        className="inline-flex min-w-7 items-center justify-center rounded-full border-2 border-white px-1.5 text-[11px] leading-6 font-semibold text-white shadow"
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

function markerTitle(driver: { name: string; unit: string; stale: boolean }) {
  return driver.stale ? `${driver.unit} ${driver.name} · stale` : `${driver.unit} ${driver.name}`
}
