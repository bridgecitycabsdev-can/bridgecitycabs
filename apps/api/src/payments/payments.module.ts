import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { CashProvider } from './cash.provider.js';
import { FakeProvider } from './fake.provider.js';
import { fakePaymentsAllowed } from './fake-payments-env.js';
import { PAYMENT_PROVIDERS, type PaymentProvider } from './payment-provider.js';
import { PaymentProvidersService } from './payment-providers.service.js';

@Module({
  providers: [
    CashProvider,
    FakeProvider,
    {
      provide: PAYMENT_PROVIDERS,
      inject: [ConfigService, CashProvider, FakeProvider],
      useFactory: (
        config: ConfigService,
        cash: CashProvider,
        fake: FakeProvider,
      ): ReadonlyMap<string, PaymentProvider> => {
        const map = new Map<string, PaymentProvider>([[cash.name, cash]]);
        // Stripe (or Moneris, etc.) registers here on Day 10.
        if (fakePaymentsAllowed(processEnv(config))) {
          map.set(fake.name, fake);
        }
        return map;
      },
    },
    PaymentProvidersService,
  ],
  exports: [PaymentProvidersService, PAYMENT_PROVIDERS],
})
export class PaymentsModule {}

function processEnv(config: ConfigService): NodeJS.ProcessEnv {
  return {
    NODE_ENV: config.get<string>('NODE_ENV'),
    ALLOW_FAKE_PAYMENTS: config.get<string>('ALLOW_FAKE_PAYMENTS'),
  };
}
