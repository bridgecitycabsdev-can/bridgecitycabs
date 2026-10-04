import { Injectable, Logger } from '@nestjs/common';
import { PaymentProvidersService } from './payment-providers.service.js';
import { PrismaService } from '../prisma/prisma.service.js';

/** Releases an authorized Stripe hold when a booking is cancelled before capture. */
@Injectable()
export class CardHoldService {
  private readonly logger = new Logger(CardHoldService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly paymentProviders: PaymentProvidersService,
  ) {}

  async releaseAuthorized(bookingId: string) {
    const booking = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: { paymentMethod: true },
    });
    if (booking?.paymentMethod !== 'CARD') return;

    const payment = await this.prisma.payment.findFirst({
      where: {
        bookingId,
        provider: 'STRIPE',
        status: 'AUTHORIZED',
      },
    });
    if (!payment?.providerRef) return;

    try {
      await this.paymentProviders.get('STRIPE').cancel({
        providerRef: payment.providerRef,
      });
    } catch (error) {
      this.logger.warn(
        `Failed to cancel Stripe PI ${payment.providerRef} for booking ${bookingId}: ${String(error)}`,
      );
      throw error;
    }

    await this.prisma.payment.update({
      where: { id: payment.id },
      data: { status: 'CANCELLED' },
    });
  }
}
