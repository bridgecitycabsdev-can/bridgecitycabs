import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { googleServerKey } from '../common/google-server-key.js';
import {
  HaversineDistanceService,
  type DistanceService,
  type GeoPoint,
  type TripMeasure,
} from './distance.service.js';

const ROUTES_URL = 'https://routes.googleapis.com/directions/v2:computeRoutes';
const FIELD_MASK = 'routes.distanceMeters,routes.duration';
const TIMEOUT_MS = 3_000;

/**
 * Routes API computeRoutes. The key is server-only and must be restricted to
 * the Routes API, with a per-API quota and a billing alert. A failed lookup
 * falls back to the straight-line estimate so dispatch can still book.
 */
@Injectable()
export class GoogleRoutesDistanceService implements DistanceService {
  private readonly logger = new Logger(GoogleRoutesDistanceService.name);

  constructor(
    private readonly config: ConfigService,
    private readonly haversine: HaversineDistanceService,
  ) {}

  async estimate(
    from: GeoPoint,
    to: GeoPoint,
    via: GeoPoint[] = [],
  ): Promise<TripMeasure> {
    const key = googleServerKey(this.config, 'GOOGLE_ROUTES_API_KEY');
    if (!key) {
      this.logger.warn('GOOGLE_ROUTES_API_KEY is not set');
      return this.fallback(from, to, via);
    }

    try {
      const measured = await this.computeRoutes(key, from, to, via);
      if (!measured) return this.fallback(from, to, via);
      return measured;
    } catch (error) {
      const name = error instanceof Error ? error.name : 'Error';
      this.logger.warn(`Routes request failed: ${name}`);
      return this.fallback(from, to, via);
    }
  }

  private async computeRoutes(
    key: string,
    from: GeoPoint,
    to: GeoPoint,
    via: GeoPoint[],
  ): Promise<TripMeasure | null> {
    const body: Record<string, unknown> = {
      origin: waypoint(from),
      destination: waypoint(to),
      travelMode: 'DRIVE',
    };
    if (via.length > 0) body.intermediates = via.map(waypoint);

    const response = await fetch(ROUTES_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': key,
        'X-Goog-FieldMask': FIELD_MASK,
      },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(TIMEOUT_MS),
    });
    if (!response.ok) {
      this.logger.warn(`Routes request failed: HTTP ${response.status}`);
      return null;
    }

    let payload: unknown;
    try {
      payload = await response.json();
    } catch {
      return null;
    }
    return readRoute(payload);
  }

  private async fallback(
    from: GeoPoint,
    to: GeoPoint,
    via: GeoPoint[],
  ): Promise<TripMeasure> {
    const estimate = await this.haversine.estimate(from, to, via);
    return {
      meters: estimate.meters,
      seconds: estimate.seconds,
      source: 'ESTIMATE',
    };
  }
}

function waypoint(point: GeoPoint) {
  return {
    location: {
      latLng: { latitude: point.lat, longitude: point.lng },
    },
  };
}

function readRoute(payload: unknown): TripMeasure | null {
  if (
    !isRecord(payload) ||
    !Array.isArray(payload.routes) ||
    payload.routes.length === 0
  ) {
    return null;
  }
  const route = payload.routes[0];
  if (!isRecord(route) || typeof route.distanceMeters !== 'number') return null;
  const seconds = durationSeconds(route.duration);
  if (seconds == null) return null;
  return {
    meters: Math.round(route.distanceMeters),
    seconds,
    source: 'ROUTES',
  };
}

function durationSeconds(value: unknown): number | null {
  if (typeof value !== 'string') return null;
  const match = /^(\d+(?:\.\d+)?)s$/.exec(value);
  if (!match?.[1]) return null;
  const seconds = Number(match[1]);
  if (!Number.isFinite(seconds)) return null;
  return Math.round(seconds);
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
