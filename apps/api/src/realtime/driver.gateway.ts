import { Logger } from '@nestjs/common';
import {
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
  MessageBody,
  OnGatewayInit,
  SubscribeMessage,
  WebSocketGateway,
} from '@nestjs/websockets';
import { SOCKET_EVENTS, driverLocationSchema, offerReceivedSchema } from '@bridgecabs/shared-types';
import type { Namespace, Socket } from 'socket.io';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { watchAccessToken } from './access-token-watch.js';
import { DriverPublisher } from './driver-publisher.js';
import { FleetBroadcaster } from './fleet-broadcaster.js';
import { evaluateLocationPing, freshBucket } from './location-guard.js';
import { NotificationListener } from './notification.listener.js';
import { driverRoom, userRoom } from './rooms.js';
import { admitSocket, guardSocketEvents } from './socket-guard.js';
import { SocketAuth } from './socket-auth.js';
import { SocketLimits } from './socket-limits.js';
import { OfferAckWaiter } from './offer-ack.waiter.js';
import { PassengerLocationRelay } from './passenger-location.relay.js';

const DRIVER_ROLES = ['driver'] as const;

@WebSocketGateway({ namespace: '/driver' })
export class DriverGateway implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
  private readonly logger = new Logger(DriverGateway.name);
  private namespace?: Namespace;

  constructor(
    private readonly auth: SocketAuth,
    private readonly fleet: FleetStateService,
    private readonly broadcaster: FleetBroadcaster,
    private readonly publisher: DriverPublisher,
    private readonly limits: SocketLimits,
    private readonly acks: OfferAckWaiter,
    private readonly locations: PassengerLocationRelay,
    private readonly notifications: NotificationListener,
  ) {}

  afterInit(server: Namespace) {
    this.namespace = server;
    this.publisher.bind(server);
    this.notifications.bind(server);
    server.use(this.auth.middleware(DRIVER_ROLES));
    guardSocketEvents(server, this.limits);
  }

  handleConnection(socket: Socket) {
    void this.connected(socket);
  }

  handleDisconnect() {
    // Presence TTL and the sweeper decide what happens next.
  }

  @SubscribeMessage(SOCKET_EVENTS.driverLocation)
  async location(@MessageBody() payload: unknown, @ConnectedSocket() socket: Socket) {
    const driverId = socket.data.driverId;
    if (!driverId) return;
    const parsed = driverLocationSchema.safeParse(payload);
    if (!parsed.success) return;

    const nowMs = Date.now();
    socket.data.bucket ??= freshBucket(nowMs);
    const decision = evaluateLocationPing({
      payload: parsed.data,
      nowMs,
      bucket: socket.data.bucket,
      lastPoint: socket.data.lastPoint,
    });
    if (!decision.accept) return;
    socket.data.lastPoint = decision.point;

    const branchId = await this.fleet.recordDriverPing(driverId, {
      lng: decision.point.lng,
      lat: decision.point.lat,
      heading: parsed.data.heading,
      speedMps: parsed.data.speedMps,
      accuracyM: parsed.data.accuracyM,
      recordedAt: decision.recordedAt,
      receivedAtMs: decision.point.receivedAtMs,
    });
    if (!branchId) return;
    this.broadcaster.mark(branchId, driverId);
    void this.locations.onPing(driverId);
  }

  @SubscribeMessage(SOCKET_EVENTS.offerReceived)
  received(@MessageBody() payload: unknown, @ConnectedSocket() socket: Socket) {
    const driverId = socket.data.driverId;
    if (!driverId) return;
    const parsed = offerReceivedSchema.safeParse(payload);
    if (!parsed.success) return;
    this.acks.receive(driverId, parsed.data.offerId);
  }

  private async connected(socket: Socket) {
    const user = socket.data.user;
    if (!user) {
      socket.disconnect(true);
      return;
    }
    if (!(await admitSocket(socket, this.limits, this.logger))) return;
    try {
      const driverId = await this.fleet.driverIdForUser(user.userId);
      if (!driverId) {
        socket.disconnect(true);
        return;
      }
      socket.data.driverId = driverId;
      socket.data.bucket = freshBucket(Date.now());
      const previous = await this.fleet.claimDriverSession(driverId, socket.id);
      if (previous && this.namespace) {
        const at = new Date().toISOString();
        const local = this.namespace.sockets.get(previous);
        if (local) {
          local.emit(SOCKET_EVENTS.sessionReplaced, { at });
          local.disconnect(true);
        } else {
          this.namespace.to(previous).emit(SOCKET_EVENTS.sessionReplaced, { at });
          this.namespace.in(previous).disconnectSockets(true);
        }
      }
      await socket.join(driverRoom(driverId));
      await socket.join(userRoom(user.userId));
      socket.emit(
        SOCKET_EVENTS.driverState,
        await this.fleet.state({
          userId: user.userId,
          role: user.role,
          branchId: user.branchId,
        }),
      );
      watchAccessToken(socket, (token) => this.auth.authenticate(token, DRIVER_ROLES));
    } catch {
      this.logger.log(`closed socket=${socket.id} user=${user.userId}`);
      socket.disconnect(true);
    }
  }
}
