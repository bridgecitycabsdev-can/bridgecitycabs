import { Injectable } from '@nestjs/common';
import {
  SOCKET_EVENTS,
  type DriverStateSnapshot,
  type OfferEnded,
  type OfferNew,
} from '@bridgecabs/shared-types';
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

  emitOffer(event: typeof SOCKET_EVENTS.offerNew, driverId: string, payload: OfferNew): void;
  emitOffer(
    event: typeof SOCKET_EVENTS.offerCancelled | typeof SOCKET_EVENTS.offerExpired,
    driverId: string,
    payload: OfferEnded,
  ): void;
  emitOffer(event: string, driverId: string, payload: OfferNew | OfferEnded) {
    assertBroadcastSafe(payload);
    this.namespace?.to(driverRoom(driverId)).emit(event, payload);
  }
}
