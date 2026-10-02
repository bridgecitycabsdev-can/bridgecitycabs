import type { FleetDriver } from '@bridgecabs/shared-types';

/** Fields GET /fleet/drivers returns to the dispatch console. */
export function toDispatchDriver(driver: FleetDriver) {
  return {
    id: driver.id,
    name: driver.name,
    unitNumber: driver.unit,
    vehicleType: driver.vehicleType,
    status: driver.status,
    lat: driver.lat,
    lng: driver.lng,
    ts: driver.ts,
    stale: driver.stale,
  };
}
