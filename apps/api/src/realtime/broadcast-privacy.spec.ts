import { bookingCreatedSchema } from '@bridgecabs/shared-types';
import { describe, expect, it } from 'vitest';
import { assertBroadcastSafe, broadcastHasPassengerContact } from './broadcast-privacy.js';

describe('broadcast privacy', () => {
  it('rejects a passenger phone anywhere in a room payload', () => {
    expect(broadcastHasPassengerContact({ passengerName: 'Leila Hassan' })).toBe(false);
    expect(broadcastHasPassengerContact({ booking: { passengerPhone: '+14035550100' } })).toBe(true);
    expect(broadcastHasPassengerContact({ passengerEmail: 'a@example.com' })).toBe(true);
    expect(() => assertBroadcastSafe({ phone: '+14035550100' })).toThrow(
      'Broadcast includes passenger contact',
    );
  });

  it('keeps phone and email off the shared socket schemas', () => {
    const created = bookingCreatedSchema.safeParse({
      id: '22222222-2222-4222-8222-222222222222',
      branchId: '33333333-3333-4333-8333-333333333333',
      trackingId: 'BC-1',
      status: 'SEARCHING_DRIVER',
      passengerName: 'Leila Hassan',
      passengerPhone: '+14035550100',
      scheduledAt: null,
      quotedFareCents: 100,
      vehicleType: { id: '44444444-4444-4444-8444-444444444444', name: 'SUV' },
      pickupAddress: 'City Hall',
    });
    expect(created.success).toBe(false);
  });
});
