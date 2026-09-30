import { createHash, randomInt } from 'node:crypto';

export const OTP_TTL_SECONDS = 5 * 60;
export const OTP_RESEND_SECONDS = 60;
export const OTP_MAX_ATTEMPTS = 5;
export const OTP_DAILY_PHONE_CAP = 10;
export const OTP_DAILY_IP_CAP = 20;

export const OTP_ACCEPTED = { accepted: true } as const;

export function hashOtp(pepper: string, code: string) {
  return createHash('sha256').update(`${pepper}:${code}`).digest('hex');
}

export function useDevOtp(devCode: string | undefined, nodeEnv: string | undefined) {
  return nodeEnv !== 'production' && !!devCode && /^\d{6}$/.test(devCode);
}

export function newOtpCode(devCode: string | undefined, nodeEnv: string | undefined) {
  if (useDevOtp(devCode, nodeEnv) && devCode) {
    return devCode;
  }
  return randomInt(0, 1_000_000).toString().padStart(6, '0');
}

export function secondsUntilUtcMidnight(now = new Date()) {
  const next = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1);
  return Math.max(1, Math.ceil((next - now.getTime()) / 1000));
}
