import { ServiceUnavailableException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { ConsoleSmsProvider, UnconfiguredSmsProvider } from './console-sms.provider.js';
import { selectSmsProvider } from './select-sms-provider.js';
import { TwilioSmsProvider } from './twilio-sms.provider.js';

describe('selectSmsProvider', () => {
  it('uses Twilio when the account, token, and from-number are set', () => {
    const provider = selectSmsProvider({
      TWILIO_ACCOUNT_SID: 'AC123',
      TWILIO_AUTH_TOKEN: 'secret',
      TWILIO_FROM_NUMBER: '+14035550100',
      NODE_ENV: 'production',
    });
    expect(provider).toBeInstanceOf(TwilioSmsProvider);
  });

  it('logs to the console outside production when Twilio is unset', () => {
    const provider = selectSmsProvider({ NODE_ENV: 'development' });
    expect(provider).toBeInstanceOf(ConsoleSmsProvider);
  });

  it('refuses to send in production when Twilio is unset', () => {
    const provider = selectSmsProvider({ NODE_ENV: 'production' });
    expect(provider).toBeInstanceOf(UnconfiguredSmsProvider);
  });
});

describe('TwilioSmsProvider', () => {
  it('posts a transactional message and does not throw on success', async () => {
    const fetchImpl = vi.fn(async () => new Response('', { status: 201 }));
    const provider = new TwilioSmsProvider(
      'AC123',
      'secret',
      '+14035550100',
      fetchImpl,
    );
    await provider.sendTransactional('+14035550199', 'Your code is 123456');
    expect(fetchImpl).toHaveBeenCalledOnce();
    const [url, init] = fetchImpl.mock.calls[0] as [string, RequestInit];
    expect(url).toContain('/Accounts/AC123/Messages.json');
    expect(String(init.body)).toContain('To=%2B14035550199');
    expect(init.headers).toMatchObject({
      authorization: `Basic ${Buffer.from('AC123:secret').toString('base64')}`,
    });
  });

  it('throws when Twilio rejects the message', async () => {
    const fetchImpl = vi.fn(async () => new Response('no', { status: 400 }));
    const provider = new TwilioSmsProvider('AC123', 'secret', '+14035550100', fetchImpl);
    await expect(provider.sendTransactional('+14035550199', 'hi')).rejects.toBeInstanceOf(
      ServiceUnavailableException,
    );
  });
});
