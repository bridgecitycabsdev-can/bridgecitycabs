import { z } from 'zod'

const rawApi =
  (import.meta.env.VITE_API_URL as string | undefined) ||
  (import.meta.env.VITE_API_BASE_URL as string | undefined) ||
  (typeof window !== 'undefined' && window.location.hostname === 'localhost'
    ? 'http://localhost:3000/api/v1'
    : 'https://bridgecabs-api-staging.onrender.com/api/v1')

const rawWs =
  (import.meta.env.VITE_WS_URL as string | undefined) ||
  (import.meta.env.VITE_SOCKET_URL as string | undefined) ||
  (typeof window !== 'undefined' && window.location.hostname === 'localhost'
    ? 'http://localhost:3000'
    : 'https://bridgecabs-api-staging.onrender.com')

const envSchema = z.object({
  VITE_API_URL: z.string().default(rawApi),
  VITE_WS_URL: z.string().default(rawWs),
  VITE_GOOGLE_MAPS_KEY: z.string().default(''),
  VITE_GOOGLE_MAPS_MAP_ID: z.string().default(''),
})

const parsed = envSchema.parse({
  VITE_API_URL: rawApi,
  VITE_WS_URL: rawWs,
  VITE_GOOGLE_MAPS_KEY: import.meta.env.VITE_GOOGLE_MAPS_KEY ?? '',
  VITE_GOOGLE_MAPS_MAP_ID: import.meta.env.VITE_GOOGLE_MAPS_MAP_ID ?? '',
})

/** OpenAPI paths already include `/api/v1`, so the client origin is the API host. */
export function apiOriginFrom(apiUrl: string) {
  try {
    return new URL(apiUrl).origin
  } catch {
    return apiUrl.replace(/\/api\/v1\/?$/, '').replace(/\/+$/, '')
  }
}

export const env = {
  apiUrl: parsed.VITE_API_URL.replace(/\/+$/, ''),
  apiOrigin: apiOriginFrom(parsed.VITE_API_URL),
  wsUrl: parsed.VITE_WS_URL.replace(/\/+$/, ''),
  googleMapsKey: parsed.VITE_GOOGLE_MAPS_KEY,
  googleMapsMapId: parsed.VITE_GOOGLE_MAPS_MAP_ID,
}
