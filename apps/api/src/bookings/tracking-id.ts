import { customAlphabet } from 'nanoid';

export const TRACKING_ALPHABET = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';

const suffix = customAlphabet(TRACKING_ALPHABET, 8);

export function newTrackingId() {
  return `BC-${suffix()}`;
}
