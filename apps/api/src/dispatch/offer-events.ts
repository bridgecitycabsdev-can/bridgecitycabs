import type { OfferOutcome } from '@bridgecabs/shared-types';

export const OFFER_OPENED = 'offer.opened';
export const OFFER_RESOLVED = 'offer.resolved';

export type OfferOpenedEvent = {
  offerId: string;
  bookingId: string;
  driverId: string;
  branchId: string;
  expiresAt: string;
};

export type OfferResolvedEvent = {
  offerId: string;
  bookingId: string;
  driverId: string;
  branchId: string;
  outcome: OfferOutcome;
};
