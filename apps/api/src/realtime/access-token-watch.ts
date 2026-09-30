import { SOCKET_EVENTS, authTokenSchema } from '@bridgecabs/shared-types';
import type { Socket } from 'socket.io';
import type { SocketUser } from './socket-auth.js';

export const AUTH_EXPIRING_LEAD_MS = 60_000;

export function authExpiringDelayMs(expSeconds: number, nowMs: number) {
  return Math.max(0, expSeconds * 1000 - AUTH_EXPIRING_LEAD_MS - nowMs);
}

/**
 * Warns one minute before the access token expires. The client refreshes over
 * REST and sends auth:token. If that token is still missing when exp arrives,
 * the socket is closed.
 */
export function watchAccessToken(
  socket: Socket,
  authenticate: (token: string) => Promise<SocketUser>,
) {
  let warnTimer: ReturnType<typeof setTimeout> | undefined;
  let killTimer: ReturnType<typeof setTimeout> | undefined;

  const clear = () => {
    if (warnTimer) clearTimeout(warnTimer);
    if (killTimer) clearTimeout(killTimer);
    warnTimer = undefined;
    killTimer = undefined;
  };

  const arm = (expSeconds: number) => {
    clear();
    const warn = () => {
      socket.emit(SOCKET_EVENTS.authExpiring, { exp: expSeconds });
      const remaining = Math.max(0, expSeconds * 1000 - Date.now());
      killTimer = setTimeout(() => socket.disconnect(true), remaining);
    };
    const delay = authExpiringDelayMs(expSeconds, Date.now());
    if (delay === 0) warn();
    else warnTimer = setTimeout(warn, delay);
  };

  const exp = socket.data.user?.exp;
  if (exp != null) arm(exp);

  socket.on(SOCKET_EVENTS.authToken, (payload: unknown) => {
    const parsed = authTokenSchema.safeParse(payload);
    if (!parsed.success || !socket.data.user) return;
    void authenticate(parsed.data.token)
      .then((user) => {
        if (!socket.data.user || user.userId !== socket.data.user.userId) return;
        socket.data.user = user;
        arm(user.exp);
      })
      .catch(() => undefined);
  });

  socket.on('disconnect', clear);
  return clear;
}
