import { createHash, randomBytes } from 'node:crypto';
import {
  ForbiddenException,
  HttpException,
  HttpStatus,
  Inject,
  Injectable,
  InternalServerErrorException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Prisma } from '@prisma/client';
import argon2 from 'argon2';
import type { Redis } from 'ioredis';
import { normalizePhone } from '../common/phone.js';
import { REDIS } from '../redis/redis.constants.js';
import {
  otpCooldownKey,
  otpDailyIpKey,
  otpDailyPhoneKey,
  otpKey,
} from '../redis/redis.keys.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { SMS_PROVIDER, type SmsProvider } from '../sms/sms-provider.js';
import {
  OTP_ACCEPTED,
  OTP_DAILY_IP_CAP,
  OTP_DAILY_PHONE_CAP,
  OTP_MAX_ATTEMPTS,
  OTP_RESEND_SECONDS,
  OTP_TTL_SECONDS,
  hashOtp,
  newOtpCode,
  secondsUntilUtcMidnight,
} from './otp.policy.js';

type TokenUser = {
  id: string;
  branchId: string | null;
  role: { name: string };
};

const INVALID_CREDENTIALS = 'Invalid credentials';
const INVALID_CODE = 'Invalid code';

const VERIFY_OTP = `
local hash = redis.call('HGET', KEYS[1], 'hash')
if not hash then
  return 'missing'
end
local attempts = tonumber(redis.call('HGET', KEYS[1], 'attempts') or '0')
local maxAttempts = tonumber(ARGV[2])
if attempts >= maxAttempts then
  redis.call('DEL', KEYS[1])
  return 'locked'
end
if hash ~= ARGV[1] then
  local nextAttempts = redis.call('HINCRBY', KEYS[1], 'attempts', 1)
  if tonumber(nextAttempts) >= maxAttempts then
    redis.call('DEL', KEYS[1])
    return 'locked'
  end
  return 'mismatch'
end
redis.call('DEL', KEYS[1])
return 'ok'
`;

