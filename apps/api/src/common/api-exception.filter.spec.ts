import {
  ArgumentsHost,
  BadRequestException,
  ConflictException,
  HttpStatus,
  UnauthorizedException,
} from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { ApiCode } from './api-code.js';
import { ApiException } from './api-exception.js';
import { ApiExceptionFilter, toApiError } from './api-exception.filter.js';

describe('toApiError', () => {
  it('keeps the message and adds a status code', () => {
    expect(
      toApiError(new UnauthorizedException('Invalid credentials')),
    ).toEqual({
      status: 401,
      body: { code: ApiCode.UNAUTHORIZED, message: 'Invalid credentials' },
    });
  });

  it('promotes an existing stable code carried as the message', () => {
    for (const code of [
      ApiCode.DRIVER_NOT_AVAILABLE,
      ApiCode.QUOTE_EXPIRED,
      ApiCode.VERSION_CONFLICT,
    ]) {
      expect(toApiError(new ConflictException(code)).body).toEqual({
        code,
        message: code,
      });
    }
  });

  it('maps illegal transitions without rewriting the message', () => {
    const message = 'Illegal transition REQUESTED → COMPLETED';
    expect(toApiError(new ConflictException(message)).body).toEqual({
      code: ApiCode.ILLEGAL_TRANSITION,
      message,
    });
  });

  it('turns a validation message list into VALIDATION', () => {
    const exception = new BadRequestException([
      'email must be an email',
      'phone is required',
    ]);
    expect(toApiError(exception).body).toEqual({
      code: ApiCode.VALIDATION,
      message: 'email must be an email; phone is required',
    });
  });

  it('passes through an ApiException, including fields', () => {
    const exception = new ApiException(
      HttpStatus.BAD_REQUEST,
      ApiCode.VALIDATION,
      'Validation failed',
      {
        placeId: 'placeId is invalid',
      },
    );
    expect(toApiError(exception)).toEqual({
      status: 400,
      body: {
        code: ApiCode.VALIDATION,
        message: 'Validation failed',
        fields: { placeId: 'placeId is invalid' },
      },
    });
  });

  it('keeps a replacement quote beside QUOTE_EXPIRED', () => {
    const quote = { distanceM: 8100, options: [] };
    const exception = new ApiException(
      HttpStatus.CONFLICT,
      ApiCode.QUOTE_EXPIRED,
      'Quote expired',
      undefined,
      quote,
    );
    expect(toApiError(exception)).toEqual({
      status: 409,
      body: { code: ApiCode.QUOTE_EXPIRED, message: 'Quote expired', quote },
    });
  });

  it('hides unexpected failures', () => {
    expect(toApiError(new Error('relation "User" does not exist'))).toEqual({
      status: 500,
      body: { code: ApiCode.INTERNAL, message: 'Internal server error' },
    });
  });
});

describe('ApiExceptionFilter', () => {
  function httpHost() {
    const json = vi.fn();
    const status = vi.fn(() => ({ json }));
    const host = {
      getType: () => 'http',
      switchToHttp: () => ({
        getResponse: () => ({ status, headersSent: false }),
      }),
    } as unknown as ArgumentsHost;
    return { host, status, json };
  }

  it('writes only code, message, and fields', () => {
    const { host, status, json } = httpHost();
    new ApiExceptionFilter().catch(
      new UnauthorizedException('Invalid credentials'),
      host,
    );
    expect(status).toHaveBeenCalledWith(401);
    expect(json).toHaveBeenCalledWith({
      code: 'UNAUTHORIZED',
      message: 'Invalid credentials',
    });
  });

  it('leaves non-http contexts alone', () => {
    const status = vi.fn();
    const host = {
      getType: () => 'ws',
      switchToHttp: () => ({ getResponse: () => ({ status }) }),
    } as unknown as ArgumentsHost;
    new ApiExceptionFilter().catch(new Error('UNAUTHENTICATED'), host);
    expect(status).not.toHaveBeenCalled();
  });
});
