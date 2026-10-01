import { api, apiOrigin } from './load-env.js';

export { api, apiOrigin };

export function flag(name: string) {
  const index = process.argv.indexOf(`--${name}`);
  if (index === -1) return undefined;
  const value = process.argv[index + 1];
  if (!value || value.startsWith('--')) {
    throw new Error(`--${name} needs a value`);
  }
  return value;
}

export function devCode() {
  const code = process.env.OTP_DEV_CODE;
  if (!code || code.length !== 6) {
    throw new Error('Set OTP_DEV_CODE to the 6 digit development code');
  }
  return code;
}

export async function otpLogin(phone: string) {
  const code = devCode();
  const requested = await fetch(`${apiOrigin()}/api/v1/auth/otp/request`, {
    method: 'POST',
    headers: { 'content-type': 'application/json' },
    body: JSON.stringify({ phone }),
  });
  if (requested.status !== 202 && requested.status !== 429) {
    throw new Error(`OTP request failed: ${requested.status} ${await requested.text()}`);
  }
  return (await api('/api/v1/auth/otp/verify', {
    method: 'POST',
    body: JSON.stringify({ phone, code }),
  })) as { accessToken: string };
}

export function bearer(accessToken: string) {
  return { authorization: `Bearer ${accessToken}` };
}
