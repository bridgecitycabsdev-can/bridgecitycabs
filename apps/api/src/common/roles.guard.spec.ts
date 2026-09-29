import {
  Controller,
  ExecutionContext,
  Get,
  INestApplication,
} from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { Test } from '@nestjs/testing';
import request from 'supertest';
import type { App } from 'supertest/types.js';
import type { AuthUser } from './auth-user.js';
import { Roles } from './roles.decorator.js';
import { RolesGuard } from './roles.guard.js';

@Controller('roles-check')
class RolesCheckController {
  @Get('any')
  any() {
    return { ok: true };
  }

  @Get('admin')
  @Roles('super_admin', 'branch_admin')
  admin() {
    return { ok: true };
  }
}

class AttachUserGuard {
  constructor(private readonly user: AuthUser | undefined) {}

  canActivate(context: ExecutionContext) {
    const req = context.switchToHttp().getRequest<{ user?: AuthUser }>();
    req.user = this.user;
    return true;
  }
}

async function createApp(user?: AuthUser) {
  const moduleRef = await Test.createTestingModule({
    controllers: [RolesCheckController],
    providers: [
      { provide: APP_GUARD, useValue: new AttachUserGuard(user) },
      { provide: APP_GUARD, useClass: RolesGuard },
    ],
  }).compile();
  const app = moduleRef.createNestApplication();
  await app.init();
  return app;
}

describe('RolesGuard', () => {
  let app: INestApplication<App>;

  afterEach(async () => {
    await app?.close();
  });

  it('allows an authenticated route with no role metadata', async () => {
    app = await createApp({
      userId: 'user-1',
      role: 'driver',
      branchId: null,
    });
    await request(app.getHttpServer()).get('/roles-check/any').expect(200);
  });

  it('allows a listed role', async () => {
    app = await createApp({
      userId: 'user-1',
      role: 'branch_admin',
      branchId: 'branch-1',
    });
    await request(app.getHttpServer()).get('/roles-check/admin').expect(200);
  });

  it('rejects a role that is not listed', async () => {
    app = await createApp({
      userId: 'user-1',
      role: 'driver',
      branchId: null,
    });
    await request(app.getHttpServer()).get('/roles-check/admin').expect(403);
  });
});
