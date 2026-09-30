import { describe, expect, it } from 'vitest';
import { accessTokenFromHandshake, socketLogLine } from './handshake-token.js';

describe('socket token handling', () => {
  it('reads the token from handshake auth and refuses one in the url', () => {
    expect(accessTokenFromHandshake({ auth: { token: 'header-token' } })).toBe('header-token');
    expect(
      accessTokenFromHandshake({
        auth: { token: 'header-token' },
        query: { token: 'url-token' },
      }),
    ).toBeNull();
    expect(accessTokenFromHandshake({ query: { token: 'url-token' } })).toBeNull();
  });

  it('logs the socket id and user id only', () => {
    const line = socketLogLine('connected', 'abc', 'user-1');
    expect(line).toBe('connected socket=abc user=user-1');
    expect(line).not.toContain('token');
  });
});
