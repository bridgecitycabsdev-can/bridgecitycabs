export function assertOtpDevCode(env: NodeJS.ProcessEnv = process.env) {
  const code = env.OTP_DEV_CODE?.trim();
  if (env.NODE_ENV === 'production' && code) {
    throw new Error('OTP_DEV_CODE must not be set when NODE_ENV is production');
  }
}
