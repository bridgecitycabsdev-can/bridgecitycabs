import { describe, expect, it, vi } from 'vitest';
import { DevicesService } from './devices.service.js';

describe('DevicesService', () => {
  it('registers a token for the signed-in user and removes only theirs', async () => {
    const prisma = {
      deviceToken: {
        upsert: vi.fn(async ({ create }: { create: { token: string; platform: string } }) => ({
          id: 'device-1',
          platform: create.platform,
          appVersion: '1.2.0',
        })),
        deleteMany: vi.fn(async () => ({ count: 1 })),
      },
    };
    const devices = new DevicesService(prisma as never);

    await expect(
      devices.register('user-1', {
        token: 'fcm-token',
        platform: 'ios',
        appVersion: '1.2.0',
      }),
    ).resolves.toEqual({ id: 'device-1', platform: 'ios', appVersion: '1.2.0' });
    expect(prisma.deviceToken.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { token: 'fcm-token' },
        create: expect.objectContaining({ userId: 'user-1', platform: 'ios' }),
        update: expect.objectContaining({ userId: 'user-1', platform: 'ios', revokedAt: null }),
      }),
    );

    await devices.remove('user-1', 'fcm-token');
    expect(prisma.deviceToken.deleteMany).toHaveBeenCalledWith({
      where: { userId: 'user-1', token: 'fcm-token' },
    });
  });
});
