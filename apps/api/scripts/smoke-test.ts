/**
 * Post-deploy smoke: /health/ready, login, /branches — fail loud if the box is up but miswired.
 *
 *   pnpm exec tsx scripts/smoke-test.ts --base-url https://staging-api.bridgecitycabs.com
 *
 * Env (or flags):
 *   SMOKE_BASE_URL / --base-url
 *   SMOKE_EMAIL / --email
 *   SMOKE_PASSWORD / --password
 */
import { loadEnvFile } from './load-env.js';
import { flag } from './sim-session.js';

loadEnvFile();

const baseUrl = (
  flag('base-url') ??
  process.env.SMOKE_BASE_URL ??
  process.env.API_ORIGIN ??
  'http://localhost:3000'
).replace(/\/$/, '');
const email = flag('email') ?? process.env.SMOKE_EMAIL ?? process.env.SEED_ADMIN_EMAIL;
const password =
  flag('password') ?? process.env.SMOKE_PASSWORD ?? process.env.SEED_ADMIN_PASSWORD;

if (!email || !password) {
  fail('Set SMOKE_EMAIL/SMOKE_PASSWORD (or SEED_ADMIN_*) for the smoke-test account');
}

const timeoutMs = Number(process.env.SMOKE_TIMEOUT_MS ?? 8_000);

console.log(`smoke → ${baseUrl}`);

const ready = await getJson('/api/v1/health/ready');
if (ready.status !== 'ready') {
  fail(`readiness check failed: ${JSON.stringify(ready)}`);
}
console.log('ok  GET /api/v1/health/ready');

const session = (await postJson('/api/v1/auth/login', { email, password })) as {
  accessToken?: string;
};
if (!session.accessToken) {
  fail('login returned no accessToken');
}
console.log('ok  POST /api/v1/auth/login');

const branches = await getJson('/api/v1/branches', session.accessToken);
if (!Array.isArray(branches)) {
  fail(`branches response was not an array: ${JSON.stringify(branches)}`);
}
console.log(`ok  GET /api/v1/branches (${branches.length})`);
console.log('smoke passed');

async function getJson(path: string, token?: string) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const response = await fetch(`${baseUrl}${path}`, {
      headers: token ? { authorization: `Bearer ${token}` } : undefined,
      signal: controller.signal,
    });
    const text = await response.text();
    if (!response.ok) {
      fail(`${path} → ${response.status} ${text}`);
    }
    return text ? (JSON.parse(text) as Record<string, unknown>) : {};
  } catch (error) {
    fail(
      `${path} failed: ${error instanceof Error ? error.message : String(error)}`,
    );
  } finally {
    clearTimeout(timer);
  }
}

async function postJson(path: string, body: unknown) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const response = await fetch(`${baseUrl}${path}`, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
    const text = await response.text();
    if (!response.ok) {
      fail(`${path} → ${response.status} ${text}`);
    }
    return text ? JSON.parse(text) : {};
  } catch (error) {
    fail(
      `${path} failed: ${error instanceof Error ? error.message : String(error)}`,
    );
  } finally {
    clearTimeout(timer);
  }
}

function fail(message: string): never {
  console.error(`smoke FAILED: ${message}`);
  process.exit(1);
}
