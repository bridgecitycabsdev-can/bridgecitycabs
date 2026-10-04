import { Injectable, Logger } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { SOCKET_EVENTS } from '@bridgecabs/shared-types';
import type { Namespace } from 'socket.io';
import { SOS_TRIGGERED } from '../sos/sos.events.js';
import { assertBroadcastSafe } from './broadcast-privacy.js';
import { branchRoom } from './rooms.js';

type SosAlertRow = {
  id: string;
  branchId: string;
  bookingId: string | null;
  triggeredByType: string;
  triggeredByUserId: string;
  lat: number;
  lng: number;
  status: string;
  createdAt: Date;
};

/** Highest-priority dispatch event: live SOS on the branch room. */
@Injectable()
export class SosListener {
  private readonly logger = new Logger(SosListener.name);
  private server?: Namespace;

  bind(server: Namespace) {
    this.server = server;
  }

  @OnEvent(SOS_TRIGGERED)
  onTriggered(alert: SosAlertRow) {
    try {
      if (!this.server) return;
      const payload = {
        id: alert.id,
        branchId: alert.branchId,
        bookingId: alert.bookingId,
        triggeredByType: alert.triggeredByType,
        triggeredByUserId: alert.triggeredByUserId,
        lat: alert.lat,
        lng: alert.lng,
        status: alert.status,
        createdAt: alert.createdAt.toISOString(),
      };
      assertBroadcastSafe(payload);
      this.server
        .to(branchRoom(alert.branchId))
        .emit(SOCKET_EVENTS.sosTriggered, payload);
    } catch (error) {
      this.logger.warn(
        `SOS socket relay failed: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }
}
