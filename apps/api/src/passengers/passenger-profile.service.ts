import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { AuthService } from '../auth/auth.service.js';
import type { AuthUser } from '../common/auth-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { DeletePassengerAccountDto } from './dto/delete-passenger-account.dto.js';
import type { UpdatePassengerProfileDto } from './dto/update-passenger-profile.dto.js';

const OPEN_TRIP_STATUSES = [
  'SCHEDULED',
  'CREATED',
  'SEARCHING_DRIVER',
  'MATCHED',
  'DRIVER_ASSIGNED',
  'DRIVER_ARRIVING',
  'DRIVER_ARRIVED',
  'TRIP_STARTED',
  'PAYMENT_PENDING',
  'NO_DRIVER_FOUND',
] as const;

@Injectable()
export class PassengerProfileService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly auth: AuthService,
  ) {}

  async get(user: AuthUser) {
    const passenger = await this.require(user);
    return this.present(passenger);
  }

  async update(user: AuthUser, dto: UpdatePassengerProfileDto) {
    const passenger = await this.require(user);
    const lastName =
      dto.lastName === undefined ? undefined : dto.lastName || null;
    try {
      await this.prisma.$transaction(async (tx) => {
        const updated = await tx.passenger.update({
          where: { id: passenger.id },
          data: {
            firstName: dto.firstName,
            lastName,
            email: dto.email,
          },
        });
        await tx.user.update({
          where: { id: user.userId },
          data: {
            email: dto.email,
            displayName: [updated.firstName, updated.lastName]
              .filter((part) => part && part.length > 0)
              .join(' '),
          },
        });
      });
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException('That email is already in use');
      }
      throw error;
    }
    return this.get(user);
  }

  async requestDeletionCode(user: AuthUser) {
    const passenger = await this.require(user);
    await this.auth.requestOtp(passenger.phone, `passenger-delete:${user.userId}`);
    return { accepted: true };
  }

  async delete(user: AuthUser, dto: DeletePassengerAccountDto) {
    const passenger = await this.require(user);
    const openTrip = await this.prisma.booking.findFirst({
      where: {
        passengerId: passenger.id,
        status: { in: [...OPEN_TRIP_STATUSES] },
      },
      select: { id: true },
    });
    if (openTrip) {
      throw new ConflictException(
        'Finish or cancel your current trip before deleting your account',
      );
    }
    await this.auth.confirmOtp(passenger.phone, dto.otp);
    const reason = [dto.reason, dto.feedback].filter(Boolean).join(': ');
    await this.prisma.$transaction([
      this.prisma.passenger.update({
        where: { id: passenger.id },
        data: {
          blocked: true,
          blockReason: reason.slice(0, 500),
          blockedAt: new Date(),
        },
      }),
      this.prisma.user.update({
        where: { id: user.userId },
        data: { isActive: false },
      }),
      this.prisma.refreshToken.updateMany({
        where: { userId: user.userId, revokedAt: null },
        data: { revokedAt: new Date() },
      }),
    ]);
    return { deleted: true };
  }

  private async require(user: AuthUser) {
    const passenger = await this.prisma.passenger.findUnique({
      where: { userId: user.userId },
    });
    if (!passenger || passenger.blocked) throw new NotFoundException();
    return passenger;
  }

  private async present(
    passenger: Prisma.PassengerGetPayload<Record<string, never>>,
  ) {
    const [totalRides, card] = await Promise.all([
      this.prisma.booking.count({
        where: {
          passengerId: passenger.id,
          status: { in: ['CLOSED', 'PAYMENT_COMPLETED'] },
        },
      }),
      this.prisma.passengerPaymentMethod.findFirst({
        where: { passengerId: passenger.id, isDefault: true },
      }),
    ]);
    const fullName = [passenger.firstName, passenger.lastName]
      .filter((part) => part && part.length > 0)
      .join(' ');
    const defaultPaymentMethod =
      card?.brand && card.last4
        ? `${card.brand} •••• ${card.last4}`
        : 'Cash';
    return {
      id: passenger.id,
      firstName: passenger.firstName,
      lastName: passenger.lastName,
      fullName,
      phone: passenger.phone,
      email: passenger.email ?? '',
      rating: Number(passenger.ratingAvg),
      totalRides,
      memberSince: String(passenger.createdAt.getUTCFullYear()),
      defaultPaymentMethod,
    };
  }
}
