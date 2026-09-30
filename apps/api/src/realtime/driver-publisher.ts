import { Injectable } from '@nestjs/common';
import { SOCKET_EVENTS, type DriverStateSnapshot } from '@bridgecabs/shared-types';
import type { Namespace } from 'socket.io';
import { assertBroadcastSafe } from './broadcast-privacy.js';
import { driverRoom } from './rooms.js';

@Injectable()
export class DriverPublisher {
  private namespace?: Namespace;

  bind(server: Namespace) {
    this.namespace = server;
  }

  emitState(driverId: string, snapshot: DriverStateSnapshot) {
    assertBroadcastSafe(snapshot);
    this.namespace?.to(driverRoom(driverId)).emit(SOCKET_EVENTS.driverState, snapshot);
  }
}
