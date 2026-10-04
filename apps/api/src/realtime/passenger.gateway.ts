import { Logger } from '@nestjs/common';
import { OnGatewayConnection, OnGatewayInit, WebSocketGateway } from '@nestjs/websockets';
import type { Namespace, Socket } from 'socket.io';
import { PassengerBookingsService } from '../passengers/passenger-bookings.service.js';
import { watchAccessToken } from './access-token-watch.js';
import { PassengerPublisher } from './passenger-publisher.js';
import { NotificationListener } from './notification.listener.js';
import { passengerRoom, userRoom } from './rooms.js';
import { admitSocket, guardSocketEvents } from './socket-guard.js';
import { SocketAuth } from './socket-auth.js';
import { SocketLimits } from './socket-limits.js';

const PASSENGER_ROLES = ['passenger'] as const;

@WebSocketGateway({ namespace: '/passenger' })
export class PassengerGateway implements OnGatewayInit, OnGatewayConnection {
  private readonly logger = new Logger(PassengerGateway.name);

  constructor(
    private readonly auth: SocketAuth,
    private readonly publisher: PassengerPublisher,
    private readonly limits: SocketLimits,
    private readonly bookings: PassengerBookingsService,
    private readonly notifications: NotificationListener,
  ) {}

  afterInit(server: Namespace) {
    this.publisher.bind(server);
    this.notifications.bind(server);
    server.use(this.auth.middleware(PASSENGER_ROLES));
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
    await socket.join(passengerRoom(user.userId));
    await socket.join(userRoom(user.userId));
    watchAccessToken(socket, (token) => this.auth.authenticate(token, PASSENGER_ROLES));
    try {
      const snapshot = await this.bookings.activeForUser(user.userId);
      if (snapshot) this.publisher.emitBooking(user.userId, snapshot);
    } catch (error) {
      this.logger.warn(
        `Active booking was not sent to ${user.userId}: ${
          error instanceof Error ? error.message : 'unknown error'
        }`,
      );
    }
  }
}
