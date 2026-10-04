import { describe, expect, it, vi } from 'vitest';
import { CardHoldService } from './card-hold.service.js';

describe('CardHoldService', () => {
  it('cancels an AUTHORIZED Stripe PaymentIntent and marks Payment CANCELLED', async () => {
    const cancel = vi.fn(async () => undefined);
    const prisma = {
      booking: {
        findUnique: vi.fn(async () => ({ paymentMethod: 'CARD' })),
      },
      payment: {
        findFirst: vi.fn(async () => ({
          id: 'pay-1',
          providerRef: 'pi_1',
          status: 'AUTHORIZED',
        })),
        update: vi.fn(async () => ({ id: 'pay-1' })),
      },
    };
    const service = new CardHoldService(
      prisma as never,
      { get: () => ({ cancel }) } as never,
    );

    await service.releaseAuthorized('b1');

    expect(cancel).toHaveBeenCalledWith({ providerRef: 'pi_1' });
    expect(prisma.payment.update).toHaveBeenCalledWith({
      where: { id: 'pay-1' },
      data: { status: 'CANCELLED' },
    });
  });

  it('no-ops for cash bookings and missing authorizations', async () => {
    const cancel = vi.fn();
    const prisma = {
      booking: {
        findUnique: vi.fn(async () => ({ paymentMethod: 'CASH' })),
      },
      payment: {
        findFirst: vi.fn(),
        update: vi.fn(),
      },
    };
    const service = new CardHoldService(
      prisma as never,
      { get: () => ({ cancel }) } as never,
    );

    await service.releaseAuthorized('b1');
    expect(cancel).not.toHaveBeenCalled();

    prisma.booking.findUnique.mockResolvedValueOnce({ paymentMethod: 'CARD' });
    prisma.payment.findFirst.mockResolvedValueOnce(null);
    await service.releaseAuthorized('b1');
    expect(cancel).not.toHaveBeenCalled();
  });
});
