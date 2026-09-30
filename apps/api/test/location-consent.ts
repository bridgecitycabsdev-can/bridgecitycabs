import { LOCATION_NOTICE_VERSION } from '../src/fleet/location-notice.js';

type ConsentDb = {
  driverLocationConsent: {
    upsert(args: {
      where: { driverId_noticeVersion: { driverId: string; noticeVersion: string } };
      create: { driverId: string; noticeVersion: string };
      update: Record<string, never>;
    }): Promise<unknown>;
  };
};

export function grantLocationConsent(db: ConsentDb, driverId: string) {
  return db.driverLocationConsent.upsert({
    where: {
      driverId_noticeVersion: { driverId, noticeVersion: LOCATION_NOTICE_VERSION },
    },
    create: { driverId, noticeVersion: LOCATION_NOTICE_VERSION },
    update: {},
  });
}
