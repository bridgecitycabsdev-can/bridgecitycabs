import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import type { RegisterDeviceDto } from './dto/register-device.dto.js';

@Injectable()
export class DevicesService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Upsert by FCM token. Shared phones / re-logins reassign the token to the
   * caller and clear revokedAt so PushService can use it again.
   */
  async register(userId: string, dto: RegisterDeviceDto) {
    const saved = await this.prisma.deviceToken.upsert({
      where: { token: dto.token },
      create: {
        userId,
        token: dto.token,
        platform: dto.platform,
        appVersion: dto.appVersion ?? null,
      },
      update: {
        userId,
        platform: dto.platform,
        appVersion: dto.appVersion ?? null,
        lastSeenAt: new Date(),
        revokedAt: null,
      },
    });
    return {
      id: saved.id,
      platform: saved.platform,
      appVersion: saved.appVersion,
    };
  }

  /** Soft-revoke so the token is never pushed again until re-registered. */
  async remove(userId: string, token: string) {
    await this.prisma.deviceToken.updateMany({
      where: { userId, token, revokedAt: null },
      data: { revokedAt: new Date() },
    });
  }
}
