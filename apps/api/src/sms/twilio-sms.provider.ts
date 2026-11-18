import { Logger, ServiceUnavailableException } from '@nestjs/common';
import type { SmsProvider } from './sms-provider.js';

/**
 * Transactional SMS through Twilio's Messages API.
 * Marketing messages stay off this path.
 */
export class TwilioSmsProvider implements SmsProvider {
  private readonly logger = new Logger(TwilioSmsProvider.name);

  constructor(
    private readonly accountSid: string,
    private readonly authToken: string,
    private readonly from: string,
    private readonly fetchImpl: typeof fetch = fetch,
  ) {}

  async sendTransactional(to: string, body: string) {
    const url = `https://api.twilio.com/2010-04-01/Accounts/${this.accountSid}/Messages.json`;
    const response = await this.fetchImpl(url, {
      method: 'POST',
      headers: {
        authorization: `Basic ${Buffer.from(`${this.accountSid}:${this.authToken}`).toString('base64')}`,
        'content-type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({ To: to, From: this.from, Body: body }),
    });
    if (!response.ok) {
      this.logger.warn(`Twilio SMS failed with status ${response.status}`);
      throw new ServiceUnavailableException('Transactional SMS failed');
    }
  }
}
