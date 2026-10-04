import { BadRequestException } from '@nestjs/common';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { StripeWebhookService } from './stripe-webhook.service.js';

describe('StripeWebhookService', () => {
  const secret = 'whsec_test';
  let constructEvent: ReturnType<typeof vi.fn>;
  let prisma: {
    webhookEvent: {
      upsert: ReturnType<typeof vi.fn>;
      findUnique: ReturnType<typeof vi.fn>;
      update: ReturnType<typeof vi.fn>;
    };
    stripeCustomer: { findUnique: ReturnType<typeof vi.fn> };
    passengerPaymentMethod: {
      count: ReturnType<typeof vi.fn>;
      upsert: ReturnType<typeof vi.fn>;
    };
    payment: {
      updateMany: ReturnType<typeof vi.fn>;
      findFirst: ReturnType<typeof vi.fn>;
      update: ReturnType<typeof vi.fn>;
    };
    booking: {
      findUnique: ReturnType<typeof vi.fn>;
      update: ReturnType<typeof vi.fn>;
      updateMany: ReturnType<typeof vi.fn>;
    };
    ledgerTransaction: {
      findFirst: ReturnType<typeof vi.fn>;
      findUnique: ReturnType<typeof vi.fn>;
    };
    $transaction: ReturnType<typeof vi.fn>;
    $queryRaw: ReturnType<typeof vi.fn>;
  };
  let stripe: {
    webhooks: { constructEvent: ReturnType<typeof vi.fn> };
    paymentMethods: { retrieve: ReturnType<typeof vi.fn> };
  };
  let ledger: { post: ReturnType<typeof vi.fn> };
  let state: { transition: ReturnType<typeof vi.fn> };
  let events: { emitAsync: ReturnType<typeof vi.fn> };
  let service: StripeWebhookService;

  beforeEach(() => {
    constructEvent = vi.fn();
    prisma = {
      webhookEvent: {
        upsert: vi.fn(async ({ create }) => ({
          id: 'we-1',
          processedAt: null,
          ...create,
        })),
        findUnique: vi.fn(async () => {
          const event = constructEvent.mock.results.at(-1)?.value;
          if (!event) return null;
          return {
            id: 'we-1',
            processedAt: null,
            eventId: event.id,
            type: event.type,
            payload: event,
          };
        }),
        update: vi.fn(async () => ({ id: 'we-1' })),
      },
      stripeCustomer: {
        findUnique: vi.fn(async () => ({
          passengerId: 'pass-1',
          stripeCustomerId: 'cus_1',
        })),
      },
      passengerPaymentMethod: {
        count: vi.fn(async () => 0),
        upsert: vi.fn(async () => ({ id: 'ppm-1' })),
      },
      payment: {
        updateMany: vi.fn(async () => ({ count: 1 })),
        findFirst: vi.fn(),
        update: vi.fn(),
      },
      booking: {
        findUnique: vi.fn(),
        update: vi.fn(),
        updateMany: vi.fn(),
      },
      ledgerTransaction: {
        findFirst: vi.fn(),
        findUnique: vi.fn(),
      },
      $queryRaw: vi.fn(async () => [{ '?column?': 1 }]),
      $transaction: vi.fn(async (fn: (tx: typeof prisma) => unknown) =>
        fn(prisma),
      ),
    };
    stripe = {
      webhooks: { constructEvent },
      paymentMethods: {
        retrieve: vi.fn(async () => ({
          id: 'pm_1',
          card: {
            brand: 'visa',
            last4: '4242',
            exp_month: 12,
            exp_year: 2030,
          },
        })),
      },
    };
    ledger = { post: vi.fn(async () => ({ id: 'txn-1' })) };
    state = {
      transition: vi
        .fn()
        .mockResolvedValueOnce({
          bookingId: 'b1',
          to: 'PAYMENT_COMPLETED',
        })
        .mockResolvedValueOnce({ bookingId: 'b1', to: 'CLOSED' }),
    };
    events = { emitAsync: vi.fn(async () => []) };
    const queue = {
      enqueue: vi.fn(async (job: { eventId: string }) => {
        await service.processEvent(job.eventId);
      }),
    };
    service = new StripeWebhookService(
      prisma as never,
      { get: (key: string) => (key === 'STRIPE_WEBHOOK_SECRET' ? secret : undefined) } as never,
      ledger as never,
      state as never,
      events as never,
      stripe as never,
      queue as never,
    );
  });

  it('rejects a tampered body / invalid signature with 400', async () => {
    constructEvent.mockImplementation(() => {
      throw new Error('bad sig');
    });
    await expect(
      service.handle(Buffer.from('{"tampered":true}'), 'sig'),
    ).rejects.toBeInstanceOf(BadRequestException);
    expect(prisma.webhookEvent.upsert).not.toHaveBeenCalled();
    expect(ledger.post).not.toHaveBeenCalled();
  });

  it('ignores already-processed events', async () => {
    constructEvent.mockReturnValue({
      id: 'evt_1',
      type: 'payment_intent.succeeded',
      data: { object: { id: 'pi_1' } },
    });
    prisma.webhookEvent.upsert.mockResolvedValueOnce({
      id: 'we-1',
      processedAt: new Date(),
    });

    await expect(
      service.handle(Buffer.from('{}'), 'sig'),
    ).resolves.toEqual({ received: true });
    expect(ledger.post).not.toHaveBeenCalled();
  });

  it('writes exactly one PassengerPaymentMethod on setup_intent.succeeded', async () => {
    constructEvent.mockReturnValue({
      id: 'evt_si',
      type: 'setup_intent.succeeded',
      data: {
        object: {
          id: 'seti_1',
          customer: 'cus_1',
          payment_method: 'pm_1',
        },
      },
    });

    await service.handle(Buffer.from('{}'), 'sig');

    expect(prisma.passengerPaymentMethod.upsert).toHaveBeenCalledTimes(1);
    expect(prisma.passengerPaymentMethod.upsert).toHaveBeenCalledWith(
      expect.objectContaining({
        where: { stripePmId: 'pm_1' },
        create: expect.objectContaining({
          passengerId: 'pass-1',
          brand: 'visa',
          last4: '4242',
          isDefault: true,
        }),
      }),
    );
    expect(prisma.webhookEvent.update).toHaveBeenCalledWith({
      where: { id: 'we-1' },
      data: { processedAt: expect.any(Date) },
    });
  });

  it('marks Payment AUTHORIZED on amount_capturable_updated', async () => {
    constructEvent.mockReturnValue({
      id: 'evt_auth',
      type: 'payment_intent.amount_capturable_updated',
      data: { object: { id: 'pi_1' } },
    });

    await service.handle(Buffer.from('{}'), 'sig');

    expect(prisma.payment.updateMany).toHaveBeenCalledWith({
      where: { provider: 'STRIPE', providerRef: 'pi_1' },
      data: { status: 'AUTHORIZED' },
    });
  });

  it('posts TRIP_CARD and closes the booking on payment_intent.succeeded', async () => {
    constructEvent.mockReturnValue({
      id: 'evt_ok',
      type: 'payment_intent.succeeded',
      data: { object: { id: 'pi_1' } },
    });
    prisma.payment.findFirst.mockResolvedValue({
      id: 'pay-1',
      bookingId: 'b1',
      status: 'AUTHORIZED',
      capturedAt: null,
    });
    prisma.booking.findUnique.mockResolvedValue({
      id: 'b1',
      branchId: 'branch-1',
      status: 'PAYMENT_PENDING',
      driverId: 'driver-1',
      finalFareCents: 2100,
      finalSubtotalCents: 2000,
      finalTaxCents: 100,
      commissionCents: 200,
      driverEarningCents: 1800,
    });

    await service.handle(Buffer.from('{}'), 'sig');

    expect(prisma.payment.update).toHaveBeenCalledWith({
      where: { id: 'pay-1' },
      data: expect.objectContaining({ status: 'CAPTURED' }),
    });
    expect(ledger.post).toHaveBeenCalledWith(
      prisma,
      expect.objectContaining({
        kind: 'TRIP_CARD',
        sourceType: 'BOOKING',
        sourceId: 'b1',
      }),
    );
    expect(state.transition).toHaveBeenCalledWith(
      'b1',
      'PAYMENT_COMPLETED',
      { type: 'SYSTEM' },
      expect.objectContaining({ tx: prisma }),
    );
    expect(state.transition).toHaveBeenCalledWith(
      'b1',
      'CLOSED',
      { type: 'SYSTEM' },
      expect.objectContaining({ tx: prisma }),
    );
    expect(events.emitAsync).toHaveBeenCalledTimes(2);
  });

  it('posts one TRIP_CARD and closes once when the same PI succeeds twice', async () => {
    const piSucceeded = {
      type: 'payment_intent.succeeded' as const,
      data: { object: { id: 'pi_1' } },
    };
    constructEvent
      .mockReturnValueOnce({ id: 'evt_a', ...piSucceeded })
      .mockReturnValueOnce({ id: 'evt_b', ...piSucceeded });

    prisma.webhookEvent.upsert
      .mockResolvedValueOnce({
        id: 'we-a',
        processedAt: null,
        eventId: 'evt_a',
      })
      .mockResolvedValueOnce({
        id: 'we-b',
        processedAt: null,
        eventId: 'evt_b',
      });

    prisma.payment.findFirst
      .mockResolvedValueOnce({
        id: 'pay-1',
        bookingId: 'b1',
        status: 'AUTHORIZED',
        capturedAt: null,
      })
      .mockResolvedValueOnce({
        id: 'pay-1',
        bookingId: 'b1',
        status: 'CAPTURED',
        capturedAt: new Date(),
      });
    prisma.booking.findUnique
      .mockResolvedValueOnce({
        id: 'b1',
        branchId: 'branch-1',
        status: 'PAYMENT_PENDING',
        driverId: 'driver-1',
        finalFareCents: 2100,
        finalSubtotalCents: 2000,
        finalTaxCents: 100,
        commissionCents: 200,
        driverEarningCents: 1800,
      })
      // Second delivery: CAPTURED + CLOSED short-circuit uses one findUnique.
      .mockResolvedValueOnce({
        id: 'b1',
        status: 'CLOSED',
      });

    await service.handle(Buffer.from('{}'), 'sig');
    await service.handle(Buffer.from('{}'), 'sig');

    expect(ledger.post).toHaveBeenCalledTimes(1);
    expect(ledger.post).toHaveBeenCalledWith(
      prisma,
      expect.objectContaining({ kind: 'TRIP_CARD', sourceId: 'b1' }),
    );
    expect(
      state.transition.mock.calls.filter((c) => c[1] === 'CLOSED'),
    ).toHaveLength(1);
  });

  it('marks Payment FAILED on payment_intent.payment_failed', async () => {
    constructEvent.mockReturnValue({
      id: 'evt_fail',
      type: 'payment_intent.payment_failed',
      data: {
        object: {
          id: 'pi_1',
          last_payment_error: { code: 'card_declined' },
        },
      },
    });

    await service.handle(Buffer.from('{}'), 'sig');

    expect(prisma.payment.updateMany).toHaveBeenCalledWith({
      where: { provider: 'STRIPE', providerRef: 'pi_1' },
      data: { status: 'FAILED', failureCode: 'card_declined' },
    });
  });

  it('refunds Payment and posts REVERSAL on charge.refunded', async () => {
    constructEvent.mockReturnValue({
      id: 'evt_re',
      type: 'charge.refunded',
      data: {
        object: { id: 'ch_1', payment_intent: 'pi_1' },
      },
    });
    prisma.payment.findFirst.mockResolvedValue({
      id: 'pay-1',
      bookingId: 'b1',
    });
    prisma.ledgerTransaction.findFirst.mockResolvedValue({
      id: 'txn-1',
      branchId: 'branch-1',
      entries: [
        {
          amountCents: 100,
          account: {
            key: 'PAYMENT_CLEARING:branch-1',
            type: 'PAYMENT_CLEARING',
            ownerId: null,
          },
        },
      ],
    });
    prisma.ledgerTransaction.findUnique.mockResolvedValue(null);

    await service.handle(Buffer.from('{}'), 'sig');

    expect(prisma.payment.update).toHaveBeenCalledWith({
      where: { id: 'pay-1' },
      data: { status: 'REFUNDED' },
    });
    expect(ledger.post).toHaveBeenCalledWith(
      prisma,
      expect.objectContaining({
        kind: 'REVERSAL',
        reversalOfId: 'txn-1',
      }),
    );
    expect(prisma.booking.updateMany).toHaveBeenCalledWith({
      where: { id: 'b1' },
      data: { paymentStatus: 'REFUNDED' },
    });
  });
});
