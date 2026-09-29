import { createHash, randomBytes } from 'node:crypto';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Prisma } from '@prisma/client';
import argon2 from 'argon2';
import { PrismaService } from '../prisma/prisma.service.js';

type TokenUser = {
  id: string;
  branchId: string | null;
  role: { name: string };
};

const INVALID_CREDENTIALS = 'Invalid credentials';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
  ) {}

  async login(email: string, password: string) {
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: { role: true },
    });
    const ok =
      !!user?.isActive &&
      !!user.passwordHash &&
      (await argon2.verify(user.passwordHash, password));
    if (!ok || !user) {
      throw new UnauthorizedException(INVALID_CREDENTIALS);
    }

    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });
    return this.issueTokens(user);
  }

  async refresh(refreshToken: string) {
    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash: this.hashToken(refreshToken) },
      include: { user: { include: { role: true } } },
    });
    if (!stored) {
      throw new UnauthorizedException(INVALID_CREDENTIALS);
    }

    if (stored.revokedAt) {
      await this.prisma.refreshToken.updateMany({
        where: { userId: stored.userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
      throw new UnauthorizedException(INVALID_CREDENTIALS);
    }

    if (stored.expiresAt.getTime() <= Date.now() || !stored.user.isActive) {
      throw new UnauthorizedException(INVALID_CREDENTIALS);
    }

    await this.prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });
    return this.issueTokens(stored.user);
  }

  async logout(refreshToken: string) {
    await this.prisma.refreshToken.updateMany({
      where: { tokenHash: this.hashToken(refreshToken), revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return { success: true };
  }

  async me(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { role: true, branch: true },
    });
    if (!user?.isActive) {
      throw new UnauthorizedException(INVALID_CREDENTIALS);
    }
    return this.toProfile(user);
  }

  toProfile(
    user: Prisma.UserGetPayload<{ include: { role: true; branch: true } }>,
  ) {
    return {
      id: user.id,
      email: user.email,
      phone: user.phone,
      isActive: user.isActive,
      lastLoginAt: user.lastLoginAt,
      role: { id: user.role.id, name: user.role.name },
      branch: user.branch
        ? {
            id: user.branch.id,
            name: user.branch.name,
            city: user.branch.city,
          }
        : null,
    };
  }

  private async issueTokens(user: TokenUser) {
    const payload = {
      sub: user.id,
      role: user.role.name,
      branchId: user.branchId,
    };
    const accessToken = await this.jwt.signAsync(payload, { expiresIn: '15m' });
    const refreshToken = randomBytes(48).toString('hex');
    await this.prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: this.hashToken(refreshToken),
        expiresAt: this.addDays(new Date(), this.refreshTtlDays()),
      },
    });
    return { accessToken, refreshToken };
  }

  private hashToken(token: string) {
    return createHash('sha256').update(token).digest('hex');
  }

  private refreshTtlDays() {
    const days = Number(this.config.get<string>('JWT_REFRESH_TTL_DAYS') ?? 7);
    return Number.isFinite(days) && days > 0 ? days : 7;
  }

  private addDays(date: Date, days: number) {
    const next = new Date(date);
    next.setUTCDate(next.getUTCDate() + days);
    return next;
  }
}
