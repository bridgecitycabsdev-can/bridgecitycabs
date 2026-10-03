import {
  HttpStatus,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import type { Prisma } from '@prisma/client';
import { ApiCode } from '../common/api-code.js';
import { ApiException } from '../common/api-exception.js';
import type { AuthUser } from '../common/auth-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { LOCATION_TRACKING_CONSENT } from './dto/driver-consent.dto.js';
import { LOCATION_NOTICE, LOCATION_NOTICE_VERSION } from './location-notice.js';

@Injectable()
export class LocationConsentService {
  constructor(private readonly prisma: PrismaService) {}

  notice() {
    return { version: LOCATION_NOTICE_VERSION, text: LOCATION_NOTICE };
  }

  /** Legacy notice accept — also writes ConsentRecord for shift/start. */
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
    await this.writeConsentRecord(user.userId, LOCATION_TRACKING_CONSENT, version);
    return { version: consent.noticeVersion, acceptedAt: consent.acceptedAt.toISOString() };
  }

  /** POST /driver/consents — app-agnostic ConsentRecord (LOCATION_TRACKING). */
  async acceptTyped(
    user: AuthUser,
    input: { type: typeof LOCATION_TRACKING_CONSENT; version: string; appVersion?: string },
  ) {
    if (input.version !== LOCATION_NOTICE_VERSION) {
      throw new UnprocessableEntityException('Location consent version is out of date');
    }
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
      select: { id: true },
    });
    if (!driver) throw new NotFoundException();
    await this.prisma.driverLocationConsent.upsert({
      where: {
        driverId_noticeVersion: {
          driverId: driver.id,
          noticeVersion: input.version,
        },
      },
      create: { driverId: driver.id, noticeVersion: input.version },
      update: {},
    });
    const row = await this.writeConsentRecord(
      user.userId,
      input.type,
      input.version,
      input.appVersion,
    );
    return {
      type: row.type,
      version: row.version,
      acceptedAt: row.acceptedAt.toISOString(),
    };
  }

  async assertAccepted(tx: Prisma.TransactionClient, driverId: string) {
    const driver = await tx.driver.findUnique({
      where: { id: driverId },
      select: { userId: true },
    });
    if (!driver) throw new NotFoundException();
    const consent = await tx.consentRecord.findFirst({
      where: {
        userId: driver.userId,
        type: LOCATION_TRACKING_CONSENT,
        version: LOCATION_NOTICE_VERSION,
      },
      select: { id: true },
    });
    if (!consent) {
      throw new ApiException(
        HttpStatus.UNPROCESSABLE_ENTITY,
        ApiCode.CONSENT_REQUIRED,
        'Location tracking consent required',
        { type: LOCATION_TRACKING_CONSENT, version: LOCATION_NOTICE_VERSION },
      );
    }
  }

  private async writeConsentRecord(
    userId: string,
    type: string,
    version: string,
    appVersion?: string,
  ) {
    const existing = await this.prisma.consentRecord.findFirst({
      where: { userId, type, version },
    });
    if (existing) return existing;
    return this.prisma.consentRecord.create({
      data: {
        userId,
        type,
        version,
        appVersion: appVersion ?? null,
      },
    });
  }
}
