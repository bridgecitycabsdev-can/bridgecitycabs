import { Inject, Injectable, NotFoundException } from '@nestjs/common';
import {
  PAYMENT_PROVIDERS,
  type PaymentProvider,
} from './payment-provider.js';

@Injectable()
export class PaymentProvidersService {
  constructor(
    @Inject(PAYMENT_PROVIDERS)
    private readonly providers: ReadonlyMap<string, PaymentProvider>,
  ) {}

  get(name: string): PaymentProvider {
    const provider = this.providers.get(name);
    if (!provider) {
      throw new NotFoundException(`Unknown payment provider: ${name}`);
    }
    return provider;
  }

  has(name: string) {
    return this.providers.has(name);
  }

  names() {
    return [...this.providers.keys()];
  }
}
