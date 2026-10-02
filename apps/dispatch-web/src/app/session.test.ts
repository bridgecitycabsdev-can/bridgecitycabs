import { beforeEach, describe, expect, it } from 'vitest'
import { getAccessToken, useSession } from '@/app/session'

describe('session', () => {
  beforeEach(() => {
    useSession.getState().clear()
    localStorage.clear()
  })

  it('keeps the access token in a module variable', () => {
    useSession.getState().setAccessToken('access-token')
    expect(getAccessToken()).toBe('access-token')
    expect(useSession.getState().accessToken).toBe('access-token')
    expect(localStorage.length).toBe(0)
    useSession.getState().clear()
    expect(getAccessToken()).toBeNull()
    expect(useSession.getState().accessToken).toBeNull()
  })
})
