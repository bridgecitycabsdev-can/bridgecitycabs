import { NotFoundException } from '@nestjs/common';
import { describe, expect, it } from 'vitest';
import { CashProvider } from './cash.provider.js';
import { FakeProvider } from './fake.provider.js';
import { PaymentProvidersService } from './payment-providers.service.js';
import { StripeProvider } from './stripe.provider.js';

describe('PaymentProvidersService', () => {
  it('resolves registered providers by name', () => {
    const cash = new CashProvider();
    const fake = new FakeProvider();
    const stripe = new StripeProvider({
      paymentIntents: {},
      refunds: {},
    } as never);
    const service = new PaymentProvidersService(
      new Map([
        [cash.name, cash],
        [fake.name, fake],
        [stripe.name, stripe],
      ]),
    );
    expect(service.get('CASH')).toBe(cash);
    expect(service.get('FAKE')).toBe(fake);
    expect(service.get('STRIPE')).toBe(stripe);
    expect(service.names()).toEqual(['CASH', 'FAKE', 'STRIPE']);
  });

  it('throws when the provider is not registered', () => {
    const service = new PaymentProvidersService(
      new Map([['CASH', new CashProvider()]]),
    );
    expect(() => service.get('STRIPE')).toThrow(NotFoundException);
    expect(service.has('STRIPE')).toBe(false);
  });
});
