import { ServiceUnavailableException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { PrismaService } from './prisma/prisma.service.js';
import { REDIS } from './redis/redis.constants.js';

describe('AppController', () => {
  let appController: AppController;
  const redis = { ping: vi.fn(async () => 'PONG') };
  const prisma = { $queryRaw: vi.fn(async () => [{ '?column?': 1 }]) };

  beforeEach(async () => {
    redis.ping.mockReset().mockResolvedValue('PONG');
    prisma.$queryRaw.mockReset().mockResolvedValue([{ '?column?': 1 }]);
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [
        AppService,
        { provide: PrismaService, useValue: prisma },
        { provide: REDIS, useValue: redis },
      ],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  afterEach(() => {
    vi.unstubAllEnvs();
  });

  describe('root', () => {
    it('should return "Hello World!"', () => {
      expect(appController.getHello()).toBe('Hello World!');
    });
  });

  describe('health', () => {
    it('returns liveness without touching dependencies', () => {
      expect(appController.health()).toEqual({ status: 'ok' });
      expect(prisma.$queryRaw).not.toHaveBeenCalled();
      expect(redis.ping).not.toHaveBeenCalled();
    });

    it('returns ready when db and redis respond', async () => {
      await expect(appController.ready()).resolves.toEqual({ status: 'ready' });
    });

    it('returns 503 when redis is unreachable', async () => {
      redis.ping.mockRejectedValueOnce(new Error('ECONNREFUSED'));
      await expect(appController.ready()).rejects.toBeInstanceOf(
        ServiceUnavailableException,
      );
    });

    it('returns 503 when db is unreachable', async () => {
      prisma.$queryRaw.mockRejectedValueOnce(new Error('db down'));
      await expect(appController.ready()).rejects.toBeInstanceOf(
        ServiceUnavailableException,
      );
    });

    it('slow endpoint waits then returns in non-production', async () => {
      vi.stubEnv('NODE_ENV', 'test');
      await expect(appController.slow()).resolves.toEqual({ status: 'slow-ok' });
    });

    it('slow endpoint is unavailable in production', async () => {
      vi.stubEnv('NODE_ENV', 'production');
      await expect(appController.slow()).rejects.toBeInstanceOf(
        ServiceUnavailableException,
      );
    });
  });
});
