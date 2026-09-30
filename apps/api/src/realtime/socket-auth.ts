import { Injectable } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import type { Socket } from 'socket.io';
import { PrismaService } from '../prisma/prisma.service.js';
import { accessTokenFromHandshake } from './handshake-token.js';
import type { LocationSample, TokenBucket } from './location-guard.js';

export type SocketUser = {
  userId: string;
  role: string;
  branchId: string | null;
  exp: number;
};

type AccessPayload = {
  sub?: string;
  role?: string;
  branchId?: string | null;
  exp?: number;
};

declare module 'socket.io' {
  interface SocketData {
    user?: SocketUser;
    driverId?: string;
    bucket?: TokenBucket;
    lastPoint?: LocationSample;
  }
}

@Injectable()
export class SocketAuth {
  constructor(
    private readonly jwt: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  middleware(allowedRoles: readonly string[]) {
    return async (socket: Socket, next: (error?: Error) => void) => {
      try {
        const token = accessTokenFromHandshake(socket.handshake);
        if (!token) return next(new Error('UNAUTHENTICATED'));
        socket.data.user = await this.authenticate(token, allowedRoles);
        next();
      } catch (error) {
        if (error instanceof Error && error.message === 'FORBIDDEN') {
          return next(error);
        }
        next(new Error('UNAUTHENTICATED'));
      }
    };
  }

  async authenticate(token: string, allowedRoles: readonly string[]) {
    const payload = await this.jwt.verifyAsync<AccessPayload>(token);
    if (!payload.sub || !payload.role || payload.exp == null) {
      throw new Error('UNAUTHENTICATED');
    }
    if (!allowedRoles.includes(payload.role)) throw new Error('FORBIDDEN');
    if (!(await this.isActive(payload.sub))) throw new Error('UNAUTHENTICATED');
    return {
      userId: payload.sub,
      role: payload.role,
      branchId: payload.branchId ?? null,
      exp: payload.exp,
    } satisfies SocketUser;
  }

  async isActive(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { isActive: true },
    });
    return user?.isActive === true;
  }
}
