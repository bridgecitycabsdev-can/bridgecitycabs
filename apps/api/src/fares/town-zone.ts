import { haversineMeters, type GeoPoint } from './distance.service.js';

export type TownCentre = { lat: number; lng: number };

/**
 * Inside town when every stop is within the branch radius.
 * One stop outside town makes the whole trip out of town.
 * Returns null when the branch has no centre, so the caller cannot guess.
 */
export function deriveZone(
  centre: TownCentre | null,
  radiusKm: number,
  stops: GeoPoint[],
): 'INSIDE_TOWN' | 'OUT_OF_TOWN' | null {
  if (!centre) return null;
  const limitM = radiusKm * 1000;
  const inside = stops.every((stop) => haversineMeters(centre, stop) <= limitM);
  return inside ? 'INSIDE_TOWN' : 'OUT_OF_TOWN';
}
