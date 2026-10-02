import {
  FLEET_CHIPS,
  fleetChipForStatus,
  type DriverPresenceState,
  type FleetChip,
} from '@bridgecabs/shared-types';

export { FLEET_CHIPS, fleetChipForStatus };
export type { FleetChip };

export function emptyFleetCounts(): Record<FleetChip, number> {
  return { ALL: 0, BUSY: 0, FREE: 0, ASSIGN: 0, WAIT: 0, AWAY: 0 };
}

export function countFleetChips(statuses: readonly DriverPresenceState[]) {
  const counts = emptyFleetCounts();
  for (const status of statuses) {
    const chip = fleetChipForStatus(status);
    if (!chip) continue;
    counts.ALL += 1;
    counts[chip] += 1;
  }
  return counts;
}
