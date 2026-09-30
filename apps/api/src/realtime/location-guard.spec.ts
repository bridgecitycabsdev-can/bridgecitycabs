import { describe, expect, it } from 'vitest';
import {
  evaluateLocationPing,
  freshBucket,
  haversineMeters,
  historyRecordedAt,
  impliedSpeedMps,
} from './location-guard.js';

const lethbridge = { lat: 49.6935, lng: -112.8418 };
const calgary = { lat: 51.0447, lng: -114.0719 };
const now = Date.parse('2026-09-30T15:00:00.000Z');

function ping(point: { lat: number; lng: number }, recordedAt = new Date(now).toISOString()) {
  return {
    ...point,
    accuracyM: 8,
    recordedAt,
  };
}

describe('location guard', () => {
  it('measures Lethbridge to Calgary in a straight line', () => {
    const meters = haversineMeters(lethbridge, calgary);
    expect(meters).toBeGreaterThan(150_000);
    expect(meters).toBeLessThan(200_000);
  });

  it('drops accuracy over 100 metres and a second ping inside the same second', () => {
    const bucket = freshBucket(now);
    expect(
      evaluateLocationPing({
        payload: { ...ping(lethbridge), accuracyM: 101 },
        nowMs: now,
        bucket,
      }).accept,
    ).toBe(false);

    const first = evaluateLocationPing({
      payload: ping(lethbridge),
      nowMs: now,
      bucket,
    });
    expect(first.accept).toBe(true);
    expect(
      evaluateLocationPing({
        payload: ping({ lat: 49.69395, lng: -112.8418 }),
        nowMs: now + 200,
        bucket,
        lastPoint: first.accept ? first.point : undefined,
      }).accept,
    ).toBe(false);
  });

  it('drops a jump to Calgary and keeps a short move', () => {
    const bucket = freshBucket(now);
    const first = evaluateLocationPing({
      payload: ping(lethbridge),
      nowMs: now,
      bucket,
    });
    expect(first.accept).toBe(true);
    if (!first.accept) return;

    const glitch = evaluateLocationPing({
      payload: ping(calgary),
      nowMs: now + 1_000,
      bucket: freshBucket(now + 1_000),
      lastPoint: first.point,
    });
    expect(glitch.accept).toBe(false);
    expect(
      impliedSpeedMps(first.point, {
        ...calgary,
        receivedAtMs: now + 1_000,
      }),
    ).toBeGreaterThan(70);

    const nearby = evaluateLocationPing({
      payload: ping({ lat: 49.69395, lng: -112.8418 }),
      nowMs: now + 1_000,
      bucket: freshBucket(now + 1_000),
      lastPoint: first.point,
    });
    expect(nearby.accept).toBe(true);
  });

  it('uses the client timestamp only within about five seconds', () => {
    expect(historyRecordedAt('2026-09-30T15:00:02.000Z', now)).toBe(
      '2026-09-30T15:00:02.000Z',
    );
    expect(historyRecordedAt('2026-09-30T14:00:00.000Z', now)).toBe(
      '2026-09-30T15:00:00.000Z',
    );
  });
});
