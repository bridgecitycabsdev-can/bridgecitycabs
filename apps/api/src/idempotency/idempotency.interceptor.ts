import {
  BadRequestException,
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { catchError, concatMap, from, map, of, switchMap, throwError } from 'rxjs';
import type { AuthUser } from '../common/auth-user.js';
import { IDEMPOTENT_KEY } from './idempotency.decorator.js';
import { hashRequestBody, IdempotencyService } from './idempotency.service.js';

const HTTP_CODE_METADATA = '__httpCode__';
const IDEMPOTENCY_HEADER = 'idempotency-key';

@Injectable()
export class IdempotencyInterceptor implements NestInterceptor {
  constructor(
    private readonly reflector: Reflector,
    private readonly idempotency: IdempotencyService,
  ) {}

  intercept(context: ExecutionContext, next: CallHandler) {
    const enabled = this.reflector.getAllAndOverride<boolean>(IDEMPOTENT_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!enabled) return next.handle();

    const http = context.switchToHttp();
    const request = http.getRequest<{
      method: string;
      body: unknown;
      headers: Record<string, string | string[] | undefined>;
      user?: AuthUser;
    }>();
    const response = http.getResponse<{ status: (code: number) => void }>();
    const key = readKey(request.headers[IDEMPOTENCY_HEADER]);
    const userId = request.user?.userId;
    if (!userId) throw new UnauthorizedException();

    const requestHash = hashRequestBody(request.body);
    const responseCode = this.responseCode(context, request.method);

    return from(this.idempotency.claim(userId, key, requestHash)).pipe(
      switchMap((claim) => {
        if (claim.kind === 'replay') {
          response.status(claim.responseCode);
          return of(claim.responseBody);
        }
        return next.handle().pipe(
          catchError((error: unknown) =>
            from(this.idempotency.release(claim.id)).pipe(
              switchMap(() => throwError(() => error)),
            ),
          ),
          concatMap((data: unknown) =>
            from(this.idempotency.complete(claim.id, responseCode, data)).pipe(
              map(() => data),
            ),
          ),
        );
      }),
    );
  }

  private responseCode(context: ExecutionContext, method: string) {
    const explicit = this.reflector.getAllAndOverride<number>(HTTP_CODE_METADATA, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (explicit) return explicit;
    return method === 'POST' ? 201 : 200;
  }
}

function readKey(header: string | string[] | undefined) {
  if (typeof header !== 'string' || header.trim() === '') {
    throw new BadRequestException('Idempotency-Key header is required');
  }
  const key = header.trim();
  if (key.length > 255) {
    throw new BadRequestException('Idempotency-Key is too long');
  }
  return key;
}
