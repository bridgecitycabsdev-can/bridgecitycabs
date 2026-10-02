import { z } from 'zod'

const envSchema = z.object({
  VITE_API_URL: z.url(),
  VITE_WS_URL: z.url(),
  VITE_GOOGLE_MAPS_KEY: z.string(),
  VITE_GOOGLE_MAPS_MAP_ID: z.string(),
})

const parsed = envSchema.parse(import.meta.env)

/** OpenAPI paths already include `/api/v1`, so the client origin is the API host. */
export function apiOriginFrom(apiUrl: string) {
  return new URL(apiUrl).origin
}

export const env = {
  apiUrl: parsed.VITE_API_URL,
  apiOrigin: apiOriginFrom(parsed.VITE_API_URL),
  wsUrl: parsed.VITE_WS_URL,
  googleMapsKey: parsed.VITE_GOOGLE_MAPS_KEY,
  googleMapsMapId: parsed.VITE_GOOGLE_MAPS_MAP_ID,
}
