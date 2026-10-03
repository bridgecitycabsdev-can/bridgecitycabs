import { describe, expect, it, vi } from 'vitest';
import { toFcmMulticast } from './fcm-push.provider.js';
import { offerNotification, OFFER_PUSH_BODY, OFFER_PUSH_TITLE, PushService } from './push.service.js';

const offerId = '55555555-5555-4555-8555-555555555555';
const at = '2026-10-01T10:00:00.000Z';

describe('offer notification', () => {
  it('is a high-priority visible alert with TTL, collapse, and OFFER data', () => {
    const message = offerNotification({ type: 'OFFER', offerId, expiresAt: at });
    expect(message.title).toBe(OFFER_PUSH_TITLE);
    expect(message.title).toBe('New ride request');
    expect(message.body).toBe(OFFER_PUSH_BODY);
    expect(message.body).toBe('Open the app to respond');
    expect(message.data).toEqual({ type: 'OFFER', offerId, expiresAt: at });
    expect(message.highPriority).toBe(true);
    expect(message.timeSensitive).toBe(true);
    expect(message.androidChannelId).toBe('offers');
    expect(message.collapseKey).toBe(offerId);
    expect(message.expiresAtMs).toBe(Date.parse(at));
    expect(JSON.stringify(message)).not.toMatch(/address|passenger|Leila|City Hall/i);

    const fcm = toFcmMulticast(['token-a'], message);
    expect(fcm.notification).toEqual({
      title: 'New ride request',
      body: 'Open the app to respond',
    });
    expect(fcm.android?.priority).toBe('high');
    expect(fcm.android?.collapseKey).toBe(offerId);
    expect(fcm.android?.ttl).toBeTypeOf('number');
    expect(fcm.android?.notification?.channelId).toBe('offers');
    expect(fcm.android?.notification?.sound).toBe('default');
    expect(fcm.apns?.payload?.aps.alert).toEqual({
      title: 'New ride request',
      body: 'Open the app to respond',
    });
    expect(fcm.apns?.payload?.aps['interruption-level']).toBe('time-sensitive');
    expect(fcm.apns?.headers?.['apns-push-type']).toBe('alert');
    expect(fcm.apns?.headers?.['apns-collapse-id']).toBe(offerId);
    expect(fcm.apns?.headers?.['apns-expiration']).toBe(String(Math.floor(Date.parse(at) / 1000)));
  });
});

describe('PushService', () => {
  it('revokes tokens FCM reports as unregistered or invalid', async () => {
    const prisma = {
      deviceToken: {
        findMany: vi.fn(async () => [
          { token: 'good', platform: 'ios' },
          { token: 'dead', platform: 'android' },
        ]),
        updateMany: vi.fn(async () => ({ count: 1 })),
      },
    };
    const provider = { send: vi.fn(async () => ['dead']) };
    const push = new PushService(prisma as never, provider);

    await push.sendToUser('user-1', {
      title: 'Driver arrived',
      body: 'Your driver is here',
      data: { type: 'driver_arrived', bookingId: 'booking-1' },
      highPriority: true,
      timeSensitive: false,
    });

    expect(provider.send).toHaveBeenCalledWith(
      [
        { token: 'good', platform: 'ios' },
        { token: 'dead', platform: 'android' },
      ],
      expect.objectContaining({ title: 'Driver arrived' }),
    );
    expect(prisma.deviceToken.updateMany).toHaveBeenCalledWith({
      where: { token: { in: ['dead'] }, revokedAt: null },
      data: { revokedAt: expect.any(Date) },
    });
  });
});
