export function fakePaymentsAllowed(env: NodeJS.ProcessEnv = process.env) {
  const raw = env.ALLOW_FAKE_PAYMENTS?.trim().toLowerCase();
  return raw === '1' || raw === 'true' || raw === 'yes';
}

/** Mirrors assertOtpDevCode: the fake card provider must never ship to prod. */
export function assertFakePaymentsEnv(env: NodeJS.ProcessEnv = process.env) {
  if (env.NODE_ENV === 'production' && fakePaymentsAllowed(env)) {
    throw new Error(
      'ALLOW_FAKE_PAYMENTS must not be set when NODE_ENV is production',
    );
  }
}
