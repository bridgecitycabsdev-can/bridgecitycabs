import { ConfigService } from '@nestjs/config';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { HaversineDistanceService } from './distance.service.js';
import { GoogleRoutesDistanceService } from './google-routes.distance.js';

const from = { lat: 49.6935, lng: -112.8418 };
const to = { lat: 49.7, lng: -112.84 };
const via = { lat: 49.695, lng: -112.85 };

function service(key = 'routes-key') {
  return new GoogleRoutesDistanceService(
    {
      get: (name: string) =>
        name === 'GOOGLE_ROUTES_API_KEY' ? key : undefined,
    } as ConfigService,
    new HaversineDistanceService(),
  );
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

describe('GoogleRoutesDistanceService', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('asks the Routes API for drive distance and duration', async () => {
    const fetchMock = vi.fn(async (_url: string, _init?: RequestInit) =>
      json({ routes: [{ distanceMeters: 8100, duration: '1020s' }] }),
    );
    vi.stubGlobal('fetch', fetchMock);

    await expect(service().estimate(from, to, [via])).resolves.toEqual({
      meters: 8100,
      seconds: 1020,
      source: 'ROUTES',
    });

    const call = fetchMock.mock.calls[0];
    if (!call?.[1]) throw new Error('fetch was not called');
    const [url, init] = call;
    expect(url).toBe(
      'https://routes.googleapis.com/directions/v2:computeRoutes',
    );
    expect(init.signal).toBeInstanceOf(AbortSignal);
    const headers = init.headers as Record<string, string>;
    expect(headers['X-Goog-Api-Key']).toBe('routes-key');
    expect(headers['X-Goog-FieldMask']).toBe(
      'routes.distanceMeters,routes.duration',
    );
    expect(JSON.parse(jsonBody(init))).toEqual({
      origin: {
        location: { latLng: { latitude: from.lat, longitude: from.lng } },
      },
      destination: {
        location: { latLng: { latitude: to.lat, longitude: to.lng } },
      },
      intermediates: [
        { location: { latLng: { latitude: via.lat, longitude: via.lng } } },
      ],
      travelMode: 'DRIVE',
    });
  });

  it('falls back to the straight-line estimate when routing fails', async () => {
    const straight = await new HaversineDistanceService().estimate(from, to);
    vi.stubGlobal(
      'fetch',
      vi.fn(async () => json({ error: { message: 'denied' } }, 403)),
    );

    await expect(service().estimate(from, to)).resolves.toEqual({
      ...straight,
      source: 'ESTIMATE',
    });
  });

  it('does not call Google when the routes key is missing', async () => {
    const fetchMock = vi.fn();
    vi.stubGlobal('fetch', fetchMock);
    const measured = await service('').estimate(from, to);
    expect(measured.source).toBe('ESTIMATE');
    expect(fetchMock).not.toHaveBeenCalled();
  });
});

function jsonBody(init: RequestInit) {
  if (typeof init.body !== 'string')
    throw new Error('expected a JSON string body');
  return init.body;
}
