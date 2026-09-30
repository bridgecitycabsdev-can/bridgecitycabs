import { Injectable, NotFoundException, UnprocessableEntityException } from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import type { AuthUser } from '../common/auth-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { LOCATION_NOTICE, LOCATION_NOTICE_VERSION } from './location-notice.js';

@Injectable()
export class LocationConsentService {
  constructor(private readonly prisma: PrismaService) {}

  notice() {
    return { version: LOCATION_NOTICE_VERSION, text: LOCATION_NOTICE };
  }

  async accept(user: AuthUser, version: string) {
    if (version !== LOCATION_NOTICE_VERSION) {
      throw new UnprocessableEntityException('Location notice version is out of date');
    }
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
      select: { id: true },
    });
    if (!driver) throw new NotFoundException();
    const consent = await this.prisma.driverLocationConsent.upsert({
      where: {
        driverId_noticeVersion: { driverId: driver.id, noticeVersion: version },
      },
      create: { driverId: driver.id, noticeVersion: version },
      update: {},
    });
    return { version: consent.noticeVersion, acceptedAt: consent.acceptedAt.toISOString() };
  }

  async assertAccepted(tx: Prisma.TransactionClient, driverId: string) {
    const consent = await tx.driverLocationConsent.findUnique({
      where: {
        driverId_noticeVersion: {
          driverId,
          noticeVersion: LOCATION_NOTICE_VERSION,
        },
      },
      select: { id: true },
    });
    if (!consent) {
      throw new UnprocessableEntityException({
        message: 'Location agreement required',
        version: LOCATION_NOTICE_VERSION,
        notice: LOCATION_NOTICE,
      });
    }
  }
}
