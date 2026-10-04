import { randomUUID } from 'node:crypto';
import type { IncomingMessage, ServerResponse } from 'node:http';
import type { Params } from 'nestjs-pino';
import { runWithCorrelationId } from './correlation.js';

type ReqWithId = IncomingMessage & {
  id?: string;
  headers: IncomingMessage['headers'];
};

/**
 * Pino HTTP config: correlation id per request, redaction for secrets/PII.
 */
export function pinoLoggerParams(): Params {
  const isProd = process.env.NODE_ENV === 'production';
  const isTest = process.env.NODE_ENV === 'test';

  return {
    pinoHttp: {
      level: isTest ? 'silent' : isProd ? 'info' : 'debug',
      genReqId: (req: IncomingMessage) => {
        const header = req.headers['x-request-id'];
        const fromHeader = Array.isArray(header) ? header[0] : header;
        return fromHeader?.trim() || randomUUID();
      },
      customProps: (req: IncomingMessage) => ({
        correlationId: String((req as ReqWithId).id ?? ''),
      }),
      redact: {
        paths: [
          'req.headers.authorization',
          'req.body.password',
          'req.body.code',
          '*.phone',
          '*.email',
          'req.body.phone',
          'req.body.email',
        ],
        remove: true,
      },
      transport:
        !isProd && !isTest
          ? { target: 'pino-pretty', options: { singleLine: true } }
          : undefined,
      quietReqLogger: true,
    },
  };
}

/**
 * Keeps AsyncLocalStorage correlation active for the whole request so
 * BullMQ enqueue sites inherit the HTTP x-request-id / genReqId value.
 */
export function correlationMiddleware(
  req: IncomingMessage & { id?: string },
  _res: ServerResponse,
  next: (err?: unknown) => void,
) {
  const header = req.headers['x-request-id'];
  const fromHeader = Array.isArray(header) ? header[0] : header;
  const id = (typeof req.id === 'string' && req.id) || fromHeader?.trim() || randomUUID();
  req.id = id;
  runWithCorrelationId(id, () => next());
}
