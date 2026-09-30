import { Injectable, Logger, ServiceUnavailableException } from '@nestjs/common';
import type { SmsProvider } from './sms-provider.js';

@Injectable()
export class ConsoleSmsProvider implements SmsProvider {
  private readonly logger = new Logger(ConsoleSmsProvider.name);

  async sendTransactional(to: string, body: string) {
    this.logger.log(`Transactional SMS to ${to}: ${body}`);
  }
}

export class UnconfiguredSmsProvider implements SmsProvider {
  async sendTransactional() {
    throw new ServiceUnavailableException('Transactional SMS is not configured');
  }
}
