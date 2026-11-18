import {
  Injectable,
  Inject,
  NotFoundException,
  ServiceUnavailableException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type Stripe from 'stripe';
import type { AuthUser } from '../common/auth-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { STRIPE } from './stripe.token.js';

@Injectable()
export class PassengerPaymentMethodsService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(STRIPE) private readonly stripe: Stripe | null,
  ) {}

  async createSetupIntent(user: AuthUser) {
    const passenger = await this.requirePassenger(user);
    const stripe = this.requireStripe();

    let sc = await this.prisma.stripeCustomer.findUnique({
      where: { passengerId: passenger.id },
    });
    if (!sc) {
      const customer = await stripe.customers.create({
        metadata: { passengerId: passenger.id },
      });
      try {
        sc = await this.prisma.stripeCustomer.create({
          data: {
            passengerId: passenger.id,
            stripeCustomerId: customer.id,
          },
        });
      } catch (error) {
        if (
          error instanceof Prisma.PrismaClientKnownRequestError &&
          error.code === 'P2002'
        ) {
          sc = await this.prisma.stripeCustomer.findUniqueOrThrow({
            where: { passengerId: passenger.id },
          });
        } else {
          throw error;
        }
      }
    }

    const si = await stripe.setupIntents.create({
      customer: sc.stripeCustomerId,
      usage: 'off_session',
    });
    if (!si.client_secret) {
      throw new ServiceUnavailableException('Stripe SetupIntent missing client secret');
    }
    return {
      clientSecret: si.client_secret,
      customerId: sc.stripeCustomerId,
    };
  }

  cardConfig() {
    const key = process.env.STRIPE_PUBLISHABLE_KEY?.trim() ?? '';
    const publishableKey = key.startsWith('pk_') ? key : '';
    return {
      publishableKey,
      cardPayments: this.stripe != null && publishableKey.length > 0,
    };
  }

  async list(user: AuthUser) {
    const passenger = await this.requirePassenger(user);
    const methods = await this.prisma.passengerPaymentMethod.findMany({
      where: { passengerId: passenger.id },
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
    });
    return methods.map(toPaymentMethodView);
  }

  async setDefault(user: AuthUser, id: string) {
    const passenger = await this.requirePassenger(user);
    const method = await this.prisma.passengerPaymentMethod.findFirst({
      where: { id, passengerId: passenger.id },
    });
    if (!method) throw new NotFoundException();

    await this.prisma.$transaction(async (tx) => {
      await tx.passengerPaymentMethod.updateMany({
        where: { passengerId: passenger.id, isDefault: true },
        data: { isDefault: false },
      });
      await tx.passengerPaymentMethod.update({
        where: { id: method.id },
        data: { isDefault: true },
      });
    });

    const stripe = this.stripe;
    if (stripe) {
      const sc = await this.prisma.stripeCustomer.findUnique({
        where: { passengerId: passenger.id },
      });
      if (sc) {
        await stripe.customers.update(sc.stripeCustomerId, {
          invoice_settings: { default_payment_method: method.stripePmId },
        });
      }
    }

    return toPaymentMethodView({ ...method, isDefault: true });
  }

  async remove(user: AuthUser, id: string) {
    const passenger = await this.requirePassenger(user);
    const method = await this.prisma.passengerPaymentMethod.findFirst({
      where: { id, passengerId: passenger.id },
    });
    if (!method) throw new NotFoundException();

    const stripe = this.requireStripe();
    try {
      await stripe.paymentMethods.detach(method.stripePmId);
    } catch (error) {
      // Already detached remotely — still drop the local row.
      if (!isStripeMissingResource(error)) throw error;
    }

    await this.prisma.passengerPaymentMethod.delete({ where: { id: method.id } });

    if (method.isDefault) {
      const next = await this.prisma.passengerPaymentMethod.findFirst({
        where: { passengerId: passenger.id },
        orderBy: { createdAt: 'desc' },
      });
      if (next) {
        await this.prisma.passengerPaymentMethod.update({
          where: { id: next.id },
          data: { isDefault: true },
        });
      }
    }

    return { ok: true as const };
  }

  private requireStripe(): Stripe {
    if (!this.stripe) {
      throw new ServiceUnavailableException('Card payments are not configured');
    }
    return this.stripe;
  }

  private async requirePassenger(user: AuthUser) {
    const passenger = await this.prisma.passenger.findUnique({
      where: { userId: user.userId },
    });
    if (!passenger) throw new NotFoundException();
    return passenger;
  }
}

function toPaymentMethodView(row: {
  id: string;
  brand: string | null;
  last4: string | null;
  expMonth: number | null;
  expYear: number | null;
  isDefault: boolean;
  createdAt: Date;
}) {
  return {
    id: row.id,
    brand: row.brand,
    last4: row.last4,
    expMonth: row.expMonth,
    expYear: row.expYear,
    isDefault: row.isDefault,
    createdAt: row.createdAt.toISOString(),
  };
}

function isStripeMissingResource(error: unknown): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    'code' in error &&
    (error as { code?: string }).code === 'resource_missing'
  );
}
