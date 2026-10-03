import { HttpStatus, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ApiCode } from '../common/api-code.js';
import { ApiException } from '../common/api-exception.js';
import { googleServerKey } from '../common/google-server-key.js';
import { isPlaceId } from './place-id.js';
import type {
  PlaceBias,
  PlaceDetails,
  PlaceSuggestion,
  PlacesProvider,
  ReverseGeocode,
} from './places.provider.js';

const TIMEOUT_MS = 3_000;
const BIAS_RADIUS_METERS = 30_000;
const AUTOCOMPLETE_URL = 'https://places.googleapis.com/v1/places:autocomplete';
const AUTOCOMPLETE_MASK =
  'suggestions.placePrediction.placeId,suggestions.placePrediction.structuredFormat.mainText.text,suggestions.placePrediction.structuredFormat.secondaryText.text';
const DETAILS_MASK = 'id,formattedAddress,location';
const REVERSE_MASK = 'results.formattedAddress';

/**
 * Places API (New) for autocomplete and details, Geocoding API for reverse lookup.
 * The same session token is sent on autocomplete and on the following Place Details
 * call (`sessionToken` query parameter), which closes the billing session.
 * Autocomplete predictions are not cached.
 */
@Injectable()
export class GooglePlacesProvider implements PlacesProvider {
  private readonly logger = new Logger(GooglePlacesProvider.name);

  constructor(private readonly config: ConfigService) {}

  async autocomplete(input: {
    q: string;
    session: string;
    bias?: PlaceBias;
  }): Promise<PlaceSuggestion[]> {
    const body: Record<string, unknown> = {
      input: input.q,
      sessionToken: input.session,
      includedRegionCodes: ['ca'],
      languageCode: 'en',
      regionCode: 'ca',
    };
    if (input.bias) {
      body.locationBias = {
        circle: {
          center: {
            latitude: input.bias.lat,
            longitude: input.bias.lng,
          },
          radius: BIAS_RADIUS_METERS,
        },
      };
    }

    const payload = await this.send(AUTOCOMPLETE_URL, {
      method: 'POST',
      headers: this.headers(AUTOCOMPLETE_MASK),
      body: JSON.stringify(body),
    });
    return mapAutocomplete(payload);
  }

  async details(input: {
    placeId: string;
    session: string;
  }): Promise<PlaceDetails> {
    if (!isPlaceId(input.placeId)) {
      throw new ApiException(
        HttpStatus.BAD_REQUEST,
        ApiCode.VALIDATION,
        'Validation failed',
        {
          placeId: 'placeId is invalid',
        },
      );
    }

    const url = new URL(
      `https://places.googleapis.com/v1/places/${encodeURIComponent(input.placeId)}`,
    );
    url.searchParams.set('sessionToken', input.session);
    url.searchParams.set('languageCode', 'en');
    url.searchParams.set('regionCode', 'ca');

    const payload = await this.send(
      url,
      { method: 'GET', headers: this.headers(DETAILS_MASK) },
      new ApiException(
        HttpStatus.NOT_FOUND,
        ApiCode.PLACE_NOT_FOUND,
        'Place not found',
      ),
    );
    return mapDetails(payload);
  }

  async reverse(input: { lat: number; lng: number }): Promise<ReverseGeocode> {
    const url = new URL(
      `https://geocode.googleapis.com/v4/geocode/location/${input.lat},${input.lng}`,
    );
    url.searchParams.set('languageCode', 'en');
    url.searchParams.set('regionCode', 'ca');

    const payload = await this.send(url, {
      method: 'GET',
      headers: this.headers(REVERSE_MASK),
    });
    return mapReverse(payload);
  }

  private headers(fieldMask: string): Record<string, string> {
    return {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': this.apiKey(),
      'X-Goog-FieldMask': fieldMask,
    };
  }

