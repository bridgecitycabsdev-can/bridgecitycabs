import {
  BadRequestException,
  Inject,
  Injectable,
  Logger,
  ServiceUnavailableException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EventEmitter2 } from '@nestjs/event-emitter';
import type Stripe from 'stripe';
import { BookingStateService } from '../bookings/booking-state.service.js';
import {
  STRIPE_WEBHOOK_QUEUE,
  type StripeWebhookQueue,
} from '../jobs/stripe-webhook-queue.js';
import { cardTripLedgerLines } from '../ledger/card-ledger-lines.js';
import { LedgerService } from '../ledger/ledger.service.js';
import { getCorrelationId } from '../observability/correlation.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { STRIPE } from './stripe.token.js';

type StripeHandler = (event: Stripe.Event) => Promise<void>;

@Injectable()
export class StripeWebhookService {
  private readonly logger = new Logger(StripeWebhookService.name);
  private readonly handlers: Record<string, StripeHandler>;

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly ledger: LedgerService,
    private readonly state: BookingStateService,
    private readonly events: EventEmitter2,
    @Inject(STRIPE) private readonly stripe: Stripe | null,
    @Inject(STRIPE_WEBHOOK_QUEUE) private readonly webhookQueue: StripeWebhookQueue,
  ) {
    this.handlers = {
      'setup_intent.succeeded': (e) => this.onSetupIntentSucceeded(e),
      'payment_intent.amount_capturable_updated': (e) =>
        this.onAmountCapturableUpdated(e),
      'payment_intent.succeeded': (e) => this.onPaymentIntentSucceeded(e),
      'payment_intent.payment_failed': (e) => this.onPaymentIntentFailed(e),
      'charge.refunded': (e) => this.onChargeRefunded(e),
    };
  }

  /**
   * Verify + persist, then enqueue BullMQ processing so the HTTP correlation id
   * threads into the async worker. Returns 200 after enqueue (Stripe retries on
   * failure; the job is idempotent via processedAt).
   */
  async handle(rawBody: Buffer, signature: string | undefined) {
    const stripe = this.requireStripe();
    const secret = this.config.get<string>('STRIPE_WEBHOOK_SECRET')?.trim();
    if (!secret) {
      throw new ServiceUnavailableException('Stripe webhooks are not configured');
    }
    if (!signature) {
      throw new BadRequestException('Invalid signature');
    }

    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(rawBody, signature, secret);
    } catch {
      throw new BadRequestException('Invalid signature');
    }

    const stored = await this.prisma.webhookEvent.upsert({
      where: {
        provider_eventId: { provider: 'STRIPE', eventId: event.id },
      },
      update: {},
      create: {
        provider: 'STRIPE',
        eventId: event.id,
        type: event.type,
        payload: event as unknown as object,
      },
    });
    if (stored.processedAt) {
      return { received: true as const };
    }

    await this.webhookQueue.enqueue({
      eventId: event.id,
      correlationId: getCorrelationId(),
    });
    return { received: true as const };
  }

  /** BullMQ worker entry — runs the type-specific handler once. */
  async processEvent(eventId: string) {
    const stored = await this.prisma.webhookEvent.findUnique({
      where: {
        provider_eventId: { provider: 'STRIPE', eventId },
      },
    });
    if (!stored) {
      this.logger.warn(`stripe-webhook job: unknown event ${eventId}`);
      return;
    }
    if (stored.processedAt) return;

    const event = stored.payload as unknown as Stripe.Event;
    const handler = this.handlers[event.type];
    if (handler) {
      await handler(event);
    } else {
      this.logger.debug(`Ignoring unhandled Stripe event ${event.type}`);
    }

    await this.prisma.webhookEvent.update({
      where: { id: stored.id },
      data: { processedAt: new Date() },
    });
  }

  private async onSetupIntentSucceeded(event: Stripe.Event) {
    const si = event.data.object as Stripe.SetupIntent;
    const customerId =
      typeof si.customer === 'string' ? si.customer : si.customer?.id;
    const pmId =
      typeof si.payment_method === 'string'
        ? si.payment_method
        : si.payment_method?.id;
    if (!customerId || !pmId) {
      this.logger.warn(
        `setup_intent.succeeded ${si.id} missing customer or payment_method`,
      );
      return;
    }

    const sc = await this.prisma.stripeCustomer.findUnique({
      where: { stripeCustomerId: customerId },
    });
    if (!sc) {
      this.logger.warn(`No StripeCustomer for ${customerId}`);
      return;
    }

    const stripe = this.requireStripe();
    const pm = await stripe.paymentMethods.retrieve(pmId);
    const card = pm.card;
    const existingCount = await this.prisma.passengerPaymentMethod.count({
      where: { passengerId: sc.passengerId },
    });

    await this.prisma.passengerPaymentMethod.upsert({
      where: { stripePmId: pm.id },
      create: {
        passengerId: sc.passengerId,
        stripePmId: pm.id,
        brand: card?.brand ?? null,
        last4: card?.last4 ?? null,
        expMonth: card?.exp_month ?? null,
        expYear: card?.exp_year ?? null,
        isDefault: existingCount === 0,
      },
      update: {
        brand: card?.brand ?? null,
        last4: card?.last4 ?? null,
        expMonth: card?.exp_month ?? null,
        expYear: card?.exp_year ?? null,
      },
    });
  }

  private async onAmountCapturableUpdated(event: Stripe.Event) {
    const pi = event.data.object as Stripe.PaymentIntent;
    await this.prisma.payment.updateMany({
      where: { provider: 'STRIPE', providerRef: pi.id },
      data: { status: 'AUTHORIZED' },
    });
  }

  private async onPaymentIntentSucceeded(event: Stripe.Event) {
    const pi = event.data.object as Stripe.PaymentIntent;
    const { paid, closed } = await this.prisma.$transaction(async (tx) => {
      await tx.$queryRaw`
        SELECT 1 FROM "Payment" WHERE "providerRef" = ${pi.id} FOR UPDATE
      `;
      const payment = await tx.payment.findFirst({
        where: { provider: 'STRIPE', providerRef: pi.id },
      });
      if (!payment) {
        this.logger.warn(`payment_intent.succeeded: no Payment for ${pi.id}`);
        return { paid: null, closed: null };
      }

      if (payment.status === 'CAPTURED') {
        const booking = await tx.booking.findUnique({
          where: { id: payment.bookingId },
        });
        if (booking?.status === 'CLOSED') {
          return { paid: null, closed: null };
        }
      }

      await tx.payment.update({
        where: { id: payment.id },
        data: {
          status: 'CAPTURED',
          capturedAt: payment.capturedAt ?? new Date(),
        },
      });

      const booking = await tx.booking.findUnique({
        where: { id: payment.bookingId },
      });
      if (!booking) return { paid: null, closed: null };

      if (
        booking.finalFareCents == null ||
        booking.finalSubtotalCents == null ||
        booking.finalTaxCents == null ||
        booking.commissionCents == null ||
        booking.driverEarningCents == null ||
        !booking.driverId
      ) {
        this.logger.warn(
          `payment_intent.succeeded: booking ${booking.id} missing settlement amounts`,
        );
        return { paid: null, closed: null };
      }

      await this.ledger.post(tx, {
        kind: 'TRIP_CARD',
        sourceType: 'BOOKING',
        sourceId: booking.id,
        branchId: booking.branchId,
        description: 'Card trip settlement',
        lines: cardTripLedgerLines({
          branchId: booking.branchId,
          driverId: booking.driverId,
          subtotalCents: booking.finalSubtotalCents,
          taxCents: booking.finalTaxCents,
          commissionCents: booking.commissionCents,
          driverEarningCents: booking.driverEarningCents,
        }),
      });

      await tx.booking.update({
        where: { id: booking.id },
        data: { paymentStatus: 'PAID' },
      });

      if (booking.status !== 'PAYMENT_PENDING') {
        // Already moved on; ledger + payment update are enough.
        return { paid: null, closed: null };
      }

      const paid = await this.state.transition(
        booking.id,
        'PAYMENT_COMPLETED',
        { type: 'SYSTEM' },
        { tx },
      );
      const closed = await this.state.transition(
        booking.id,
        'CLOSED',
        { type: 'SYSTEM' },
        { tx },
      );
      return { paid, closed };
    });

    if (paid) await this.events.emitAsync('booking.status_changed', paid);
    if (closed) await this.events.emitAsync('booking.status_changed', closed);
  }

  private async onPaymentIntentFailed(event: Stripe.Event) {
    const pi = event.data.object as Stripe.PaymentIntent;
    const updated = await this.prisma.payment.updateMany({
      where: { provider: 'STRIPE', providerRef: pi.id },
      data: {
        status: 'FAILED',
        failureCode: pi.last_payment_error?.code ?? 'payment_failed',
      },
    });
    if (updated.count === 0) {
      this.logger.warn(`payment_intent.payment_failed: no Payment for ${pi.id}`);
      return;
    }
    // Booking stays PAYMENT_PENDING so it surfaces on the payment_pending tab.
    this.logger.warn(`Card payment failed for PaymentIntent ${pi.id}`);
  }

  private async onChargeRefunded(event: Stripe.Event) {
    const charge = event.data.object as Stripe.Charge;
    const piId =
      typeof charge.payment_intent === 'string'
        ? charge.payment_intent
        : charge.payment_intent?.id;
    if (!piId) {
      this.logger.warn(`charge.refunded ${charge.id} has no payment_intent`);
      return;
    }

    await this.prisma.$transaction(async (tx) => {
      const payment = await tx.payment.findFirst({
        where: { provider: 'STRIPE', providerRef: piId },
      });
      if (!payment) {
        this.logger.warn(`charge.refunded: no Payment for ${piId}`);
        return;
      }

      await tx.payment.update({
        where: { id: payment.id },
        data: { status: 'REFUNDED' },
      });

      const original = await tx.ledgerTransaction.findFirst({
        where: {
          sourceType: 'BOOKING',
          sourceId: payment.bookingId,
          kind: 'TRIP_CARD',
        },
        include: { entries: { include: { account: true } } },
      });
      if (!original) return;

      const already = await tx.ledgerTransaction.findUnique({
        where: { reversalOfId: original.id },
      });
      if (already) return;

      const lines = original.entries
        .map((entry) => ({
          accountKey: entry.account.key,
          type: entry.account.type,
          ownerId: entry.account.ownerId ?? undefined,
          amountCents: -entry.amountCents,
        }))
        .filter((line) => line.amountCents !== 0);

      await this.ledger.post(tx, {
        kind: 'REVERSAL',
        sourceType: 'REVERSAL',
        sourceId: original.id,
        branchId: original.branchId,
        description: 'Stripe charge.refunded',
        reversalOfId: original.id,
        lines,
      });

      await tx.booking.updateMany({
        where: { id: payment.bookingId },
        data: { paymentStatus: 'REFUNDED' },
      });
    });
  }

  private requireStripe(): Stripe {
    if (!this.stripe) {
      throw new ServiceUnavailableException('Card payments are not configured');
    }
    return this.stripe;
  }
}
