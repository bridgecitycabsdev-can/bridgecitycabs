import { Injectable, NestMiddleware } from '@nestjs/common';
import type { NextFunction, Request, Response } from 'express';

const QUERY_TOKEN_KEYS = ['token', 'access_token', 'refresh_token', 'refreshToken'] as const;

@Injectable()
export class RejectTokenQueryMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    if (queryCarriesToken(req.query)) {
      res.status(401).json({ statusCode: 401, message: 'Unauthorized' });
      return;
    }
    next();
  }
}

export function queryCarriesToken(query: unknown) {
  if (!query || typeof query !== 'object') return false;
  const bag = query as Record<string, unknown>;
  return QUERY_TOKEN_KEYS.some((key) => {
    const value = bag[key];
    return value != null && value !== '';
  });
}