  private apiKey(): string {
    const key = googleServerKey(this.config, 'GOOGLE_PLACES_API_KEY');
    if (!key) {
      this.logger.warn('GOOGLE_PLACES_API_KEY is not set');
      throw new ApiException(
        HttpStatus.SERVICE_UNAVAILABLE,
        ApiCode.PLACES_UNAVAILABLE,
        'Address search is not configured',
      );
    }
    return key;
  }

  private async send(
    url: string | URL,
    init: RequestInit,
    notFound?: ApiException,
  ): Promise<unknown> {
    let response: Response;
    try {
      response = await fetch(url, {
        ...init,
        signal: AbortSignal.timeout(TIMEOUT_MS),
      });
    } catch (error) {
      this.unavailable(error);
    }

    if (response.status === 404 && notFound) throw notFound;
    if (!response.ok) {
      this.logger.warn(`Address search failed: HTTP ${response.status}`);
      throw unavailable();
    }

    try {
      return await response.json();
    } catch (error) {
      this.unavailable(error);
    }
  }

  private unavailable(error: unknown): never {
    const name = error instanceof Error ? error.name : 'Error';
    this.logger.warn(`Address search failed: ${name}`);
    throw unavailable();
  }
}

function unavailable() {
  return new ApiException(
    HttpStatus.SERVICE_UNAVAILABLE,
    ApiCode.PLACES_UNAVAILABLE,
    'Address search is temporarily unavailable',
  );
}

function mapAutocomplete(payload: unknown): PlaceSuggestion[] {
  if (!isRecord(payload) || !Array.isArray(payload.suggestions)) return [];
  const suggestions: PlaceSuggestion[] = [];
  for (const suggestion of payload.suggestions) {
    if (!isRecord(suggestion) || !isRecord(suggestion.placePrediction))
      continue;
    const prediction = suggestion.placePrediction;
    const placeId = prediction.placeId;
    const format = prediction.structuredFormat;
    if (typeof placeId !== 'string' || !isPlaceId(placeId) || !isRecord(format))
      continue;
    const primaryText = localizedText(format.mainText);
    if (!primaryText) continue;
    suggestions.push({
      placeId,
      primaryText,
      secondaryText: localizedText(format.secondaryText) ?? '',
    });
  }
  return suggestions;
}

function mapDetails(payload: unknown): PlaceDetails {
  if (
    !isRecord(payload) ||
    typeof payload.id !== 'string' ||
    !isPlaceId(payload.id)
  ) {
    throw unavailable();
  }
  const address = payload.formattedAddress;
  const location = payload.location;
  if (
    typeof address !== 'string' ||
    address.length === 0 ||
    !isRecord(location)
  ) {
    throw new ApiException(
      HttpStatus.NOT_FOUND,
      ApiCode.PLACE_NOT_FOUND,
      'Place not found',
    );
  }
  const { latitude, longitude } = location;
  if (typeof latitude !== 'number' || typeof longitude !== 'number') {
    throw new ApiException(
      HttpStatus.NOT_FOUND,
      ApiCode.PLACE_NOT_FOUND,
      'Place not found',
    );
  }
  return { placeId: payload.id, address, lat: latitude, lng: longitude };
}

function mapReverse(payload: unknown): ReverseGeocode {
  if (
    !isRecord(payload) ||
    !Array.isArray(payload.results) ||
    payload.results.length === 0
  ) {
    throw new ApiException(
      HttpStatus.NOT_FOUND,
      ApiCode.ADDRESS_NOT_FOUND,
      'No address found for that location',
    );
  }
  const first = payload.results[0];
  if (
    !isRecord(first) ||
    typeof first.formattedAddress !== 'string' ||
    first.formattedAddress.length === 0
  ) {
    throw new ApiException(
      HttpStatus.NOT_FOUND,
      ApiCode.ADDRESS_NOT_FOUND,
      'No address found for that location',
    );
  }
  return { address: first.formattedAddress };
}

function localizedText(value: unknown): string | undefined {
  if (
    !isRecord(value) ||
    typeof value.text !== 'string' ||
    value.text.length === 0
  ) {
    return undefined;
  }
  return value.text;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
