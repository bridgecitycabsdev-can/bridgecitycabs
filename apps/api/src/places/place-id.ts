/** Google place IDs are opaque. Reject anything that is not a path segment. */
export const PLACE_ID_PATTERN = /^[A-Za-z0-9_-]{10,300}$/;

/**
 * Places API (New) session tokens are URL-safe strings of at most 36 characters.
 * A version 4 UUID is the recommended shape.
 */
export const SESSION_TOKEN_PATTERN = /^[A-Za-z0-9_-]{1,36}$/;

export function isPlaceId(value: string): boolean {
  return PLACE_ID_PATTERN.test(value);
}
