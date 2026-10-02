import { z } from 'zod'
import { profileSchema, useSession } from '@/app/session'
import { api, jsonBody, refreshAccessToken } from '@/lib/api'

const accessTokenSchema = z.object({
  accessToken: z.string().min(1),
})

export async function loadProfile() {
  const result = await api.GET('/api/v1/auth/me')
  if (!result.response.ok) {
    useSession.getState().clear()
    return null
  }
  const profile = profileSchema.parse(await jsonBody(result))
  useSession.getState().setProfile(profile)
  return profile
}

export async function login(email: string, password: string) {
  try {
    const result = await api.POST('/api/v1/auth/login', {
      body: { email, password },
    })
    if (!result.response.ok) return false
    const tokens = accessTokenSchema.parse(await jsonBody(result))
    useSession.getState().setAccessToken(tokens.accessToken)
    return (await loadProfile()) !== null
  } catch {
    useSession.getState().clear()
    return false
  }
}

export async function refreshSession() {
  const token = await refreshAccessToken()
  if (!token) return false
  try {
    return (await loadProfile()) !== null
  } catch {
    useSession.getState().clear()
    return false
  }
}

export async function logout() {
  try {
    await api.POST('/api/v1/auth/logout', { body: {} })
  } finally {
    useSession.getState().clear()
  }
}
