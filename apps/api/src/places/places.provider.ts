export type PlaceSuggestion = {
  placeId: string;
  primaryText: string;
  secondaryText: string;
};

export type PlaceDetails = {
  placeId: string;
  address: string;
  lat: number;
  lng: number;
};

export type ReverseGeocode = {
  address: string;
};

export type PlaceBias = {
  lat: number;
  lng: number;
};

export interface PlacesProvider {
  autocomplete(input: {
    q: string;
    session: string;
    bias?: PlaceBias;
  }): Promise<PlaceSuggestion[]>;

  details(input: { placeId: string; session: string }): Promise<PlaceDetails>;

  reverse(input: { lat: number; lng: number }): Promise<ReverseGeocode>;
}

export const PLACES_PROVIDER = Symbol('PLACES_PROVIDER');
