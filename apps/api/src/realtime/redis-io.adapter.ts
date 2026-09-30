import type { Server as HttpServer } from 'node:http';
import { ConfigService } from '@nestjs/config';
import { IoAdapter } from '@nestjs/platform-socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import type { Redis } from 'ioredis';
import { allowedWsOrigins } from './allowed-origins.js';

export const REALTIME_SERVER_OPTIONS = {
  transports: ['websocket'],
  pingInterval: 10_000,
  pingTimeout: 10_000,
  maxHttpBufferSize: 1e5,
} as const;

export class RedisIoAdapter extends IoAdapter {
  constructor(
    httpServer: HttpServer,
    private readonly pub: Redis,
    private readonly sub: Redis,
    private readonly config: ConfigService,
  ) {
    super(httpServer);
  }

  createIOServer(
    port: number,
    options?: Parameters<IoAdapter['createIOServer']>[1],
  ): any {
    const origins = allowedWsOrigins(this.config.get<string>('WS_ALLOWED_ORIGINS'));
    const server = super.createIOServer(port, {
      ...options,
      transports: ['websocket'],
      pingInterval: REALTIME_SERVER_OPTIONS.pingInterval,
      pingTimeout: REALTIME_SERVER_OPTIONS.pingTimeout,
      maxHttpBufferSize: REALTIME_SERVER_OPTIONS.maxHttpBufferSize,
      cors: { origin: origins },
    } as unknown as Parameters<IoAdapter['createIOServer']>[1]);
    server.adapter(createAdapter(this.pub, this.sub));
    return server;
  }
}
