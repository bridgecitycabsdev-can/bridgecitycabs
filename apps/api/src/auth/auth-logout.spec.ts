import { describe, expect, it, vi } from 'vitest';
import { AuthService } from './auth.service.js';

describe('AuthService.logout', () => {
  it('revokes the refresh token and deletes the user device tokens', async () => {
    const prisma = {
      refreshToken: { updateMany: vi.fn(async () => ({ count: 1 })) },
      deviceToken: { deleteMany: vi.fn(async () => ({ count: 2 })) },
    };
    const auth = new AuthService(
      prisma as never,
      {} as never,
      { get: () => '7' } as never,
      {} as never,
      { sendTransactional: async () => undefined } as never,
    );

    await expect(auth.logout('user-1', 'refresh-token')).resolves.toEqual({ success: true });

    expect(prisma.refreshToken.updateMany).toHaveBeenCalledWith(
      expect.objectContaining({
        data: { revokedAt: expect.any(Date) },
      }),
    );
    expect(prisma.deviceToken.deleteMany).toHaveBeenCalledWith({ where: { userId: 'user-1' } });
  });
});
