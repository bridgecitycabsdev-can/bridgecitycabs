import { Prisma } from '@prisma/client';
import { describe, expect, it } from 'vitest';
import { safeJson } from './safe-json.js';

describe('safeJson', () => {
  it('returns JsonNull for nullish', () => {
    expect(safeJson(null)).toBe(Prisma.JsonNull);
    expect(safeJson(undefined)).toBe(Prisma.JsonNull);
  });

  it('round-trips plain objects', () => {
    expect(safeJson({ id: 'a', n: 1 })).toEqual({ id: 'a', n: 1 });
  });

  it('summarizes buffers and stream-like constructors', () => {
    expect(safeJson(Buffer.from('hi'))).toEqual({
      type: 'buffer',
      byteLength: 2,
    });
    class StreamableFile {}
    expect(safeJson(new StreamableFile())).toEqual({ type: 'StreamableFile' });
  });
});
