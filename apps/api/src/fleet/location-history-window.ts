const DAY_MS = 24 * 60 * 60 * 1000;
export const LOCATION_HISTORY_DEFAULT_MS = DAY_MS;
export const LOCATION_HISTORY_MAX_MS = 7 * DAY_MS;

export function locationHistoryWindow(
  input: { from?: string; to?: string },
  now = new Date(),
): { from: Date; to: Date } | { error: string } {
  const to = input.to ? new Date(input.to) : now;
  const from = input.from ? new Date(input.from) : new Date(to.getTime() - LOCATION_HISTORY_DEFAULT_MS);
  if (Number.isNaN(from.getTime()) || Number.isNaN(to.getTime()) || from >= to) {
    return { error: 'Invalid location history window' };
  }
  if (to.getTime() - from.getTime() > LOCATION_HISTORY_MAX_MS) {
    return { error: 'Location history window is limited to 7 days' };
  }
  return { from, to };
}
