import {
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { describe, expect, it, vi } from 'vitest';
import { ApiCode } from '../common/api-code.js';
import { RatingsService } from './ratings.service.js';

const closedBooking = {
  id: 'b1',
  passengerId: 'pass-1',
  driverId: 'drv-1',
  status: 'CLOSED',
  closedAt: new Date(),
};

describe('RatingsService', () => {
  it('rates a driver and updates the incremental SQL average', async () => {
    const tx = {
      booking: { findUnique: vi.fn(async () => closedBooking) },
      bookingRating: {
        create: vi.fn(async ({ data }) => ({ id: 'r1', ...data })),
      },
      $executeRaw: vi.fn(async () => 1),
    };
    const prisma = {
      $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      bookingRating: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'r1',
          bookingId: 'b1',
          raterType: 'PASSENGER',
          driverId: 'drv-1',
          passengerId: null,
          stars: 5,
          comment: 'Great',
          createdAt: new Date(),
        })),
      },
    };
    const service = new RatingsService(
      prisma as never,
      { get: () => '14' } as never,
    );

    await expect(
      service.rateDriver('b1', 'pass-1', 5, 'Great'),
    ).resolves.toMatchObject({ stars: 5, raterType: 'PASSENGER' });
    expect(tx.bookingRating.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        bookingId: 'b1',
        raterType: 'PASSENGER',
        driverId: 'drv-1',
        stars: 5,
      }),
    });
    expect(tx.$executeRaw).toHaveBeenCalled();
  });

  it('forbids rating another passenger’s booking', async () => {
    const tx = {
      booking: {
        findUnique: vi.fn(async () => ({
          ...closedBooking,
          passengerId: 'other',
        })),
      },
    };
    const service = new RatingsService(
      {
        $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      } as never,
      { get: () => '14' } as never,
    );
    await expect(service.rateDriver('b1', 'pass-1', 4)).rejects.toBeInstanceOf(
      ForbiddenException,
    );
  });

  it('rejects non-CLOSED bookings and expired windows', async () => {
    const openTx = {
      booking: {
        findUnique: vi.fn(async () => ({
          ...closedBooking,
          status: 'TRIP_COMPLETED',
        })),
      },
    };
    const expiredTx = {
      booking: {
        findUnique: vi.fn(async () => ({
          ...closedBooking,
          closedAt: new Date(Date.now() - 20 * 24 * 60 * 60 * 1000),
        })),
      },
    };
    const make = (tx: typeof openTx) =>
      new RatingsService(
        {
          $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
        } as never,
        { get: () => '14' } as never,
      );

    await expect(make(openTx).rateDriver('b1', 'pass-1', 3)).rejects.toMatchObject(
      { response: { code: ApiCode.BOOKING_NOT_CLOSED } },
    );
    await expect(
      make(expiredTx).rateDriver('b1', 'pass-1', 3),
    ).rejects.toMatchObject({
      response: { code: ApiCode.RATING_WINDOW_EXPIRED },
    });
  });

  it('maps a unique-constraint collision to ALREADY_RATED', async () => {
    const tx = {
      booking: { findUnique: vi.fn(async () => closedBooking) },
      bookingRating: {
        create: vi.fn(async () => {
          throw new Prisma.PrismaClientKnownRequestError('dup', {
            code: 'P2002',
            clientVersion: 'test',
          });
        }),
      },
    };
    const service = new RatingsService(
      {
        $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      } as never,
      { get: () => '14' } as never,
    );
    await expect(service.rateDriver('b1', 'pass-1', 5)).rejects.toMatchObject({
      response: { code: ApiCode.ALREADY_RATED },
    });
    await expect(service.rateDriver('b1', 'pass-1', 5)).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('rates a passenger from the assigned driver', async () => {
    const tx = {
      booking: { findUnique: vi.fn(async () => closedBooking) },
      bookingRating: {
        create: vi.fn(async ({ data }) => ({ id: 'r2', ...data })),
      },
      $executeRaw: vi.fn(async () => 1),
    };
    const prisma = {
      $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      bookingRating: {
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'r2',
          bookingId: 'b1',
          raterType: 'DRIVER',
          driverId: null,
          passengerId: 'pass-1',
          stars: 4,
          comment: null,
          createdAt: new Date(),
        })),
      },
    };
    const service = new RatingsService(
      prisma as never,
      { get: () => '14' } as never,
    );
    await expect(
      service.ratePassenger('b1', 'drv-1', 4),
    ).resolves.toMatchObject({ raterType: 'DRIVER', stars: 4 });
    expect(tx.bookingRating.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        raterType: 'DRIVER',
        passengerId: 'pass-1',
      }),
    });
  });

  it('lists driver ratings for staff in-branch', async () => {
    const prisma = {
      driver: {
        findUnique: vi.fn(async () => ({
          id: 'drv-1',
          branchId: 'branch-1',
          ratingAvg: 4.5,
          ratingCount: 2,
        })),
      },
      $transaction: vi.fn(async (ops: Promise<unknown>[]) => Promise.all(ops)),
      bookingRating: {
        count: vi.fn(async () => 1),
        findMany: vi.fn(async () => [
          {
            id: 'r1',
            bookingId: 'b1',
            raterType: 'PASSENGER',
            driverId: 'drv-1',
            passengerId: null,
            stars: 5,
            comment: 'Nice',
            createdAt: new Date(),
            booking: {
              id: 'b1',
              trackingId: 'BC-1',
              closedAt: new Date(),
              passengerName: 'Pat',
            },
          },
        ]),
      },
    };
    const service = new RatingsService(
      prisma as never,
      { get: () => '14' } as never,
    );
    const result = await service.listForDriver(
      'drv-1',
      { page: 1, pageSize: 20 },
      { userId: 's1', role: 'branch_admin', branchId: 'branch-1' },
    );
    expect(result.aggregate).toEqual({ ratingAvg: 4.5, ratingCount: 2 });
    expect(result.data).toHaveLength(1);

    await expect(
      service.listForDriver(
        'drv-1',
        { page: 1, pageSize: 20 },
        { userId: 's2', role: 'branch_admin', branchId: 'branch-2' },
      ),
    ).rejects.toBeInstanceOf(NotFoundException);
  });
});
