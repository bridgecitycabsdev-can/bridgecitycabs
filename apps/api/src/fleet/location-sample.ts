/** Trip pings are the record used when a fare is disputed. */
export const HISTORY_EVERY_PING_STATUSES = ['EN_ROUTE_PICKUP', 'ARRIVED', 'ON_TRIP'] as const;

export const HISTORY_IDLE_SAMPLE_MS = 60_000;

const everyPing = new Set<string>(HISTORY_EVERY_PING_STATUSES);

export function shouldSampleLocation(
  status: string | null,
  lastSampleMs: number | null,
  nowMs: number,
) {
  if (status && everyPing.has(status)) return true;
  if (lastSampleMs == null || !Number.isFinite(lastSampleMs)) return true;
  return nowMs - lastSampleMs >= HISTORY_IDLE_SAMPLE_MS;
}
