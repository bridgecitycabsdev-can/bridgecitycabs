import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { ApiCode } from './api-code.js';

export type ApiErrorBody = {
  code: string;
  message: string;
  fields?: Record<string, string>;
  quote?: unknown;
};

const STATUS_CODES: Record<number, string> = {
  [HttpStatus.BAD_REQUEST]: ApiCode.BAD_REQUEST,
  [HttpStatus.UNAUTHORIZED]: ApiCode.UNAUTHORIZED,
  [HttpStatus.FORBIDDEN]: ApiCode.FORBIDDEN,
  [HttpStatus.NOT_FOUND]: ApiCode.NOT_FOUND,
  [HttpStatus.CONFLICT]: ApiCode.CONFLICT,
  [HttpStatus.UNPROCESSABLE_ENTITY]: ApiCode.UNPROCESSABLE,
  [HttpStatus.TOO_MANY_REQUESTS]: ApiCode.TOO_MANY_REQUESTS,
};

@Catch()
export class ApiExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(ApiExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    if (host.getType() !== 'http') return;

    const { status, body } = toApiError(exception);
    if (status >= HttpStatus.INTERNAL_SERVER_ERROR) {
      this.logger.error(
        exception instanceof Error ? exception.stack : String(exception),
      );
    }

    const response = host.switchToHttp().getResponse<{
      headersSent?: boolean;
      status: (code: number) => { json: (payload: ApiErrorBody) => void };
    }>();
    if (response.headersSent) return;
    response.status(status).json(body);
  }
}

export function toApiError(exception: unknown): {
  status: number;
  body: ApiErrorBody;
} {
  if (!(exception instanceof HttpException)) {
    return {
      status: HttpStatus.INTERNAL_SERVER_ERROR,
      body: {
        code: ApiCode.INTERNAL,
        message: 'Internal server error',
      },
    };
  }

  const status = exception.getStatus();
  const raw = exception.getResponse();
  const shaped = apiBody(raw);
  if (shaped) return { status, body: shaped };

  if (typeof raw === 'string') {
    return { status, body: { code: codeFor(status, raw), message: raw } };
  }

  if (isRecord(raw)) {
    const message = raw.message;
    if (
      Array.isArray(message) &&
      message.every((item) => typeof item === 'string')
    ) {
      return {
        status,
        body: {
          code: ApiCode.VALIDATION,
          message:
            message.length > 0 ? message.join('; ') : 'Validation failed',
        },
      };
    }
    if (typeof message === 'string') {
      return { status, body: { code: codeFor(status, message), message } };
    }
  }

  const fallback =
    typeof exception.message === 'string' && exception.message.length > 0
      ? exception.message
      : 'Request failed';
  return {
    status,
    body: { code: codeFor(status, fallback), message: fallback },
  };
}

function apiBody(raw: unknown): ApiErrorBody | undefined {
  if (!isRecord(raw)) return undefined;
  if (typeof raw.code !== 'string' || typeof raw.message !== 'string')
    return undefined;
  const body: ApiErrorBody = { code: raw.code, message: raw.message };
  const fields = stringFields(raw.fields);
  if (fields) body.fields = fields;
  if ('quote' in raw) body.quote = raw.quote;
  return body;
}

function stringFields(value: unknown): Record<string, string> | undefined {
  if (!isRecord(value)) return undefined;
  const fields: Record<string, string> = {};
  for (const [key, item] of Object.entries(value)) {
    if (typeof item !== 'string') return undefined;
    fields[key] = item;
  }
  return Object.keys(fields).length > 0 ? fields : undefined;
}

function codeFor(status: number, message: string): string {
  const trimmed = message.trim();
  if (/^[A-Z][A-Z0-9_]*$/.test(trimmed)) return trimmed;
  if (trimmed.startsWith('Illegal transition'))
    return ApiCode.ILLEGAL_TRANSITION;
  return (
    STATUS_CODES[status] ??
    (status >= 500 ? ApiCode.INTERNAL : ApiCode.BAD_REQUEST)
  );
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null && !Array.isArray(value);
}
