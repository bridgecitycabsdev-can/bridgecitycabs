import { ConsoleSmsProvider, UnconfiguredSmsProvider } from './console-sms.provider.js';
import type { SmsProvider } from './sms-provider.js';
import { TwilioSmsProvider } from './twilio-sms.provider.js';

/** Twilio when all three secrets are set. Otherwise console in dev, and a hard failure in production. */
export function selectSmsProvider(
  env: NodeJS.ProcessEnv,
  consoleProvider: SmsProvider = new ConsoleSmsProvider(),
  fetchImpl?: typeof fetch,
): SmsProvider {
  const sid = env.TWILIO_ACCOUNT_SID?.trim();
  const token = env.TWILIO_AUTH_TOKEN?.trim();
  const from = env.TWILIO_FROM_NUMBER?.trim();
  if (sid && token && from) {
    return new TwilioSmsProvider(sid, token, from, fetchImpl);
  }
  if (env.NODE_ENV === 'production') return new UnconfiguredSmsProvider();
  return consoleProvider;
}
