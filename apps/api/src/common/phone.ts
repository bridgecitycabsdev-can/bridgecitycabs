import { BadRequestException } from '@nestjs/common';
import { parsePhoneNumberFromString } from 'libphonenumber-js';

export function normalizePhone(value: string) {
  const parsed = parsePhoneNumberFromString(value, 'CA');
  if (!parsed?.isValid()) {
    throw new BadRequestException('Invalid phone number');
  }
  return parsed.number;
}