type PhoneAccount = Prisma.UserGetPayload<{
  include: {
    role: true;
    driver: { select: { id: true } };
    passenger: { select: { id: true; blocked: true } };
  };
}>;

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly config: ConfigService,
    @Inject(REDIS) private readonly redis: Redis,
    @Inject(SMS_PROVIDER) private readonly sms: SmsProvider,
  ) {}

  async requestOtp(rawPhone: string, ip: string) {
    const phone = normalizePhone(rawPhone);
    await this.consumeDailyCap(otpDailyPhoneKey(phone), OTP_DAILY_PHONE_CAP);
    await this.consumeDailyCap(otpDailyIpKey(ip), OTP_DAILY_IP_CAP);
    const reserved = await this.redis.set(
      otpCooldownKey(phone),
      '1',
      'EX',
      OTP_RESEND_SECONDS,
      'NX',
    );
    if (reserved !== 'OK') {
      throw new HttpException(
        'Wait 60 seconds before requesting another code',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    const account = await this.findPhoneAccount(phone);
    if (!this.canSendOtp(account)) {
      return OTP_ACCEPTED;
    }

    const code = newOtpCode(
      this.config.get<string>('OTP_DEV_CODE'),
      this.config.get<string>('NODE_ENV'),
    );
    const pepper = this.otpPepper();
    const key = otpKey(phone);
    await this.redis
      .multi()
      .hset(key, 'hash', hashOtp(pepper, code), 'attempts', '0')
      .expire(key, OTP_TTL_SECONDS)
      .exec();
    await this.sms.sendTransactional(
      phone,
      `Bridgecabs code: ${code}. It expires in 5 minutes.`,
    );
    return OTP_ACCEPTED;
  }

  async verifyOtp(rawPhone: string, code: string) {
    const phone = normalizePhone(rawPhone);
    const outcome = await this.redis.eval(
      VERIFY_OTP,
      1,
      otpKey(phone),
      hashOtp(this.otpPepper(), code),
      String(OTP_MAX_ATTEMPTS),
    );
    if (outcome !== 'ok') {
      throw new UnauthorizedException(INVALID_CODE);
    }

    const account = await this.findPhoneAccount(phone);
    const user = await this.accountForVerifiedPhone(phone, account);
    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });
    return this.issueTokens(user);
  }

  async login(email: string, password: string) {
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: { role: true },
    });
    const ok =
      !!user?.isActive &&
      !!user.passwordHash &&
      (await argon2.verify(user.passwordHash, password));
    if (!ok || !user) {
      throw new UnauthorizedException(INVALID_CREDENTIALS);
    }

    await this.prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });
    return this.issueTokens(user);
  }

  async refresh(refreshToken: string) {
    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash: this.hashToken(refreshToken) },
      include: { user: { include: { role: true } } },
    });
    if (!stored) {
      throw new UnauthorizedException(INVALID_CREDENTIALS);
    }

    if (stored.revokedAt) {
      await this.prisma.refreshToken.updateMany({
        where: { userId: stored.userId, revokedAt: null },
        data: { revokedAt: new Date() },
      });
      throw new UnauthorizedException(INVALID_CREDENTIALS);
    }

    if (stored.expiresAt.getTime() <= Date.now() || !stored.user.isActive) {
      throw new UnauthorizedException(INVALID_CREDENTIALS);
    }

    await this.prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });
    return this.issueTokens(stored.user);
  }

  async logout(userId: string, refreshToken: string) {
    await this.prisma.refreshToken.updateMany({
      where: { tokenHash: this.hashToken(refreshToken), revokedAt: null },
      data: { revokedAt: new Date() },
    });
    await this.prisma.deviceToken.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return { success: true };
  }

  async me(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { role: true, branch: true },
    });
    if (!user?.isActive) {
      throw new UnauthorizedException(INVALID_CREDENTIALS);
    }
    return this.toProfile(user);
  }

  toProfile(
    user: Prisma.UserGetPayload<{ include: { role: true; branch: true } }>,
  ) {
    return {
      id: user.id,
      email: user.email,
      phone: user.phone,
      isActive: user.isActive,
      lastLoginAt: user.lastLoginAt,
      role: { id: user.role.id, name: user.role.name },
      branch: user.branch
        ? {
            id: user.branch.id,
            name: user.branch.name,
            city: user.branch.city,
          }
        : null,
    };
  }

  private async issueTokens(user: TokenUser) {
    const payload = {
      sub: user.id,
      role: user.role.name,
      branchId: user.branchId,
    };
    const accessToken = await this.jwt.signAsync(payload, { expiresIn: '15m' });
    const refreshToken = randomBytes(48).toString('hex');
    await this.prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: this.hashToken(refreshToken),
        expiresAt: this.addDays(new Date(), this.refreshTtlDays()),
      },
    });
    return { accessToken, refreshToken };
  }

  private otpPepper() {
    const pepper = this.config.get<string>('OTP_PEPPER');
    if (!pepper) {
      throw new InternalServerErrorException('OTP pepper is not configured');
    }
    return pepper;
  }

  private async consumeDailyCap(key: string, cap: number) {
    const count = await this.redis.incr(key);
    if (count === 1) {
      await this.redis.expire(key, secondsUntilUtcMidnight());
    }
    if (count > cap) {
      throw new HttpException(
        'Too many code requests. Try again tomorrow',
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }
  }

  private findPhoneAccount(phone: string) {
    return this.prisma.user.findUnique({
      where: { phone },
      include: {
        role: true,
        driver: { select: { id: true } },
        passenger: { select: { id: true, blocked: true } },
      },
    });
  }

  private canSendOtp(account: PhoneAccount | null) {
    // No account yet: this number can become a passenger, so it still gets a code.
    // Staff, inactive, and blocked accounts get the same HTTP response and no message.
    if (!account) {
      return true;
    }
    if (!account.isActive) {
      return false;
    }
    if (account.role.name === 'driver') {
      return account.driver != null;
    }
    if (account.role.name === 'passenger') {
      return account.passenger != null && !account.passenger.blocked;
    }
    return false;
  }

  private async accountForVerifiedPhone(phone: string, account: PhoneAccount | null) {
    if (!account) {
      return this.createPassenger(phone);
    }
    if (!account.isActive) {
      throw new UnauthorizedException(INVALID_CODE);
    }
    if (account.role.name === 'driver' && account.driver) {
      return account;
    }
    if (account.role.name === 'passenger' && account.passenger) {
      if (account.passenger.blocked) {
        throw new ForbiddenException('Passenger is blocked');
      }
      return account;
    }
    throw new UnauthorizedException(INVALID_CODE);
  }

  private async createPassenger(phone: string): Promise<TokenUser> {
    const role = await this.prisma.role.findUnique({ where: { name: 'passenger' } });
    if (!role) {
      throw new InternalServerErrorException('Passenger role is not configured');
    }
    try {
      const account = await this.prisma.$transaction(async (tx) => {
        const user = await tx.user.create({
          data: { phone, roleId: role.id },
        });
        await tx.passenger.create({
          data: { userId: user.id, firstName: 'Passenger', phone },
        });
        return user;
      });
      return { id: account.id, branchId: null, role: { name: 'passenger' } };
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        const existing = await this.findPhoneAccount(phone);
        if (
          existing?.isActive &&
          existing.role.name === 'passenger' &&
          existing.passenger &&
          !existing.passenger.blocked
        ) {
          return existing;
        }
      }
      throw error;
    }
  }

  private hashToken(token: string) {
    return createHash('sha256').update(token).digest('hex');
  }

  private refreshTtlDays() {
    const days = Number(this.config.get<string>('JWT_REFRESH_TTL_DAYS') ?? 7);
    return Number.isFinite(days) && days > 0 ? days : 7;
  }

  private addDays(date: Date, days: number) {
    const next = new Date(date);
    next.setUTCDate(next.getUTCDate() + days);
    return next;
  }
}
