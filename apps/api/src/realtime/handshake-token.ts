const QUERY_TOKEN_KEYS = ['token', 'access_token', 'refresh_token', 'refreshToken'] as const;

/** The access token is read from handshake.auth only. A token in the URL is refused. */
export function accessTokenFromHandshake(handshake: { auth?: unknown; query?: unknown }) {
  if (queryCarriesToken(handshake.query)) return null;
  if (!handshake.auth || typeof handshake.auth !== 'object') return null;
  const token = (handshake.auth as { token?: unknown }).token;
  return typeof token === 'string' && token.length > 0 ? token : null;
}

function queryCarriesToken(query: unknown) {
  if (!query || typeof query !== 'object') return false;
  const bag = query as Record<string, unknown>;
  return QUERY_TOKEN_KEYS.some((key) => {
    const value = bag[key];
    return value != null && value !== '';
  });
}

export function socketLogLine(action: 'connected' | 'disconnected' | 'capped', socketId: string, userId: string) {
  return `${action} socket=${socketId} user=${userId}`;
}
