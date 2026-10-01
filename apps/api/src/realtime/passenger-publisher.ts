import { Injectable } from '@nestjs/common';
import {
  SOCKET_EVENTS,
  passengerBookingSchema,
  passengerDriverLocationSchema,
  type PassengerBooking,
  type PassengerDriverLocation,
  type PassengerTrip,
} from '@bridgecabs/shared-types';
import type { Namespace } from 'socket.io';
import { assertBroadcastSafe } from './broadcast-privacy.js';
import { passengerRoom } from './rooms.js';

@Injectable()
export class PassengerPublisher {
  private namespace?: Namespace;

  bind(server: Namespace) {
    this.namespace = server;
  }

  emitTrip(userId: string, payload: PassengerTrip) {
    assertBroadcastSafe(payload);
    this.namespace?.to(passengerRoom(userId)).emit(SOCKET_EVENTS.tripUpdate, payload);
  }

  emitBooking(userId: string, payload: PassengerBooking) {
    const parsed = passengerBookingSchema.parse(payload);
    assertBroadcastSafe(parsed);
    this.namespace?.to(passengerRoom(userId)).emit(SOCKET_EVENTS.bookingUpdated, parsed);
  }

  /** Latest point for this passenger's booking. Not a subscription anyone else can join. */
  emitLocation(userId: string, payload: PassengerDriverLocation) {
    const parsed = passengerDriverLocationSchema.parse(payload);
    assertBroadcastSafe(parsed);
    this.namespace?.to(passengerRoom(userId)).emit(SOCKET_EVENTS.driverLocation, parsed);
  }
}
