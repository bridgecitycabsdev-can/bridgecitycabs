import { UnauthorizedException } from '@nestjs/common';
import type { Request, Response } from 'express';

export const REFRESH_COOKIE = 'rt';
export const REFRESH_COOKIE_PATH = '/api/v1/auth';
export const REFRESH_COOKIE_MAX_AGE_MS = 7 * 86_400_000;

const INVALID_CREDENTIALS = 'Invalid credentials';

export type IssuedTokens = {
  accessToken: string;
  refreshToken: string;
};

/**
 * SameSite=Strict is only sent on the API host's site.
 * In production the web app and API must share one registrable domain
 * (for example app.example.com and api.example.com).
 */
export function refreshCookieOptions(nodeEnv = process.env.NODE_ENV) {
  return {
    httpOnly: true as const,
    sameSite: 'strict' as const,
    path: REFRESH_COOKIE_PATH,
    secure: nodeEnv === 'production',
    maxAge: REFRESH_COOKIE_MAX_AGE_MS,
  };
}

export function isWebClient(req: Pick<Request, 'headers'>) {
  return req.headers['x-client'] === 'web';
}

export function presentSession(req: Request, res: Response, tokens: IssuedTokens) {
  if (!isWebClient(req)) return tokens;
  res.cookie(REFRESH_COOKIE, tokens.refreshToken, refreshCookieOptions());
  return { accessToken: tokens.accessToken };
}

export function refreshTokenFrom(req: Request, body?: { refreshToken?: string }) {
  if (isWebClient(req)) {
    const token = readRefreshCookie(req);
    if (!token) throw new UnauthorizedException(INVALID_CREDENTIALS);
    return token;
  }
  if (!body?.refreshToken) throw new UnauthorizedException(INVALID_CREDENTIALS);
  return body.refreshToken;
}

export function clearRefreshCookie(res: Response, nodeEnv = process.env.NODE_ENV) {
  const options = refreshCookieOptions(nodeEnv);
  res.clearCookie(REFRESH_COOKIE, {
    httpOnly: options.httpOnly,
    sameSite: options.sameSite,
    path: options.path,
    secure: options.secure,
  });
}

function readRefreshCookie(req: Request) {
  const cookies = (req as Request & { cookies?: Record<string, unknown> }).cookies;
  const value = cookies?.[REFRESH_COOKIE];
  return typeof value === 'string' && value.length > 0 ? value : undefined;
}
