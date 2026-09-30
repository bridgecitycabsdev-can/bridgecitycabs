const CONTACT_KEYS = new Set([
  'passengerphone',
  'passengeremail',
  'phone',
  'email',
  'passengernumber',
]);

/** Room payloads must not carry a passenger phone number or email. */
export function broadcastHasPassengerContact(value: unknown): boolean {
  if (!value || typeof value !== 'object') return false;
  if (Array.isArray(value)) return value.some((item) => broadcastHasPassengerContact(item));
  for (const [key, nested] of Object.entries(value)) {
    if (CONTACT_KEYS.has(key.toLowerCase())) return true;
    if (broadcastHasPassengerContact(nested)) return true;
  }
  return false;
}

export function assertBroadcastSafe(value: unknown) {
  if (broadcastHasPassengerContact(value)) {
    throw new Error('Broadcast includes passenger contact');
  }
}
