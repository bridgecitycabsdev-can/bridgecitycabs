export function shiftSeconds(startedAt: Date, now = new Date()) {
  return Math.max(0, Math.floor((now.getTime() - startedAt.getTime()) / 1000));
}

/** Start and end of the calendar day in a branch timezone, as UTC instants. */
export function branchDayWindow(timeZone: string, now = new Date()) {
  try {
    return windowFor(timeZone, now);
  } catch {
    return windowFor('America/Edmonton', now);
  }
}

/** Previous branch-local calendar day (DST-safe via a midday probe). */
export function previousBranchDayWindow(timeZone: string, now = new Date()) {
  const today = branchDayWindow(timeZone, now);
  const probe = new Date(today.start.getTime() - 12 * 60 * 60 * 1000);
  return branchDayWindow(timeZone, probe);
}

/** Branch-local calendar date `YYYY-MM-DD` → UTC instant of that local midnight. */
export function branchLocalDateStart(timeZone: string, ymd: string) {
  try {
    return zonedMidnight(timeZone, ymd);
  } catch {
    return zonedMidnight('America/Edmonton', ymd);
  }
}

/** Add whole calendar days on a UTC instant (safe when `date` is already a zoned midnight). */
export function addUtcDays(date: Date, days: number) {
  const next = new Date(date);
  next.setUTCDate(next.getUTCDate() + days);
  return next;
}

function windowFor(timeZone: string, now: Date) {
  const ymd = calendarDate(timeZone, now);
  const [year, month, day] = ymd.split('-').map(Number);
  const next = new Date(Date.UTC(year, month - 1, day + 1)).toISOString().slice(0, 10);
  return { start: zonedMidnight(timeZone, ymd), end: zonedMidnight(timeZone, next) };
}

export function calendarDate(timeZone: string, now: Date) {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(now);
}

/** True when both instants fall on the same calendar day in `timeZone`. */
export function isSameLocalDay(a: Date, b: Date, timeZone: string) {
  return calendarDate(timeZone, a) === calendarDate(timeZone, b);
}

function zonedMidnight(timeZone: string, ymd: string) {
  const utcGuess = new Date(`${ymd}T00:00:00.000Z`);
  const start = new Date(utcGuess.getTime() - zoneOffsetMs(timeZone, utcGuess));
  const offsetAtStart = zoneOffsetMs(timeZone, start);
  if (start.getTime() === utcGuess.getTime() - offsetAtStart) return start;
  return new Date(utcGuess.getTime() - offsetAtStart);
}

function zoneOffsetMs(timeZone: string, instant: Date) {
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone,
    hourCycle: 'h23',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
  }).formatToParts(instant);
  const value = (type: Intl.DateTimeFormatPartTypes) =>
    Number(parts.find((part) => part.type === type)?.value);
  const asUtc = Date.UTC(
    value('year'),
    value('month') - 1,
    value('day'),
    value('hour'),
    value('minute'),
    value('second'),
  );
  return asUtc - instant.getTime();
}
