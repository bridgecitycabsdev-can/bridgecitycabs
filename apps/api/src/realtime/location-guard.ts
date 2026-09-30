import type { DriverLocation } from '@bridgecabs/shared-types';

export const MAX_ACCURACY_M = 100;
export const MAX_SPEED_MPS = 70;
export const CLIENT_CLOCK_SKEW_MS = 5_000;
const EARTH_RADIUS_M = 6_371_000;

export type LocationSample = {
  lat: number;
  lng: number;
  receivedAtMs: number;
};

export type TokenBucket = {
  tokens: number;
  updatedAtMs: number;
};

export function freshBucket(nowMs: number): TokenBucket {
  return { tokens: 1, updatedAtMs: nowMs };
}

/** One ping per second. The bucket lives on the socket, not in Redis. */
export function takeToken(bucket: TokenBucket, nowMs: number) {
  const elapsed = Math.max(0, nowMs - bucket.updatedAtMs);
  bucket.tokens = Math.min(1, bucket.tokens + elapsed / 1000);
  bucket.updatedAtMs = nowMs;
  if (bucket.tokens < 1) return false;
  bucket.tokens -= 1;
  return true;
}

export function haversineMeters(
  from: { lat: number; lng: number },
  to: { lat: number; lng: number },
) {
  const dLat = toRad(to.lat - from.lat);
  const dLng = toRad(to.lng - from.lng);
  const lat1 = toRad(from.lat);
  const lat2 = toRad(to.lat);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * EARTH_RADIUS_M * Math.asin(Math.min(1, Math.sqrt(h)));
}

export function impliedSpeedMps(from: LocationSample, to: LocationSample) {
  const seconds = (to.receivedAtMs - from.receivedAtMs) / 1000;
  if (seconds <= 0) return Number.POSITIVE_INFINITY;
  return haversineMeters(from, to) / seconds;
}

/** Client clocks are trusted for history only when they are close to the server. */
export function historyRecordedAt(clientIso: string, serverMs: number) {
  const clientMs = Date.parse(clientIso);
  if (!Number.isFinite(clientMs) || Math.abs(clientMs - serverMs) > CLIENT_CLOCK_SKEW_MS) {
    return new Date(serverMs).toISOString();
  }
  return new Date(clientMs).toISOString();
}

export function evaluateLocationPing(input: {
  payload: DriverLocation;
  nowMs: number;
  bucket: TokenBucket;
  lastPoint?: LocationSample;
}):
  | { accept: false }
  | { accept: true; recordedAt: string; point: LocationSample } {
  if (input.payload.accuracyM == null || input.payload.accuracyM > MAX_ACCURACY_M) {
    return { accept: false };
  }
  if (!takeToken(input.bucket, input.nowMs)) return { accept: false };
  const point = {
    lat: input.payload.lat,
    lng: input.payload.lng,
    receivedAtMs: input.nowMs,
  };
  if (input.lastPoint && impliedSpeedMps(input.lastPoint, point) > MAX_SPEED_MPS) {
    return { accept: false };
  }
  return {
    accept: true,
    recordedAt: historyRecordedAt(input.payload.recordedAt, input.nowMs),
    point,
  };
}

function toRad(degrees: number) {
  return (degrees * Math.PI) / 180;
}
