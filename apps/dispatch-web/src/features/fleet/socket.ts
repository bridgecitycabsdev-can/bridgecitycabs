import { SOCKET_EVENTS, createSocket, socketPayloads } from '@bridgecabs/api-client'
import type { QueryClient } from '@tanstack/react-query'
import type { Socket } from 'socket.io-client'
import { getAccessToken, useSession } from '@/app/session'
import { registerFleetStop, useFleet } from '@/features/fleet/store'
import { refreshAccessToken } from '@/lib/api'
import { env } from '@/lib/env'

let socket: Socket | null = null
let queryClient: QueryClient | null = null
let closed = false

/** One socket for the tab. React StrictMode must not open a second connection. */
export function ensureFleetSocket(client: QueryClient) {
  queryClient = client
  closed = false
  const current = fleetSocket()
  if (!current.connected) current.connect()
  return current
}

export function subscribeFleet(branchId: string) {
  if (!socket?.connected) return
  socket.emit(SOCKET_EVENTS.fleetSubscribe, { branchId })
}

registerFleetStop(() => {
  closed = true
  socket?.disconnect()
})

function fleetSocket() {
  if (!socket) {
    socket = createSocket(`${env.wsUrl}/dispatch`, getAccessToken)
    bindFleetSocket(socket)
  }
  return socket
}

function loadFleetSnapshot() {
  void queryClient?.invalidateQueries({ queryKey: ['fleet', 'drivers'] })
}

function invalidateBookings() {
  void queryClient?.invalidateQueries({ queryKey: ['bookings'] })
}

function bindFleetSocket(current: Socket) {
  current.on('connect', () => {
    useFleet.getState().setConn('live')
    const role = useSession.getState().profile?.role.name
    const branchId = useSession.getState().branchId
    if (role === 'super_admin' && branchId) {
      current.emit(SOCKET_EVENTS.fleetSubscribe, { branchId })
    }
    loadFleetSnapshot()
    invalidateBookings()
  })

  current.on('disconnect', () => {
    if (closed) {
      useFleet.getState().setConn('offline')
      return
    }
    useFleet.getState().setConn('reconnecting')
  })

  current.on(SOCKET_EVENTS.fleetSnapshot, (payload: unknown) => {
    const parsed = socketPayloads[SOCKET_EVENTS.fleetSnapshot].safeParse(payload)
    if (!parsed.success || !acceptsBranch(parsed.data.branchId)) return
    useFleet.getState().replace(parsed.data.drivers)
  })

  current.on(SOCKET_EVENTS.fleetDriverUpdated, (payload: unknown) => {
    const parsed = socketPayloads[SOCKET_EVENTS.fleetDriverUpdated].safeParse(payload)
    if (!parsed.success || !acceptsBranch(parsed.data.branchId)) return
    useFleet.getState().merge(parsed.data.drivers)
  })

  current.on(SOCKET_EVENTS.bookingCreated, invalidateBookings)
  current.on(SOCKET_EVENTS.bookingStatusChanged, invalidateBookings)

  current.on(SOCKET_EVENTS.authExpiring, () => {
    void refreshAccessToken().then((token) => {
      if (token) current.emit(SOCKET_EVENTS.authToken, { token })
    })
  })

  current.on('connect_error', (error: Error) => {
    useFleet.getState().setConn('reconnecting')
    if (error.message !== 'UNAUTHENTICATED') return
    void refreshAccessToken().then((token) => {
      if (token) current.connect()
    })
  })
}

function acceptsBranch(branchId: string) {
  if (useSession.getState().profile?.role.name !== 'super_admin') return true
  return useSession.getState().branchId === branchId
}

if (import.meta.hot) {
  import.meta.hot.dispose(() => {
    socket?.disconnect()
    socket = null
  })
}
