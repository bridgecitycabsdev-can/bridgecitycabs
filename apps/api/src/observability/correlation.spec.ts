import { describe, expect, it } from 'vitest';
import {
  correlationIdOrNew,
  getCorrelationId,
  readJobCorrelationId,
  runWithCorrelationId,
  withCorrelationId,
} from './correlation.js';

describe('correlation', () => {
  it('binds ALS for the request and merges into job payloads', () => {
    expect(getCorrelationId()).toBeUndefined();
    runWithCorrelationId('req-abc', () => {
      expect(getCorrelationId()).toBe('req-abc');
      expect(correlationIdOrNew()).toBe('req-abc');
      expect(withCorrelationId({ bookingId: 'b1' })).toEqual({
        bookingId: 'b1',
        correlationId: 'req-abc',
      });
    });
    expect(getCorrelationId()).toBeUndefined();
  });

  it('reads correlationId from job data or generates one', () => {
    expect(readJobCorrelationId({ correlationId: 'job-1' })).toBe('job-1');
    expect(readJobCorrelationId({})).toMatch(
      /^[0-9a-f-]{36}$/i,
    );
  });
});
