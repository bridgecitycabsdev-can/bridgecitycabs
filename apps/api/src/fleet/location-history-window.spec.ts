import { describe, expect, it } from 'vitest';
import { locationHistoryWindow } from './location-history-window.js';

describe('location history window', () => {
  const now = new Date('2026-09-30T18:00:00.000Z');

  it('defaults to the last day and rejects a range over a week', () => {
    const window = locationHistoryWindow({}, now);
    expect(window).toEqual({
      from: new Date('2026-09-29T18:00:00.000Z'),
      to: now,
    });
    expect(
      locationHistoryWindow(
        { from: '2026-09-01T00:00:00.000Z', to: '2026-09-30T00:00:00.000Z' },
        now,
      ),
    ).toEqual({ error: 'Location history window is limited to 7 days' });
  });
});