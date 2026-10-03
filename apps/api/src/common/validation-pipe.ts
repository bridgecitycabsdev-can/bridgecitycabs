import { BadRequestException, ValidationPipe } from '@nestjs/common';
import type { ValidationError } from 'class-validator';
import { ApiCode } from './api-code.js';

export function validationExceptionFactory(errors: ValidationError[]) {
  const fields: Record<string, string> = {};
  collectFields(errors, '', fields);
  return new BadRequestException({
    code: ApiCode.VALIDATION,
    message: 'Validation failed',
    fields,
  });
}

export function apiValidationPipe() {
  return new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
    exceptionFactory: validationExceptionFactory,
  });
}

function collectFields(
  errors: ValidationError[],
  prefix: string,
  fields: Record<string, string>,
) {
  for (const error of errors) {
    const path = prefix ? `${prefix}.${error.property}` : error.property;
    const constraint = error.constraints
      ? Object.values(error.constraints)[0]
      : undefined;
    if (constraint) fields[path] = constraint;
    if (error.children?.length) collectFields(error.children, path, fields);
  }
}
