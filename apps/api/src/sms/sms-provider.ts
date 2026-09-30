/**
 * Transactional SMS only. Marketing and promotional messages stay off this
 * path; CASL treats them differently.
 */
export interface SmsProvider {
  sendTransactional(to: string, body: string): Promise<void>;
}

export const SMS_PROVIDER = Symbol('SmsProvider');
