import { describe, expect, it, vi } from 'vitest';
import { FleetStateService } from './fleet-state.service.js';

describe('FleetStateService.recordLocationBatch', () => {
  it('applies only the newest accepted point to Redis presence', async () => {
    const updateLocation = vi.fn(async () => 1);
    const bufferHistorySample = vi.fn(async () => undefined);
    const service = Object.create(FleetStateService.prototype) as FleetStateService & {
      driverForUser: (userId: string) => Promise<{ id: string }>;
      updateLocation: typeof updateLocation;
      bufferHistorySample: typeof bufferHistorySample;
    };
    service.driverForUser = vi.fn(async () => ({ id: 'driver-1' }));
    service.updateLocation = updateLocation;
    service.bufferHistorySample = bufferHistorySample;

    const nowMs = Date.parse('2026-10-03T12:00:00.000Z');
    vi.spyOn(Date, 'now').mockReturnValue(nowMs);

    const result = await service.recordLocationBatch(
      { userId: 'user-1', role: 'driver', branchId: 'branch-1' },
      [
        {
          lat: 49.6939,
          lng: -112.8419,
          accuracy: 8,
          recordedAt: '2026-10-03T11:59:50.000Z',
        },
        {
          lat: 49.694,
          lng: -112.8418,
          accuracy: 8,
          recordedAt: '2026-10-03T11:59:55.000Z',
        },
      ],
    );

    expect(result.applied).toBe(true);
    expect(result.accepted).toBeGreaterThanOrEqual(1);
    expect(updateLocation).toHaveBeenCalledTimes(1);
    const applied = updateLocation.mock.calls[0]![1] as {
      lat: number;
      lng: number;
    };
    expect(applied.lat).toBeCloseTo(49.694);
    expect(applied.lng).toBeCloseTo(-112.8418);
  });
});
