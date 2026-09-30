import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Test, TestingModule } from '@nestjs/testing';
import { REDIS } from '../redis/redis.constants.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { SMS_PROVIDER } from '../sms/sms-provider.js';
import { AuthService } from './auth.service.js';

describe('AuthService', () => {
  let service: AuthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: {} },
        { provide: JwtService, useValue: {} },
        { provide: ConfigService, useValue: { get: () => '7' } },
        { provide: REDIS, useValue: {} },
        { provide: SMS_PROVIDER, useValue: { sendTransactional: async () => undefined } },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });
});
