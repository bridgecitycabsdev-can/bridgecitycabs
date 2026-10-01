import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';
import type { RegisterDeviceDto } from './dto/register-device.dto.js';

@Injectable()
export class DevicesService {
  constructor(private readonly prisma: PrismaService) {}

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

  async remove(userId: string, token: string) {
    await this.prisma.deviceToken.deleteMany({ where: { userId, token } });
  }
}
