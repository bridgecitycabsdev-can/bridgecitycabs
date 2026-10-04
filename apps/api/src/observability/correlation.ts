import { AsyncLocalStorage } from 'node:async_hooks';
import { randomUUID } from 'node:crypto';

type Store = { correlationId: string };

const storage = new AsyncLocalStorage<Store>();

/** Current request/job correlation id, or undefined outside a bound context. */
export function getCorrelationId(): string | undefined {
  return storage.getStore()?.correlationId;
}

/** Prefer an existing id, else generate one (used when enqueueing outside HTTP). */
export function correlationIdOrNew(): string {
  return getCorrelationId() ?? randomUUID();
}

export function runWithCorrelationId<T>(
  correlationId: string,
  fn: () => T,
): T {
  return storage.run({ correlationId }, fn);
}

export async function runWithCorrelationIdAsync<T>(
  correlationId: string,
  fn: () => Promise<T>,
): Promise<T> {
  return storage.run({ correlationId }, fn);
}

/** Merge correlationId into BullMQ job payloads. */
export function withCorrelationId<T extends Record<string, unknown>>(
  data: T,
): T & { correlationId: string } {
  return { ...data, correlationId: correlationIdOrNew() };
}

export function readJobCorrelationId(data: unknown): string {
  if (
    data &&
    typeof data === 'object' &&
    'correlationId' in data &&
    typeof (data as { correlationId: unknown }).correlationId === 'string' &&
    (data as { correlationId: string }).correlationId.length > 0
  ) {
    return (data as { correlationId: string }).correlationId;
  }
  return randomUUID();
}
