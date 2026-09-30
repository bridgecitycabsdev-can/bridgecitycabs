import { Logger } from '@nestjs/common';
import type { Namespace, Socket } from 'socket.io';
import { socketLogLine } from './handshake-token.js';
import { SocketLimits } from './socket-limits.js';

export function guardSocketEvents(server: Namespace, limits: SocketLimits) {
  server.on('connection', (socket) => {
    const userId = socket.data.user?.userId;
    if (!userId) return;
    socket.use((packet, next) => {
      void limits.allowEvent(userId).then((ok) => {
        if (!ok) return next(new Error('RATE_LIMITED'));
        next();
      });
    });
  });
}

export async function admitSocket(socket: Socket, limits: SocketLimits, logger: Logger) {
  const userId = socket.data.user?.userId;
  if (!userId) {
    socket.disconnect(true);
    return false;
  }
  const allowed = await limits.claim(userId, socket.id);
  if (!allowed) {
    logger.log(socketLogLine('capped', socket.id, userId));
    socket.disconnect(true);
    return false;
  }
  logger.log(socketLogLine('connected', socket.id, userId));
  socket.on('disconnect', () => {
    logger.log(socketLogLine('disconnected', socket.id, userId));
    void limits.release(userId, socket.id);
  });
  return true;
}
