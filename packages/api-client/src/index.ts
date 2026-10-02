import createClient, { type Client } from 'openapi-fetch';
import { io, type Socket } from 'socket.io-client';
import type { paths } from './schema.js';

export type ApiClient = Client<paths>;

export function createApi(options: {
  baseUrl: string;
  getToken: () => string | null;
  /** One call is shared by every 401 in a burst. Return the new access token, or null to stop. */
  refresh: () => Promise<string | null>;
  onUnauthorized: () => void;
}): ApiClient {
  const replayBodies = new WeakMap<Request, Request>();
  let refreshing: Promise<string | null> | null = null;

  function refreshOnce() {
    if (!refreshing) {
      refreshing = options.refresh().finally(() => {
        refreshing = null;
      });
    }
    return refreshing;
  }

  const client = createClient<paths>({
    baseUrl: options.baseUrl,
    credentials: 'include',
    headers: { 'X-Client': 'web' },
  });

  client.use({
    onRequest({ request }) {
      request.headers.set('X-Client', 'web');
      const token = options.getToken();
      if (token) request.headers.set('Authorization', `Bearer ${token}`);
      replayBodies.set(request, request.clone());
      return request;
    },
    async onResponse({ request, response }) {
      if (response.status !== 401 || skipsRefresh(request)) return response;
      const token = await refreshOnce().catch(() => null);
      if (!token) {
        options.onUnauthorized();
        return response;
      }
      const cloned = replayBodies.get(request);
      if (!cloned) {
        options.onUnauthorized();
        return response;
      }
      const headers = new Headers(cloned.headers);
      headers.set('Authorization', `Bearer ${token}`);
      headers.set('x-retry', '1');
      const replayed = await fetch(new Request(cloned, { headers }));
      if (replayed.status === 401) options.onUnauthorized();
      return replayed;
    },
  });

  return client;
}

function skipsRefresh(request: Request) {
  if (request.headers.get('x-retry') === '1') return true;
  const path = new URL(request.url).pathname;
  return (
    path.endsWith('/auth/login') ||
    path.endsWith('/auth/refresh') ||
    path.endsWith('/auth/logout')
  );
}

/** Socket.IO calls auth again on every reconnect, so the callback reads the token in memory. */
export function createSocket(namespace: string, getToken: () => string | null): Socket {
  return io(namespace, {
    transports: ['websocket'],
    auth: (cb) => cb({ token: getToken() }),
  });
}

export {
  FLEET_CHIP_BY_STATUS,
  FLEET_CHIPS,
  SOCKET_EVENTS,
  fleetChipForStatus,
  socketPayloads,
  type AuthExpiring,
  type AuthToken,
  type BookingCreated,
  type BookingStatusChanged,
  type DriverHeartbeat,
  type DriverLocation,
  type DriverPresenceState,
  type DriverStateSnapshot,
  type FleetChip,
  type FleetDriver,
  type FleetSnapshot,
  type FleetSubscribe,
  type OfferCreated,
  type OfferEnded,
  type OfferNew,
  type OfferReceived,
  type OfferResolved,
  type PassengerBooking,
  type PassengerDriverLocation,
  type PassengerTrip,
  type SessionReplaced,
  type SocketEventName,
} from '@bridgecabs/shared-types';
