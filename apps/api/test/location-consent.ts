import { LOCATION_TRACKING_CONSENT } from '../src/fleet/dto/driver-consent.dto.js';
import { LOCATION_NOTICE_VERSION } from '../src/fleet/location-notice.js';

type ConsentDb = {
  driver: {
    findUnique(args: {
      where: { id: string };
      select: { userId: true };
    }): Promise<{ userId: string } | null>;
  };
  driverLocationConsent: {
    upsert(args: {
      where: { driverId_noticeVersion: { driverId: string; noticeVersion: string } };
      create: { driverId: string; noticeVersion: string };
      update: Record<string, never>;
    }): Promise<unknown>;
  };
  consentRecord: {
    findFirst(args: {
      where: { userId: string; type: string; version: string };
    }): Promise<{ id: string } | null>;
    create(args: {
      data: { userId: string; type: string; version: string };
    }): Promise<unknown>;
  };
};

/** Seeds both DriverLocationConsent and ConsentRecord for e2e shift/start. */
export async function grantLocationConsent(db: ConsentDb, driverId: string) {
  await db.driverLocationConsent.upsert({
    where: {
      driverId_noticeVersion: { driverId, noticeVersion: LOCATION_NOTICE_VERSION },
    },
    create: { driverId, noticeVersion: LOCATION_NOTICE_VERSION },
    update: {},
  });
  const driver = await db.driver.findUnique({
    where: { id: driverId },
    select: { userId: true },
  });
  if (!driver) return;
  const existing = await db.consentRecord.findFirst({
    where: {
      userId: driver.userId,
      type: LOCATION_TRACKING_CONSENT,
      version: LOCATION_NOTICE_VERSION,
    },
  });
  if (existing) return;
  await db.consentRecord.create({
    data: {
      userId: driver.userId,
      type: LOCATION_TRACKING_CONSENT,
      version: LOCATION_NOTICE_VERSION,
    },
  });
}
