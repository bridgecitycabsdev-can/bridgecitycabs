import { describe, expect, it } from 'vitest';
import { normalizePhone } from './phone.js';

describe('normalizePhone', () => {
  it('stores 403-555-0100 and +14035550100 as the same E.164 value', () => {
    expect(normalizePhone('403-555-0100')).toBe('+14035550100');
    expect(normalizePhone('+14035550100')).toBe('+14035550100');
    expect(normalizePhone('403-555-0100')).toBe(normalizePhone('+14035550100'));
  });
});
