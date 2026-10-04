import { Logger } from '@nestjs/common';
import {
  ConnectedSocket,
  MessageBody,
  OnGatewayConnection,
  OnGatewayInit,
  SubscribeMessage,
  WebSocketGateway,
} from '@nestjs/websockets';
import { SOCKET_EVENTS, fleetSubscribeSchema } from '@bridgecabs/shared-types';
import type { Namespace, Socket } from 'socket.io';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { watchAccessToken } from './access-token-watch.js';
import { FleetBroadcaster } from './fleet-broadcaster.js';
import { NotificationListener } from './notification.listener.js';
import { branchRoom, userRoom } from './rooms.js';
import { assertBroadcastSafe } from './broadcast-privacy.js';
import { admitSocket, guardSocketEvents } from './socket-guard.js';
import { SocketAuth } from './socket-auth.js';
import { SocketLimits } from './socket-limits.js';
import { SosListener } from './sos.listener.js';

const DISPATCH_ROLES = [
  'super_admin',
  'branch_admin',
  'dispatcher',
  'customer_care',
] as const;

@WebSocketGateway({ namespace: '/dispatch' })
export class DispatchGateway implements OnGatewayInit, OnGatewayConnection {
  private readonly logger = new Logger(DispatchGateway.name);

  constructor(
    private readonly auth: SocketAuth,
    private readonly fleet: FleetStateService,
    private readonly broadcaster: FleetBroadcaster,
    private readonly prisma: PrismaService,
    private readonly limits: SocketLimits,
    private readonly notifications: NotificationListener,
    private readonly sos: SosListener,
  ) {}

  afterInit(server: Namespace) {
    server.use(this.auth.middleware(DISPATCH_ROLES));
    this.broadcaster.bind(server);
    this.notifications.bind(server);
    this.sos.bind(server);
    guardSocketEvents(server, this.limits);
  }

  handleConnection(socket: Socket) {
    void this.connected(socket);
  }

  private async connected(socket: Socket) {
    const user = socket.data.user;
    if (!user) {
      socket.disconnect(true);
      return;
    }
    if (!(await admitSocket(socket, this.limits, this.logger))) return;
    await socket.join(userRoom(user.userId));
    watchAccessToken(socket, (token) => this.auth.authenticate(token, DISPATCH_ROLES));
    if (user.role === 'super_admin' || !user.branchId) return;
    void this.joinBranch(socket, user.branchId);
  }

  @SubscribeMessage(SOCKET_EVENTS.fleetSubscribe)
  async subscribe(@ConnectedSocket() socket: Socket, @MessageBody() body: unknown) {
    if (socket.data.user?.role !== 'super_admin') return { error: 'FORBIDDEN' };
    const parsed = fleetSubscribeSchema.safeParse(body);
    if (!parsed.success) return { error: 'INVALID' };
    const branch = await this.prisma.branch.findUnique({
      where: { id: parsed.data.branchId },
      select: { id: true },
    });
    if (!branch) return { error: 'NOT_FOUND' };
    await this.joinBranch(socket, branch.id);
    return { ok: true };
  }

  private async joinBranch(socket: Socket, branchId: string) {
    const next = branchRoom(branchId);
    const previous = [...socket.rooms].filter((room) => room.startsWith('branch:') && room !== next);
    for (const room of previous) await socket.leave(room);
    await socket.join(next);
    const payload = {
      branchId,
      drivers: await this.fleet.fleetDrivers(branchId),
    };
    assertBroadcastSafe(payload);
    socket.emit(SOCKET_EVENTS.fleetSnapshot, payload);
  }
}
