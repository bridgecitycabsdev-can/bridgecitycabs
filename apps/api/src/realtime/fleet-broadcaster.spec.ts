import { SOCKET_EVENTS } from '@bridgecabs/shared-types';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { FleetBroadcaster, FLEET_FLUSH_MS } from './fleet-broadcaster.js';

describe('fleet broadcaster', () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  it('coalesces dirty drivers into one batch per branch', async () => {
    vi.useFakeTimers();
    const drivers = [
      {
        id: '11111111-1111-4111-8111-111111111111',
        v: 1,
        status: 'AVAILABLE' as const,
        lat: 49.6935,
        lng: -112.8418,
        heading: null,
        speedMps: null,
        accuracyM: 8,
        ts: 1,
        name: 'Priya Nair',
        unit: '111',
        vehicleType: 'SUV',
        bookingId: null,
        stale: false,
      },
    ];
    const emit = vi.fn();
    const fleet = {
      fleetDrivers: vi.fn(async () => drivers),
    };
    const broadcaster = new FleetBroadcaster(fleet as never);
    broadcaster.bind({
      to: () => ({ emit }),
    } as never);

    broadcaster.mark('22222222-2222-4222-8222-222222222222', drivers[0].id);
    broadcaster.mark('22222222-2222-4222-8222-222222222222', drivers[0].id);
    expect(emit).not.toHaveBeenCalled();

    await vi.advanceTimersByTimeAsync(FLEET_FLUSH_MS);
    expect(fleet.fleetDrivers).toHaveBeenCalledTimes(1);
    expect(emit).toHaveBeenCalledWith(SOCKET_EVENTS.fleetDriverUpdated, {
      branchId: '22222222-2222-4222-8222-222222222222',
      drivers,
    });
    broadcaster.onModuleDestroy();
  });
});
