import { describe, expect, it, vi } from 'vitest';
import { DevicesService } from './devices.service.js';

describe('DevicesService', () => {
  it('upserts a token, reassigns the user, clears revoke, and soft-revokes on delete', async () => {
    const prisma = {
      deviceToken: {
        upsert: vi.fn(async ({ create }: { create: { token: string; platform: string } }) => ({
          id: 'device-1',
          platform: create.platform,
          appVersion: '1.2.0',
        })),
        updateMany: vi.fn(async () => ({ count: 1 })),
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
        update: expect.objectContaining({
          userId: 'user-1',
          platform: 'ios',
          revokedAt: null,
        }),
      }),
    );

    // Second user registering the same token moves ownership to them.
    await devices.register('user-2', {
      token: 'fcm-token',
      platform: 'android',
      appVersion: '1.3.0',
    });
    expect(prisma.deviceToken.upsert).toHaveBeenLastCalledWith(
      expect.objectContaining({
        where: { token: 'fcm-token' },
        update: expect.objectContaining({
          userId: 'user-2',
          platform: 'android',
          revokedAt: null,
        }),
      }),
    );

    await devices.remove('user-2', 'fcm-token');
    expect(prisma.deviceToken.updateMany).toHaveBeenCalledWith({
      where: { userId: 'user-2', token: 'fcm-token', revokedAt: null },
      data: { revokedAt: expect.any(Date) },
    });
  });
});
