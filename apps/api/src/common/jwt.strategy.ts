import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import type { AuthUser } from './auth-user.js';

type AccessTokenPayload = {
  sub?: string;
  role?: string;
  branchId?: string | null;
};

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(config: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.getOrThrow<string>('JWT_ACCESS_SECRET'),
    });
  }

  validate(payload: AccessTokenPayload): AuthUser {
    if (!payload.sub || !payload.role) {
      throw new UnauthorizedException('Invalid credentials');
    }
    return {
      userId: payload.sub,
      role: payload.role,
      branchId: payload.branchId ?? null,
    };
  }
}
