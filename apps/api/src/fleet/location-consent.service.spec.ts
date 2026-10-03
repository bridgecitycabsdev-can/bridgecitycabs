import { describe, expect, it, vi } from 'vitest';
import { ApiCode } from '../common/api-code.js';
import { ApiException } from '../common/api-exception.js';
import { LOCATION_NOTICE_VERSION } from './location-notice.js';
import { LocationConsentService } from './location-consent.service.js';

describe('LocationConsentService', () => {
  it('writes ConsentRecord for LOCATION_TRACKING and gates shift start', async () => {
    const prisma = {
      driver: {
        findUnique: vi.fn(async () => ({ id: 'driver-1', userId: 'user-1' })),
      },
      driverLocationConsent: {
        upsert: vi.fn(async () => ({
          noticeVersion: LOCATION_NOTICE_VERSION,
          acceptedAt: new Date('2026-10-03T12:00:00Z'),
        })),
      },
      consentRecord: {
        findFirst: vi
          .fn()
          .mockResolvedValueOnce(null)
          .mockResolvedValueOnce({ id: 'consent-1' }),
        create: vi.fn(async () => ({
          type: 'LOCATION_TRACKING',
          version: LOCATION_NOTICE_VERSION,
          acceptedAt: new Date('2026-10-03T12:00:00Z'),
        })),
      },
    };
    const service = new LocationConsentService(prisma as never);

    await expect(
      service.acceptTyped(
        { userId: 'user-1', role: 'driver', branchId: 'branch-1' },
        { type: 'LOCATION_TRACKING', version: LOCATION_NOTICE_VERSION },
      ),
    ).resolves.toMatchObject({
      type: 'LOCATION_TRACKING',
      version: LOCATION_NOTICE_VERSION,
    });
    expect(prisma.consentRecord.create).toHaveBeenCalled();

    const tx = {
      driver: { findUnique: vi.fn(async () => ({ userId: 'user-1' })) },
      consentRecord: {
        findFirst: vi.fn(async () => null),
      },
    };
    await expect(service.assertAccepted(tx as never, 'driver-1')).rejects.toBeInstanceOf(
      ApiException,
    );
    try {
      await service.assertAccepted(tx as never, 'driver-1');
    } catch (error) {
      expect(error).toBeInstanceOf(ApiException);
      const body = (error as ApiException).getResponse() as { code: string };
      expect(body.code).toBe(ApiCode.CONSENT_REQUIRED);
    }
  });
});
