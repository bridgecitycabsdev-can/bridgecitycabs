import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { OfferPush } from '@bridgecabs/shared-types';
import { PushService } from '../push/push.service.js';

const DEFAULT_ACK_WAIT_MS = 2_000;

type PendingAck = {
  driverId: string;
  userId: string;
  push: OfferPush;
  timer: ReturnType<typeof setTimeout>;
};

/**
 * Foreground apps ack offer:new. Everyone else gets one generic push.
 */
@Injectable()
export class OfferAckWaiter implements OnModuleDestroy {
  private readonly pending = new Map<string, PendingAck>();

  constructor(
    private readonly config: ConfigService,
    private readonly push: PushService,
  ) {}

  arm(input: { driverId: string; userId: string; push: OfferPush }) {
    this.disarm(input.push.offerId);
    const timer = setTimeout(() => {
      const pending = this.pending.get(input.push.offerId);
      this.pending.delete(input.push.offerId);
      if (!pending) return;
      void this.push.sendOffer(pending.userId, pending.push);
    }, this.waitMs());
    this.pending.set(input.push.offerId, {
      driverId: input.driverId,
      userId: input.userId,
      push: input.push,
      timer,
    });
  }

  receive(driverId: string, offerId: string) {
    const pending = this.pending.get(offerId);
    if (!pending || pending.driverId !== driverId) return false;
    this.disarm(offerId);
    return true;
  }

  disarm(offerId: string) {
    const pending = this.pending.get(offerId);
    if (!pending) return;
    clearTimeout(pending.timer);
    this.pending.delete(offerId);
  }

  onModuleDestroy() {
    for (const offerId of [...this.pending.keys()]) this.disarm(offerId);
  }

  private waitMs() {
    const raw = this.config.get<string | number>('PUSH_ACK_WAIT_MS');
    if (raw === undefined || raw === '') return DEFAULT_ACK_WAIT_MS;
    const value = typeof raw === 'number' ? raw : Number(raw);
    if (!Number.isFinite(value) || value < 0) return DEFAULT_ACK_WAIT_MS;
    return Math.floor(value);
  }
}
