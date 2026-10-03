import { createHash, createHmac, timingSafeEqual } from 'node:crypto';
import type { DistanceSource } from './distance.service.js';

export type QuoteZone = 'INSIDE_TOWN' | 'OUT_OF_TOWN';

export type QuotePayload = {
  branchId: string;
  vehicleTypeId: string;
  zone: QuoteZone;
  stopsHash: string;
  distanceM: number;
  durationS: number;
  subtotalCents: number;
  taxCents: number;
  totalCents: number;
  source: DistanceSource;
  exp: number;
};

export type QuoteCheck = {
  stopsHash: string;
  vehicleTypeId: string;
  zone: QuoteZone;
  branchId: string;
};

export function stopsHash(stops: { lat: number; lng: number }[]) {
  const canonical = stops.map((stop) => `${stop.lat},${stop.lng}`).join('|');
  return createHash('sha256').update(canonical).digest('hex');
}

export function signQuote(payload: QuotePayload, secret: string) {
  const body = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const sig = createHmac('sha256', secret).update(body).digest('base64url');
  return `${body}.${sig}`;
}

/** Signature, expiry, then the trip the client is trying to book. */
export function verifyQuote(
  token: string,
  secret: string,
  expected: QuoteCheck,
  nowMs = Date.now(),
): QuotePayload | null {
  const parts = token.split('.');
  if (parts.length !== 2) return null;
  const [body, sig] = parts;
  if (!body || !sig) return null;

  const expectedSig = createHmac('sha256', secret)
    .update(body)
    .digest('base64url');
  const left = Buffer.from(sig);
  const right = Buffer.from(expectedSig);
  if (left.length !== right.length || !timingSafeEqual(left, right))
    return null;

  let parsed: unknown;
  try {
    parsed = JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
  } catch {
    return null;
  }
  if (!isPayload(parsed)) return null;
  if (parsed.exp <= Math.floor(nowMs / 1000)) return null;
  if (
    parsed.stopsHash !== expected.stopsHash ||
    parsed.vehicleTypeId !== expected.vehicleTypeId ||
    parsed.zone !== expected.zone ||
    parsed.branchId !== expected.branchId
  ) {
    return null;
  }
  return parsed;
}

function isPayload(value: unknown): value is QuotePayload {
  if (!isRecord(value)) return false;
  return (
    typeof value.branchId === 'string' &&
    typeof value.vehicleTypeId === 'string' &&
    (value.zone === 'INSIDE_TOWN' || value.zone === 'OUT_OF_TOWN') &&
    typeof value.stopsHash === 'string' &&
    Number.isInteger(value.distanceM) &&
    Number.isInteger(value.durationS) &&
    Number.isInteger(value.subtotalCents) &&
    Number.isInteger(value.taxCents) &&
    Number.isInteger(value.totalCents) &&
    (value.source === 'ROUTES' || value.source === 'ESTIMATE') &&
    Number.isInteger(value.exp)
  );
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
