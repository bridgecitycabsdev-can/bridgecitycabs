import * as Sentry from '@sentry/node';
import { nodeProfilingIntegration } from '@sentry/profiling-node';

let initialized = false;

/** Call once before Nest bootstrap. No-op when SENTRY_DSN is unset. */
export function initSentry() {
  if (initialized) return;
  initialized = true;

  const dsn = process.env.SENTRY_DSN?.trim();
  if (!dsn) return;

  const environment = process.env.NODE_ENV?.trim() || 'development';

  Sentry.init({
    dsn,
    environment,
    integrations: [nodeProfilingIntegration()],
    tracesSampleRate: environment === 'production' ? 0.1 : 1.0,
    profileSessionSampleRate: environment === 'production' ? 0.1 : 1.0,
    beforeSend(event) {
      const data = event.request?.data;
      if (data && typeof data === 'object' && !Array.isArray(data)) {
        const body = data as Record<string, unknown>;
        if ('password' in body) delete body.password;
        if ('code' in body) delete body.code;
      }
      if (event.user?.ip_address) delete event.user.ip_address;
      return event;
    },
  });
}

export { Sentry };
