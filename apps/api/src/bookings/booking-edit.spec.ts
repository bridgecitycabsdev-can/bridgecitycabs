import { ConflictException } from '@nestjs/common';
import { describe, expect, it } from 'vitest';
import { assertEditable, editableFields } from './booking-edit.js';

describe('editable fields', () => {
  it('allows the whole booking before a driver is matched, and only notes after that', () => {
    expect(editableFields('SEARCHING_DRIVER')).toContain('stops');
    expect(editableFields('NO_DRIVER_FOUND')).toContain('fixedFareCents');
    expect(editableFields('MATCHED')).toEqual(['notes']);
    expect(editableFields('DRIVER_ARRIVING')).toEqual(['notes']);
    expect(editableFields('TRIP_STARTED')).toEqual([]);
  });

  it('refuses a change while an offer is open', () => {
    expect(() => assertEditable('MATCHED', ['notes'])).not.toThrow();
    expect(() => assertEditable('MATCHED', ['passengerName'])).toThrow(ConflictException);
    expect(() => assertEditable('TRIP_STARTED', ['notes'])).toThrow(
      'This booking can no longer be edited',
    );
  });
});
