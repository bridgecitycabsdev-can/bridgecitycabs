import { describe, expect, it } from 'vitest';
import { countFleetChips } from './fleet-chips.js';

describe('fleet chips', () => {
  it('maps each online state onto one legacy chip', () => {
    const counts = countFleetChips([
      'AVAILABLE',
      'OFFERED',
      'ASSIGNED',
      'EN_ROUTE_PICKUP',
      'ARRIVED',
      'ON_TRIP',
      'AWAY',
      'OFFLINE',
    ]);
    expect(counts).toEqual({
      ALL: 7,
      FREE: 1,
      ASSIGN: 3,
      WAIT: 1,
      BUSY: 1,
      AWAY: 1,
    });
  });
});
