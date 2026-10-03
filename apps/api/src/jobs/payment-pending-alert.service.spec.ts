import { describe, expect, it, vi } from 'vitest';
import { PaymentPendingAlertService } from './payment-pending-alert.service.js';

describe('PaymentPendingAlertService', () => {
  it('writes per-branch stuck counts to Redis and never confirms money', async () => {
    const prisma = {
      branch: {
        findMany: vi.fn(async () => [{ id: 'b1' }, { id: 'b2' }]),
      },
      booking: {
        groupBy: vi.fn(async () => [{ branchId: 'b1', _count: { _all: 3 } }]),
        updateMany: vi.fn(),
      },
    };
    const redis = { set: vi.fn(async () => 'OK') };
    const service = new PaymentPendingAlertService(
      prisma as never,
      { get: () => '12' } as never,
      redis as never,
    );

    await expect(service.sweep(new Date('2026-10-03T12:00:00Z'))).resolves.toEqual(
      expect.objectContaining({ total: 3, hours: 12 }),
    );
    expect(redis.set).toHaveBeenCalledWith('alert:payment_pending:b1', '3');
    expect(redis.set).toHaveBeenCalledWith('alert:payment_pending:b2', '0');
    expect(prisma.booking.updateMany).not.toHaveBeenCalled();
  });
});
