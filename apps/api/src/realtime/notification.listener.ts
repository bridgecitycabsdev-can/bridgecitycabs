import { Injectable, Logger } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { SOCKET_EVENTS } from '@bridgecabs/shared-types';
import type { Namespace } from 'socket.io';
import { NOTIFICATION_CREATED } from '../notifications/notifications.events.js';
import { assertBroadcastSafe } from './broadcast-privacy.js';
import { userRoom } from './rooms.js';

type NotificationRow = {
  id: string;
  userId: string;
  type: string;
  title: string;
  body: string;
  data: unknown;
  readAt: Date | null;
  createdAt: Date;
};

/** Relays notification.created to any live passenger/driver/dispatch socket for that user. */
@Injectable()
export class NotificationListener {
  private readonly logger = new Logger(NotificationListener.name);
  private readonly namespaces = new Set<Namespace>();

  bind(server: Namespace) {
    this.namespaces.add(server);
  }

  @OnEvent(NOTIFICATION_CREATED)
  onCreated(row: NotificationRow) {
    try {
      const payload = {
        id: row.id,
        userId: row.userId,
        type: row.type,
        title: row.title,
        body: row.body,
        data: row.data ?? null,
        readAt: row.readAt?.toISOString() ?? null,
        createdAt: row.createdAt.toISOString(),
      };
      assertBroadcastSafe(payload);
      const room = userRoom(row.userId);
      for (const ns of this.namespaces) {
        ns.to(room).emit(SOCKET_EVENTS.notificationCreated, payload);
      }
    } catch (error) {
      this.logger.warn(
        `Notification socket relay failed: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }
}
