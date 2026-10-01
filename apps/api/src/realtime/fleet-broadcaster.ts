import { Injectable, OnModuleDestroy } from '@nestjs/common';
import {
  SOCKET_EVENTS,
  bookingCreatedSchema,
  bookingStatusChangedSchema,
  offerCreatedSchema,
  offerResolvedSchema,
  type BookingCreated,
  type BookingStatusChanged,
  type FleetDriver,
  type OfferCreated,
  type OfferResolved,
} from '@bridgecabs/shared-types';
import type { Namespace } from 'socket.io';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { assertBroadcastSafe } from './broadcast-privacy.js';
import { branchRoom } from './rooms.js';

/** One dispatch batch per branch, two seconds after the first dirty ping in the window. */
export const FLEET_FLUSH_MS = 2_000;

@Injectable()
export class FleetBroadcaster implements OnModuleDestroy {
  private server?: Namespace;
  private readonly dirty = new Map<string, Set<string>>();
  private readonly timers = new Map<string, ReturnType<typeof setTimeout>>();

  constructor(private readonly fleet: FleetStateService) {}

  bind(server: Namespace) {
    this.server = server;
  }

  emitCreated(branchId: string, payload: BookingCreated) {
    const body = bookingCreatedSchema.parse(payload);
    assertBroadcastSafe(body);
    this.server?.to(branchRoom(branchId)).emit(SOCKET_EVENTS.bookingCreated, body);
  }

  emitBooking(branchId: string, payload: BookingStatusChanged) {
    const body = bookingStatusChangedSchema.parse(payload);
    assertBroadcastSafe(body);
    this.server?.to(branchRoom(branchId)).emit(SOCKET_EVENTS.bookingStatusChanged, body);
  }

  emitOfferCreated(branchId: string, payload: OfferCreated) {
    const body = offerCreatedSchema.parse(payload);
    assertBroadcastSafe(body);
    this.server?.to(branchRoom(branchId)).emit(SOCKET_EVENTS.offerCreated, body);
  }

  emitOfferResolved(branchId: string, payload: OfferResolved) {
    const body = offerResolvedSchema.parse(payload);
    assertBroadcastSafe(body);
    this.server?.to(branchRoom(branchId)).emit(SOCKET_EVENTS.offerResolved, body);
  }

  mark(branchId: string, driverId: string) {
    let ids = this.dirty.get(branchId);
    if (!ids) {
      ids = new Set();
      this.dirty.set(branchId, ids);
      this.timers.set(
        branchId,
        setTimeout(() => void this.flush(branchId), FLEET_FLUSH_MS),
      );
    }
    ids.add(driverId);
  }

  onModuleDestroy() {
    for (const timer of this.timers.values()) clearTimeout(timer);
    this.timers.clear();
    this.dirty.clear();
  }

  private async flush(branchId: string) {
    this.timers.delete(branchId);
    const ids = this.dirty.get(branchId);
    this.dirty.delete(branchId);
    if (!ids?.size || !this.server) return;
    const drivers = await this.fleet.fleetDrivers(branchId, [...ids]);
    if (!drivers.length) return;
    const payload = { branchId, drivers } satisfies { branchId: string; drivers: FleetDriver[] };
    assertBroadcastSafe(payload);
    this.server.to(branchRoom(branchId)).emit(SOCKET_EVENTS.fleetDriverUpdated, payload);
  }
}
