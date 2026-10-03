import { HttpStatus } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { ApiCode } from '../common/api-code.js';
import { ApiException } from '../common/api-exception.js';
import { GooglePlacesProvider } from './google-places.provider.js';

const SESSION = '3519edfe-0f75-4a30-bfe4-7cbd89340b2c';
const PLACE_ID = 'ChIJj61dQgK6j4AR4GeTYWZsKWw';

function provider(key = 'test-key') {
  return new GooglePlacesProvider({
    get: (name: string) => (name === 'GOOGLE_PLACES_API_KEY' ? key : undefined),
  } as ConfigService);
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function stubFetch(
  impl: (url: string, init?: RequestInit) => Promise<Response>,
) {
  const fetchMock = vi.fn(impl);
  vi.stubGlobal('fetch', fetchMock);
  return fetchMock;
}

function firstCall(
  fetchMock: ReturnType<typeof stubFetch>,
): [string, RequestInit] {
  const call = fetchMock.mock.calls[0];
  if (!call?.[1]) throw new Error('fetch was not called');
  return [call[0], call[1]];
}

function jsonBody(init: RequestInit): string {
  if (typeof init.body !== 'string') {
    throw new Error('expected a JSON string body');
  }
  return init.body;
}

describe('GooglePlacesProvider', () => {
  afterEach(() => {
    vi.unstubAllGlobals();
  });

  it('biases autocomplete to Canada and maps only place predictions', async () => {
    const fetchMock = stubFetch(async () =>
      json({
        suggestions: [
          {
            placePrediction: {
              placeId: PLACE_ID,
              structuredFormat: {
                mainText: { text: 'City Hall' },
                secondaryText: { text: 'Lethbridge, AB, Canada' },
              },
              types: ['point_of_interest'],
            },
          },
          { queryPrediction: { text: { text: 'city hall lethbridge' } } },
        ],
      }),
    );

    await expect(
      provider().autocomplete({
        q: 'city hall',
        session: SESSION,
        bias: { lat: 49.6935, lng: -112.8418 },
      }),
    ).resolves.toEqual([
      {
        placeId: PLACE_ID,
        primaryText: 'City Hall',
        secondaryText: 'Lethbridge, AB, Canada',
      },
    ]);

    const [url, init] = firstCall(fetchMock);
    expect(url).toBe('https://places.googleapis.com/v1/places:autocomplete');
    expect(init.method).toBe('POST');
    expect(init.signal).toBeInstanceOf(AbortSignal);
    const headers = init.headers as Record<string, string>;
    expect(headers['X-Goog-Api-Key']).toBe('test-key');
    expect(headers['X-Goog-FieldMask']).toContain(
      'structuredFormat.mainText.text',
    );
    expect(JSON.parse(jsonBody(init))).toEqual({
      input: 'city hall',
      sessionToken: SESSION,
      includedRegionCodes: ['ca'],
      languageCode: 'en',
      regionCode: 'ca',
      locationBias: {
        circle: {
          center: { latitude: 49.6935, longitude: -112.8418 },
          radius: 30_000,
        },
      },
    });
  });

  it('omits location bias when the branch has no centre', async () => {
    const fetchMock = stubFetch(async () => json({ suggestions: [] }));
    await provider().autocomplete({ q: 'main', session: SESSION });
    const body = JSON.parse(jsonBody(firstCall(fetchMock)[1]));
    expect(body.locationBias).toBeUndefined();
  });

  it('sends the session token on place details and returns our shape', async () => {
    const fetchMock = stubFetch(async () =>
      json({
        id: PLACE_ID,
        formattedAddress: '910 4 Ave S, Lethbridge, AB T1J 0P6, Canada',
        location: { latitude: 49.6935, longitude: -112.8418 },
        displayName: { text: 'should not leak' },
      }),
    );

    await expect(
      provider().details({ placeId: PLACE_ID, session: SESSION }),
    ).resolves.toEqual({
      placeId: PLACE_ID,
      address: '910 4 Ave S, Lethbridge, AB T1J 0P6, Canada',
      lat: 49.6935,
      lng: -112.8418,
    });

    const [rawUrl, init] = firstCall(fetchMock);
    const url = new URL(rawUrl);
    expect(url.origin + url.pathname).toBe(
      `https://places.googleapis.com/v1/places/${encodeURIComponent(PLACE_ID)}`,
    );
    expect(url.searchParams.get('sessionToken')).toBe(SESSION);
    const headers = init.headers as Record<string, string>;
    expect(headers['X-Goog-FieldMask']).toBe('id,formattedAddress,location');
  });

  it('rejects a place id that is not a safe path segment before calling Google', async () => {
    const fetchMock = vi.fn();
    vi.stubGlobal('fetch', fetchMock);
    await expect(
      provider().details({ placeId: '../secrets', session: SESSION }),
    ).rejects.toMatchObject({
      status: HttpStatus.BAD_REQUEST,
    });
    expect(fetchMock).not.toHaveBeenCalled();
  });

  it('reverse geocodes with the Geocoding API and returns only the address', async () => {
    const fetchMock = stubFetch(async () =>
      json({
        results: [
          {
            formattedAddress: '910 4 Ave S, Lethbridge, AB T1J 0P6, Canada',
            placeId: PLACE_ID,
          },
        ],
        plusCode: { globalCode: 'not-for-clients' },
      }),
    );

    await expect(
      provider().reverse({ lat: 49.6935, lng: -112.8418 }),
    ).resolves.toEqual({
      address: '910 4 Ave S, Lethbridge, AB T1J 0P6, Canada',
    });

    const url = new URL(firstCall(fetchMock)[0]);
    expect(url.origin + url.pathname).toBe(
      'https://geocode.googleapis.com/v4/geocode/location/49.6935,-112.8418',
    );
    expect(url.searchParams.get('languageCode')).toBe('en');
    expect(url.searchParams.get('regionCode')).toBe('ca');
  });

  it('returns no address when the geocoder has no result', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn(async () => json({ results: [] })),
    );
    await expect(provider().reverse({ lat: 0, lng: 0 })).rejects.toBeInstanceOf(
      ApiException,
    );
    await expect(provider().reverse({ lat: 0, lng: 0 })).rejects.toMatchObject({
      response: { code: ApiCode.ADDRESS_NOT_FOUND },
    });
  });

  it('does not pass a Google error body through', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn(async () => json({ error: { message: 'API key not valid' } }, 403)),
    );
    const error = await provider()
      .autocomplete({ q: 'city', session: SESSION })
      .catch((caught: unknown) => caught);
    expect(error).toBeInstanceOf(ApiException);
    expect(JSON.stringify((error as ApiException).getResponse())).not.toContain(
      'API key',
    );
  });

  it('never returns the Google key or raw Google payloads to clients', async () => {
    stubFetch(async () =>
      json({
        suggestions: [
          {
            placePrediction: {
              placeId: PLACE_ID,
              structuredFormat: {
                mainText: { text: 'City Hall' },
                secondaryText: { text: 'Lethbridge, AB, Canada' },
              },
            },
          },
        ],
      }),
    );
    const rows = await provider().autocomplete({
      q: 'city',
      session: SESSION,
      bias: { lat: 49.6935, lng: -112.8418 },
    });
    const body = JSON.stringify(rows);
    expect(body).not.toMatch(/AIza|GOOGLE_|X-Goog-Api-Key|api[_-]?key|test-key/i);
    expect(rows[0]).toEqual({
      placeId: PLACE_ID,
      primaryText: 'City Hall',
      secondaryText: 'Lethbridge, AB, Canada',
    });
  });

  it('reports a timeout as address search unavailable', async () => {
    vi.stubGlobal(
      'fetch',
      vi.fn(async () => {
        throw Object.assign(new Error('timed out'), { name: 'TimeoutError' });
      }),
    );
    await expect(
      provider().autocomplete({ q: 'city', session: SESSION }),
    ).rejects.toMatchObject({
      response: { code: ApiCode.PLACES_UNAVAILABLE },
    });
  });

  it('does not call Google when the key is missing', async () => {
    const fetchMock = vi.fn();
    vi.stubGlobal('fetch', fetchMock);
    await expect(
      provider('').autocomplete({ q: 'city', session: SESSION }),
    ).rejects.toMatchObject({
      response: {
        code: ApiCode.PLACES_UNAVAILABLE,
        message: 'Address search is not configured',
      },
    });
    expect(fetchMock).not.toHaveBeenCalled();
  });
});
