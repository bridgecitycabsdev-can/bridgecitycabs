export function driverRoom(driverId: string) {
  return `driver:${driverId}`;
}

export function branchRoom(branchId: string) {
  return `branch:${branchId}`;
}

export function passengerRoom(userId: string) {
  return `passenger:${userId}`;
}

/** Cross-namespace room for generic in-app notifications (any authenticated role). */
export function userRoom(userId: string) {
  return `user:${userId}`;
}
