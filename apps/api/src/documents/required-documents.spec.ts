import { describe, expect, it } from 'vitest';
import { codesMissingFrom } from './required-documents.js';

describe('required documents', () => {
  it('returns the codes that are not in the approved set, in order', () => {
    const missing = codesMissingFrom(
      [
        { id: 'licence', code: 'AB_DRIVERS_LICENCE' },
        { id: 'police', code: 'POLICE_CHECK_VSC' },
        { id: 'work', code: 'WORK_ELIGIBILITY' },
      ],
      new Set(['police']),
    );
    expect(missing).toEqual(['AB_DRIVERS_LICENCE', 'WORK_ELIGIBILITY']);
  });
});
