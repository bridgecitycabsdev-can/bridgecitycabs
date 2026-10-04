import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';
import { CardHoldService } from './card-hold.service.js';
import { CashProvider } from './cash.provider.js';
import { FakeProvider } from './fake.provider.js';
import { fakePaymentsAllowed } from './fake-payments-env.js';
import { PassengerPaymentMethodsService } from './passenger-payment-methods.service.js';
import { PAYMENT_PROVIDERS, type PaymentProvider } from './payment-provider.js';
import { PaymentProvidersService } from './payment-providers.service.js';
import { StripeProvider } from './stripe.provider.js';
import { STRIPE } from './stripe.token.js';

@Module({
  providers: [
    CashProvider,
    FakeProvider,
    CardHoldService,
    {
      provide: STRIPE,
      inject: [ConfigService],
      useFactory: (config: ConfigService): Stripe | null => {
        const key = config.get<string>('STRIPE_SECRET_KEY')?.trim();
        return key ? new Stripe(key) : null;
      },
    },
    {
      provide: PAYMENT_PROVIDERS,
      inject: [ConfigService, CashProvider, FakeProvider, STRIPE],
      useFactory: (
        config: ConfigService,
        cash: CashProvider,
        fake: FakeProvider,
        stripe: Stripe | null,
      ): ReadonlyMap<string, PaymentProvider> => {
        const map = new Map<string, PaymentProvider>([[cash.name, cash]]);
        if (stripe) {
          map.set('STRIPE', new StripeProvider(stripe));
        }
        if (fakePaymentsAllowed(processEnv(config))) {
          map.set(fake.name, fake);
        }
        return map;
      },
    },
    PaymentProvidersService,
    PassengerPaymentMethodsService,
  ],
  exports: [
    PaymentProvidersService,
    PAYMENT_PROVIDERS,
    PassengerPaymentMethodsService,
    CardHoldService,
    STRIPE,
  ],
})
export class PaymentsModule {}

function processEnv(config: ConfigService): NodeJS.ProcessEnv {
  return {
    NODE_ENV: config.get<string>('NODE_ENV'),
    ALLOW_FAKE_PAYMENTS: config.get<string>('ALLOW_FAKE_PAYMENTS'),
  };
}
