import { Injectable } from '@nestjs/common';

export type GeoPoint = { lat: number; lng: number };

export interface DistanceService {
  estimate(
    from: GeoPoint,
    to: GeoPoint,
    via?: GeoPoint[],
  ): Promise<{ meters: number; seconds: number }>;
}

export const DISTANCE_SERVICE = Symbol('DistanceService');

const EARTH_RADIUS_M = 6_371_000;
const ROAD_FACTOR = 1.3;
const AVERAGE_SPEED_KMH = 40;

@Injectable()
export class HaversineDistanceService implements DistanceService {
  async estimate(from: GeoPoint, to: GeoPoint, via: GeoPoint[] = []) {
    const points = [from, ...via, to];
    let straight = 0;
    for (let i = 1; i < points.length; i += 1) {
      straight += haversineMeters(points[i - 1], points[i]);
    }
    const meters = Math.round(straight * ROAD_FACTOR);
    const seconds = Math.round((meters / (AVERAGE_SPEED_KMH * 1000)) * 3600);
    return { meters, seconds };
  }
}

function haversineMeters(a: GeoPoint, b: GeoPoint) {
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const lat1 = toRad(a.lat);
  const lat2 = toRad(b.lat);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * EARTH_RADIUS_M * Math.asin(Math.min(1, Math.sqrt(h)));
}

function toRad(degrees: number) {
  return (degrees * Math.PI) / 180;
}
