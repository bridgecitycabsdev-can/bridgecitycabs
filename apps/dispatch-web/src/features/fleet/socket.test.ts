import { QueryClient } from '@tanstack/react-query'
import { beforeAll, beforeEach, describe, expect, it, vi } from 'vitest'
import { refreshAccessToken } from '@/lib/api'
import { ensureFleetSocket } from '@/features/fleet/socket'
import { useFleet } from '@/features/fleet/store'

const { fakeSocket, listeners } = vi.hoisted(() => {
  const listeners = new Map<string, (payload?: unknown) => void>()
  const fakeSocket = {
    connected: false,
    connect: vi.fn(),
    disconnect: vi.fn(),
    emit: vi.fn(),
    on: vi.fn((event: string, handler: (payload?: unknown) => void) => {
      listeners.set(event, handler)
      return fakeSocket
    }),
  }
  return { fakeSocket, listeners }
})

vi.mock('@bridgecabs/api-client', async () => {
  const actual = await vi.importActual<typeof import('@bridgecabs/api-client')>('@bridgecabs/api-client')
  return {
    ...actual,
    createSocket: vi.fn(() => fakeSocket),
  }
})

vi.mock('@/lib/api', () => ({
  refreshAccessToken: vi.fn(),
}))

const queryClient = new QueryClient()

describe('fleet socket', () => {
  const invalidate = vi.spyOn(queryClient, 'invalidateQueries')

  beforeAll(() => {
    ensureFleetSocket(queryClient)
  })

  beforeEach(() => {
    invalidate.mockClear()
    fakeSocket.connect.mockClear()
    vi.mocked(refreshAccessToken).mockReset()
    useFleet.setState({ drivers: {}, conn: 'offline', chip: 'ALL' })
  })

  it('reloads the fleet from REST when the socket connects again', () => {
    listeners.get('disconnect')?.()
    expect(useFleet.getState().conn).toBe('reconnecting')

    listeners.get('connect')?.()

    expect(useFleet.getState().conn).toBe('live')
    expect(invalidate).toHaveBeenCalledWith({ queryKey: ['fleet', 'drivers'] })
  })

  it('refreshes and reconnects after an UNAUTHENTICATED error', async () => {
    vi.mocked(refreshAccessToken).mockResolvedValue('fresh-token')

    listeners.get('connect_error')?.(new Error('UNAUTHENTICATED'))

    expect(useFleet.getState().conn).toBe('reconnecting')
    await vi.waitFor(() => expect(fakeSocket.connect).toHaveBeenCalledTimes(1))
    expect(refreshAccessToken).toHaveBeenCalledTimes(1)
  })
})
