import { HttpException, HttpStatus } from '@nestjs/common';
import type { ApiCode } from './api-code.js';

export class ApiException extends HttpException {
  constructor(
    status: HttpStatus,
    code: ApiCode,
    message: string,
    fields?: Record<string, string>,
    quote?: unknown,
  ) {
    const body: {
      code: ApiCode;
      message: string;
      fields?: Record<string, string>;
      quote?: unknown;
    } = { code, message };
    if (fields) body.fields = fields;
    if (quote !== undefined) body.quote = quote;
    super(body, status);
  }
}
