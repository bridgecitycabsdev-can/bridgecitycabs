import { createApi } from '@bridgecabs/api-client'
import { z } from 'zod'
import { getAccessToken, useSession } from '@/app/session'
import { env } from '@/lib/env'

const accessTokenSchema = z.object({
  accessToken: z.string().min(1),
})

let refreshFlight: Promise<string | null> | null = null

/** POST /auth/refresh. Overlapping callers share one request so a rotated cookie is not reused. */
export function refreshAccessToken() {
  if (!refreshFlight) {
    refreshFlight = requestRefresh().finally(() => {
      refreshFlight = null
    })
  }
  return refreshFlight
}

async function requestRefresh() {
  try {
    const response = await fetch(`${env.apiOrigin}/api/v1/auth/refresh`, {
      method: 'POST',
      credentials: 'include',
      headers: {
        'Content-Type': 'application/json',
        'X-Client': 'web',
      },
      body: '{}',
    })
    if (!response.ok) return null
    const tokens = accessTokenSchema.parse(await response.json())
    useSession.getState().setAccessToken(tokens.accessToken)
    return tokens.accessToken
  } catch {
    return null
  }
}

export const api = createApi({
  baseUrl: env.apiOrigin,
  getToken: getAccessToken,
  refresh: refreshAccessToken,
  onUnauthorized: () => useSession.getState().clear(),
})

export async function jsonBody(result: { data?: unknown; response: Response }) {
  if (result.data !== undefined) return result.data
  return result.response.json()
}
