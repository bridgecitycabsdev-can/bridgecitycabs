import { BadRequestException } from '@nestjs/common';
import { describe, expect, it } from 'vitest';
import { assertDriverTransition } from './driver-status.js';

describe('assertDriverTransition', () => {
  it('allows review, approval, suspension, and reinstatement', () => {
    expect(() =>
      assertDriverTransition('PENDING_DOCUMENTS', 'PENDING_APPROVAL'),
    ).not.toThrow();
    expect(() =>
      assertDriverTransition('PENDING_DOCUMENTS', 'APPROVED'),
    ).not.toThrow();
    expect(() =>
      assertDriverTransition('PENDING_APPROVAL', 'APPROVED'),
    ).not.toThrow();
    expect(() => assertDriverTransition('APPROVED', 'SUSPENDED')).not.toThrow();
    expect(() => assertDriverTransition('SUSPENDED', 'APPROVED')).not.toThrow();
    expect(() =>
      assertDriverTransition('REJECTED', 'PENDING_APPROVAL'),
    ).not.toThrow();
  });

  it('rejects approval straight from REJECTED', () => {
    expect(() => assertDriverTransition('REJECTED', 'APPROVED')).toThrow(
      BadRequestException,
    );
  });
});
