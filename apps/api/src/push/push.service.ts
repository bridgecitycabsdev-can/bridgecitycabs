import { Inject, Injectable, Logger } from '@nestjs/common';
import type { OfferPush } from '@bridgecabs/shared-types';
import { PrismaService } from '../prisma/prisma.service.js';
import { PUSH_PROVIDER, type PushMessage, type PushProvider } from './push-provider.js';

export const OFFER_PUSH_TITLE = 'New ride request';
export const OFFER_PUSH_BODY = 'Open the app to respond';

/** Notification + data for a killed driver app. TTL matches offer remaining time. */
export function offerNotification(payload: OfferPush): PushMessage {
  const expiresAtMs = Date.parse(payload.expiresAt);
  return {
    title: OFFER_PUSH_TITLE,
    body: OFFER_PUSH_BODY,
    data: {
      type: payload.type,
      offerId: payload.offerId,
      expiresAt: payload.expiresAt,
    },
    highPriority: true,
    timeSensitive: true,
    androidChannelId: 'offers',
    collapseKey: payload.offerId,
    expiresAtMs: Number.isFinite(expiresAtMs) ? expiresAtMs : undefined,
  };
}

@Injectable()
export class PushService {
  private readonly logger = new Logger(PushService.name);

  constructor(
    private readonly prisma: PrismaService,
    @Inject(PUSH_PROVIDER) private readonly provider: PushProvider,
  ) {}

  async sendToUser(userId: string, message: PushMessage) {
    const targets = await this.prisma.deviceToken.findMany({
      where: { userId, revokedAt: null },
      select: { token: true, platform: true },
    });
    if (!targets.length) return;
    try {
      const invalid = await this.provider.send(targets, message);
      if (!invalid.length) return;
      // Soft-revoke: FCM said unregistered / invalid.
      await this.prisma.deviceToken.updateMany({
        where: { token: { in: invalid }, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    } catch (error) {
      this.logger.warn(
        `Push "${message.title}" failed: ${error instanceof Error ? error.message : 'unknown error'}`,
      );
    }
  }

  sendOffer(userId: string, payload: OfferPush) {
    return this.sendToUser(userId, offerNotification(payload));
  }
}
