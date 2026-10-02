import { http, HttpResponse } from 'msw'
import { beforeEach, describe, expect, it } from 'vitest'
import { getAccessToken, useSession } from '@/app/session'
import { login } from '@/features/auth/session'
import { api } from '@/lib/api'
import { server } from '@/test/server'

describe('single-flight refresh', () => {
  beforeEach(() => {
    useSession.getState().clear()
  })

  it('runs one refresh when several requests get a 401', async () => {
    let refreshes = 0
    server.use(
      http.post('http://localhost:3000/api/v1/auth/refresh', async () => {
        refreshes += 1
        await new Promise((resolve) => setTimeout(resolve, 30))
        return HttpResponse.json({ accessToken: 'new-token' })
      }),
      http.get('http://localhost:3000/api/v1/fleet/drivers', ({ request }) => {
        if (request.headers.get('authorization') === 'Bearer new-token') {
          return HttpResponse.json({ branchId: 'branch-1', drivers: [] })
        }
        return new HttpResponse(null, { status: 401 })
      }),
      http.get('http://localhost:3000/api/v1/auth/me', ({ request }) => {
        if (request.headers.get('authorization') === 'Bearer new-token') {
          return HttpResponse.json({ id: 'user-1' })
        }
        return new HttpResponse(null, { status: 401 })
      }),
    )

    useSession.getState().setAccessToken('stale')
    const [drivers, me] = await Promise.all([
      api.GET('/api/v1/fleet/drivers'),
      api.GET('/api/v1/auth/me'),
    ])

    expect(refreshes).toBe(1)
    expect(drivers.response.status).toBe(200)
    expect(me.response.status).toBe(200)
    expect(getAccessToken()).toBe('new-token')
  })

  it('does not refresh when login fails', async () => {
    let refreshes = 0
    server.use(
      http.post('http://localhost:3000/api/v1/auth/login', () => new HttpResponse(null, { status: 401 })),
      http.post('http://localhost:3000/api/v1/auth/refresh', () => {
        refreshes += 1
        return HttpResponse.json({ accessToken: 'new-token' })
      }),
    )

    await expect(login('ada@bridgecabs.test', 'wrong')).resolves.toBe(false)
    expect(refreshes).toBe(0)
    expect(getAccessToken()).toBeNull()
  })
})