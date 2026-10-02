import { UnauthorizedException } from '@nestjs/common';
import type { Request, Response } from 'express';
import { describe, expect, it, vi } from 'vitest';
import { AuthController } from './auth.controller.js';
import {
  REFRESH_COOKIE,
  REFRESH_COOKIE_MAX_AGE_MS,
  REFRESH_COOKIE_PATH,
  clearRefreshCookie,
  presentSession,
  refreshCookieOptions,
  refreshTokenFrom,
} from './web-refresh-cookie.js';

const tokens = { accessToken: 'access-token', refreshToken: 'refresh-token' };

function webRequest(cookies?: Record<string, unknown>): Request {
  return { headers: { 'x-client': 'web' }, cookies } as unknown as Request;
}

function mobileRequest(cookies?: Record<string, unknown>): Request {
  return { headers: {}, cookies } as unknown as Request;
}

function cookieResponse() {
  return {
    cookie: vi.fn(),
    clearCookie: vi.fn(),
  } as unknown as Response & { cookie: ReturnType<typeof vi.fn>; clearCookie: ReturnType<typeof vi.fn> };
}

describe('web refresh cookie', () => {
  it('sets an httpOnly cookie and keeps the refresh token out of the web body', () => {
    const res = cookieResponse();
    expect(presentSession(webRequest(), res, tokens)).toEqual({ accessToken: 'access-token' });
    expect(res.cookie).toHaveBeenCalledWith(
      REFRESH_COOKIE,
      'refresh-token',
      expect.objectContaining({
        httpOnly: true,
        sameSite: 'strict',
        path: REFRESH_COOKIE_PATH,
        secure: false,
        maxAge: REFRESH_COOKIE_MAX_AGE_MS,
      }),
    );
  });

  it('returns both tokens for mobile', () => {
    const res = cookieResponse();
    expect(presentSession(mobileRequest(), res, tokens)).toEqual(tokens);
    expect(res.cookie).not.toHaveBeenCalled();
  });

  it('marks the cookie secure in production', () => {
    expect(refreshCookieOptions('production').secure).toBe(true);
  });

  it('reads the cookie for web and the body for mobile', () => {
    expect(refreshTokenFrom(webRequest({ rt: 'from-cookie' }), { refreshToken: 'from-body' })).toBe(
      'from-cookie',
    );
    expect(refreshTokenFrom(mobileRequest({ rt: 'from-cookie' }), { refreshToken: 'from-body' })).toBe(
      'from-body',
    );
  });

  it('rejects a web refresh with no cookie and a mobile refresh with no body', () => {
    expect(() => refreshTokenFrom(webRequest(), { refreshToken: 'from-body' })).toThrow(
      UnauthorizedException,
    );
    expect(() => refreshTokenFrom(mobileRequest())).toThrow(UnauthorizedException);
  });

  it('clears the cookie with the same path and flags used to set it', () => {
    const res = cookieResponse();
    clearRefreshCookie(res, 'production');
    expect(res.clearCookie).toHaveBeenCalledWith(REFRESH_COOKIE, {
      httpOnly: true,
      sameSite: 'strict',
      path: REFRESH_COOKIE_PATH,
      secure: true,
    });
  });
});

describe('AuthController cookie mode', () => {
  const authService = {
    login: vi.fn(async () => tokens),
    verifyOtp: vi.fn(async () => tokens),
    refresh: vi.fn(async () => tokens),
    logout: vi.fn(async () => ({ success: true })),
  };
  const controller = new AuthController(authService as never);

  it('stores the refresh token in a cookie on web login, verify, and refresh', async () => {
    const loginRes = cookieResponse();
    await expect(
      controller.login(webRequest(), loginRes, { email: 'a@b.c', password: 'secret' }),
    ).resolves.toEqual({ accessToken: 'access-token' });
    expect(loginRes.cookie).toHaveBeenCalledWith(
      REFRESH_COOKIE,
      'refresh-token',
      expect.objectContaining({ httpOnly: true }),
    );

    const verifyRes = cookieResponse();
    await expect(
      controller.verifyOtp(webRequest(), verifyRes, { phone: '+14035550100', code: '000000' }),
    ).resolves.toEqual({ accessToken: 'access-token' });

    const refreshRes = cookieResponse();
    await expect(
      controller.refresh(webRequest({ rt: 'old-refresh' }), refreshRes, {}),
    ).resolves.toEqual({ accessToken: 'access-token' });
    expect(authService.refresh).toHaveBeenCalledWith('old-refresh');
    expect(refreshRes.cookie).toHaveBeenCalledWith(REFRESH_COOKIE, 'refresh-token', expect.any(Object));
  });

  it('returns the refresh token in the body for a mobile login', async () => {
    const res = cookieResponse();
    await expect(
      controller.login(mobileRequest(), res, { email: 'a@b.c', password: 'secret' }),
    ).resolves.toEqual(tokens);
    expect(res.cookie).not.toHaveBeenCalled();
  });

  it('rotates from the body for mobile and leaves the cookie unset', async () => {
    const res = cookieResponse();
    await expect(
      controller.refresh(mobileRequest(), res, { refreshToken: 'mobile-refresh' }),
    ).resolves.toEqual(tokens);
    expect(authService.refresh).toHaveBeenCalledWith('mobile-refresh');
    expect(res.cookie).not.toHaveBeenCalled();
  });

  it('clears the web cookie when refresh is rejected', async () => {
    authService.refresh.mockRejectedValueOnce(new UnauthorizedException('Invalid credentials'));
    const res = cookieResponse();
    await expect(controller.refresh(webRequest({ rt: 'reused' }), res, {})).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(res.clearCookie).toHaveBeenCalled();
  });

  it('revokes the cookie token and clears it on web logout', async () => {
    const res = cookieResponse();
    await expect(
      controller.logout(
        { userId: 'user-1', role: 'dispatcher', branchId: 'branch-1' },
        webRequest({ rt: 'web-refresh' }),
        res,
        {},
      ),
    ).resolves.toEqual({ success: true });
    expect(authService.logout).toHaveBeenCalledWith('user-1', 'web-refresh');
    expect(res.clearCookie).toHaveBeenCalled();
  });
});
