import type { DriverPresenceState } from '@bridgecabs/shared-types';

/** Legacy dispatch chips. This mapping was not checked against the old product. */
export const FLEET_CHIPS = ['ALL', 'BUSY', 'FREE', 'ASSIGN', 'WAIT', 'AWAY'] as const;

export type FleetChip = (typeof FLEET_CHIPS)[number];

const CHIP_BY_STATUS: Partial<Record<DriverPresenceState, Exclude<FleetChip, 'ALL'>>> = {
  AVAILABLE: 'FREE',
  OFFERED: 'ASSIGN',
  ASSIGNED: 'ASSIGN',
  EN_ROUTE_PICKUP: 'ASSIGN',
  ARRIVED: 'WAIT',
  ON_TRIP: 'BUSY',
  AWAY: 'AWAY',
};

export function emptyFleetCounts(): Record<FleetChip, number> {
  return { ALL: 0, BUSY: 0, FREE: 0, ASSIGN: 0, WAIT: 0, AWAY: 0 };
}

export function countFleetChips(statuses: readonly DriverPresenceState[]) {
  const counts = emptyFleetCounts();
  for (const status of statuses) {
    const chip = CHIP_BY_STATUS[status];
    if (!chip) continue;
    counts.ALL += 1;
    counts[chip] += 1;
  }
  return counts;
}
