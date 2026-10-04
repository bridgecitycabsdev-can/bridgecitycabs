/**
 * Monday 00:00 in the branch timezone, as a UTC instant.
 * Closing periods and lease weeks share this definition.
 */
export function startOfBranchWeek(timeZone: string, now = new Date()): Date {
  try {
    return mondayStart(timeZone, now);
  } catch {
    return mondayStart('America/Edmonton', now);
  }
}

const WEEKDAYS = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'] as const;

/** Cron for local midnight on LEASE_DEDUCTION_DAY (MON..SUN). Default MON. */
export function leaseDeductionCronPattern(dayEnv?: string | null): string {
  const key = normalizeWeekday(dayEnv, 'MON');
  const cronDow: Record<string, string> = {
    SUN: '0',
    MON: '1',
    TUE: '2',
    WED: '3',
    THU: '4',
    FRI: '5',
    SAT: '6',
  };
  return `0 0 * * ${cronDow[key]}`;
}

/** Cron for local midnight the day after LEASE_DEDUCTION_DAY (weekly close). */
export function weeklyCloseCronPattern(dayEnv?: string | null): string {
  const key = normalizeWeekday(dayEnv, 'MON') as (typeof WEEKDAYS)[number];
  const idx = WEEKDAYS.indexOf(key);
  const next = WEEKDAYS[(idx + 1) % WEEKDAYS.length]!;
  return leaseDeductionCronPattern(next);
}

/** Previous completed branch-local week [weekStart, weekEnd). */
export function previousBranchWeek(timeZone: string, now = new Date()) {
  const thisWeekStart = startOfBranchWeek(timeZone, now);
  const weekStart = startOfBranchWeek(
    timeZone,
    new Date(thisWeekStart.getTime() - 12 * 60 * 60 * 1000),
  );
  return { weekStart, weekEnd: thisWeekStart };
}

function normalizeWeekday(dayEnv: string | null | undefined, fallback: string) {
  const key = (dayEnv ?? fallback).trim().toUpperCase().slice(0, 3);
  return (WEEKDAYS as readonly string[]).includes(key) ? key : fallback;
}

function mondayStart(timeZone: string, now: Date): Date {
  const ymd = calendarDate(timeZone, now);
  const weekday = new Intl.DateTimeFormat('en-US', {
    timeZone,
    weekday: 'short',
  }).format(now);
  const dow: Record<string, number> = {
    Sun: 0,
    Mon: 1,
    Tue: 2,
    Wed: 3,
    Thu: 4,
    Fri: 5,
    Sat: 6,
  };
  const daysFromMonday = ((dow[weekday] ?? 1) + 6) % 7;
  const [year, month, day] = ymd.split('-').map(Number);
  const monday = new Date(Date.UTC(year, month - 1, day - daysFromMonday));
  return zonedMidnight(timeZone, monday.toISOString().slice(0, 10));
}

function calendarDate(timeZone: string, now: Date) {
  return new Intl.DateTimeFormat('en-CA', {
    timeZone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  }).format(now);
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
