import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Prisma } from '@prisma/client';
import { ApiCode } from '../common/api-code.js';
import type { AuthUser } from '../common/auth-user.js';
import { normalizePage, paginate, type PageQuery } from '../common/pagination.js';
import { PrismaService } from '../prisma/prisma.service.js';

function daysSince(date: Date, now = new Date()) {
  return (now.getTime() - date.getTime()) / (1000 * 60 * 60 * 24);
}

@Injectable()
export class RatingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
  ) {}

  async rateDriver(
    bookingId: string,
    passengerId: string,
    stars: number,
    comment?: string,
  ) {
    try {
      await this.prisma.$transaction(async (tx) => {
        const booking = await tx.booking.findUnique({
          where: { id: bookingId },
        });
        if (!booking) throw new NotFoundException();
        if (booking.passengerId !== passengerId) throw new ForbiddenException();
        if (booking.status !== 'CLOSED') {
          throw new ConflictException({ code: ApiCode.BOOKING_NOT_CLOSED });
        }
        if (!booking.closedAt || !booking.driverId) {
          throw new ConflictException({ code: ApiCode.BOOKING_NOT_CLOSED });
        }
        if (daysSince(booking.closedAt) > this.ratingWindowDays()) {
          throw new ConflictException({ code: ApiCode.RATING_WINDOW_EXPIRED });
        }

        await tx.bookingRating.create({
          data: {
            bookingId,
            raterType: 'PASSENGER',
            driverId: booking.driverId,
            stars,
            comment: comment?.trim() || null,
          },
        });

        await tx.$executeRaw`
          UPDATE "Driver" SET
            "ratingAvg" = (("ratingAvg" * "ratingCount") + ${stars}::numeric)
              / ("ratingCount" + 1),
            "ratingCount" = "ratingCount" + 1
          WHERE id = ${booking.driverId}`;
      });
    } catch (error) {
      this.rethrowDuplicate(error);
      throw error;
    }

    return this.getBookingRating(bookingId, 'PASSENGER');
  }

  async ratePassenger(
    bookingId: string,
    driverId: string,
    stars: number,
    comment?: string,
  ) {
    try {
      await this.prisma.$transaction(async (tx) => {
        const booking = await tx.booking.findUnique({
          where: { id: bookingId },
        });
        if (!booking) throw new NotFoundException();
        if (booking.driverId !== driverId) throw new ForbiddenException();
        if (booking.status !== 'CLOSED') {
          throw new ConflictException({ code: ApiCode.BOOKING_NOT_CLOSED });
        }
        if (!booking.closedAt || !booking.passengerId) {
          throw new ConflictException({ code: ApiCode.BOOKING_NOT_CLOSED });
        }
        if (daysSince(booking.closedAt) > this.ratingWindowDays()) {
          throw new ConflictException({ code: ApiCode.RATING_WINDOW_EXPIRED });
        }

        await tx.bookingRating.create({
          data: {
            bookingId,
            raterType: 'DRIVER',
            passengerId: booking.passengerId,
            stars,
            comment: comment?.trim() || null,
          },
        });

        await tx.$executeRaw`
          UPDATE "Passenger" SET
            "ratingAvg" = (("ratingAvg" * "ratingCount") + ${stars}::numeric)
              / ("ratingCount" + 1),
            "ratingCount" = "ratingCount" + 1
          WHERE id = ${booking.passengerId}`;
      });
    } catch (error) {
      this.rethrowDuplicate(error);
      throw error;
    }

    return this.getBookingRating(bookingId, 'DRIVER');
  }

  /** Staff: comments behind a driver's aggregate. */
  async listForDriver(driverId: string, query: PageQuery, user: AuthUser) {
    const driver = await this.prisma.driver.findUnique({
      where: { id: driverId },
      select: { id: true, branchId: true, ratingAvg: true, ratingCount: true },
    });
    if (!driver) throw new NotFoundException();
    this.assertBranch(user, driver.branchId);

    const { page, pageSize, skip, take } = normalizePage(query);
    const where = { driverId, raterType: 'PASSENGER' as const };
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.bookingRating.count({ where }),
      this.prisma.bookingRating.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        include: {
          booking: {
            select: {
              id: true,
              trackingId: true,
              closedAt: true,
              passengerName: true,
            },
          },
        },
      }),
    ]);

    return {
      ...paginate(
        rows.map((row) => this.presentRating(row)),
        total,
        { page, pageSize },
      ),
      aggregate: {
        ratingAvg: Number(driver.ratingAvg),
        ratingCount: driver.ratingCount,
      },
    };
  }

  /** Staff: comments behind a passenger's aggregate. */
  async listForPassenger(passengerId: string, query: PageQuery) {
    const passenger = await this.prisma.passenger.findUnique({
      where: { id: passengerId },
      select: { id: true, ratingAvg: true, ratingCount: true },
    });
    if (!passenger) throw new NotFoundException();

    const { page, pageSize, skip, take } = normalizePage(query);
    const where = { passengerId, raterType: 'DRIVER' as const };
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.bookingRating.count({ where }),
      this.prisma.bookingRating.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        include: {
          booking: {
            select: {
              id: true,
              trackingId: true,
              closedAt: true,
              driverId: true,
            },
          },
        },
      }),
    ]);

    return {
      ...paginate(
        rows.map((row) => this.presentRating(row)),
        total,
        { page, pageSize },
      ),
      aggregate: {
        ratingAvg: Number(passenger.ratingAvg),
        ratingCount: passenger.ratingCount,
      },
    };
  }

  private async getBookingRating(
    bookingId: string,
    raterType: 'PASSENGER' | 'DRIVER',
  ) {
    const row = await this.prisma.bookingRating.findUniqueOrThrow({
      where: { bookingId_raterType: { bookingId, raterType } },
    });
    return this.presentRating(row);
  }

  private presentRating(row: {
    id: string;
    bookingId: string;
    raterType: string;
    driverId: string | null;
    passengerId: string | null;
    stars: number;
    comment: string | null;
    createdAt: Date;
    booking?: {
      id: string;
      trackingId: string;
      closedAt: Date | null;
      passengerName?: string;
      driverId?: string | null;
    };
  }) {
    return {
      id: row.id,
      bookingId: row.bookingId,
      raterType: row.raterType,
      driverId: row.driverId,
      passengerId: row.passengerId,
      stars: row.stars,
      comment: row.comment,
      createdAt: row.createdAt.toISOString(),
      booking: row.booking
        ? {
            id: row.booking.id,
            trackingId: row.booking.trackingId,
            closedAt: row.booking.closedAt?.toISOString() ?? null,
            passengerName: row.booking.passengerName ?? null,
            driverId: row.booking.driverId ?? null,
          }
        : undefined,
    };
  }

  private ratingWindowDays() {
    const raw = this.config.get<string>('RATING_WINDOW_DAYS');
    const n = raw == null || raw === '' ? 14 : Number(raw);
    return Number.isFinite(n) && n > 0 ? n : 14;
  }

  private assertBranch(user: AuthUser, branchId: string) {
    if (user.role === 'super_admin') return;
    if (!user.branchId || user.branchId !== branchId) {
      throw new NotFoundException();
    }
  }

  private rethrowDuplicate(error: unknown): void {
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === 'P2002'
    ) {
      throw new ConflictException({ code: ApiCode.ALREADY_RATED });
    }
    if (
      error instanceof NotFoundException ||
      error instanceof ForbiddenException ||
      error instanceof ConflictException
    ) {
      throw error;
    }
  }
}
