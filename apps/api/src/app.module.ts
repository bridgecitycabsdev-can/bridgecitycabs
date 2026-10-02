import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { ThrottlerModule } from '@nestjs/throttler';
import { REDIS } from './redis/redis.constants.js';
import { RedisModule } from './redis/redis.module.js';
import { RedisThrottlerStorage } from './redis/redis-throttler.storage.js';
import type { Redis } from 'ioredis';
import { AuthModule } from './auth/auth.module.js';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { JwtAuthGuard } from './common/jwt-auth.guard.js';
import { RejectTokenQueryMiddleware } from './common/reject-token-query.middleware.js';
import { RolesGuard } from './common/roles.guard.js';
import { PrismaModule } from './prisma/prisma.module.js';
import { BranchesModule } from './branches/branches.module.js';
import { CatalogModule } from './catalog/catalog.module.js';
import { AssignmentsModule } from './assignments/assignments.module.js';
import { DocumentsModule } from './documents/documents.module.js';
import { DevicesModule } from './devices/devices.module.js';
import { DispatchModule } from './dispatch/dispatch.module.js';
import { DriversModule } from './drivers/drivers.module.js';
import { FleetModule } from './fleet/fleet.module.js';
import { JobsModule } from './jobs/jobs.module.js';
import { IdempotencyModule } from './idempotency/idempotency.module.js';
import { FaresModule } from './fares/fares.module.js';
import { BookingsModule } from './bookings/bookings.module.js';
import { PassengersModule } from './passengers/passengers.module.js';
import { PushModule } from './push/push.module.js';
import { RealtimeModule } from './realtime/realtime.module.js';
import { VehiclesModule } from './vehicles/vehicles.module.js';
import { DevBoardModule } from './dev/dev-board.module.js';

const devBoardEnabled =
  process.env.NODE_ENV !== 'production' && process.env.NODE_ENV !== 'test';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    RedisModule,
    ThrottlerModule.forRootAsync({
      imports: [RedisModule],
      inject: [REDIS],
      useFactory: (redis: Redis) => ({
        throttlers: [{ ttl: 60_000, limit: 100 }],
        storage: new RedisThrottlerStorage(redis),
      }),
    }),
    EventEmitterModule.forRoot(),
    PrismaModule,
    IdempotencyModule,
    AuthModule,
    BranchesModule,
    CatalogModule,
    VehiclesModule,
    DriversModule,
    FleetModule,
    JobsModule,
    AssignmentsModule,
    DocumentsModule,
    DispatchModule,
    PassengersModule,
    BookingsModule,
    FaresModule,
    DevicesModule,
    PushModule,
    RealtimeModule,
    ...(devBoardEnabled ? [DevBoardModule] : []),
  ],
  controllers: [AppController],
  providers: [
    AppService,
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(RejectTokenQueryMiddleware).forRoutes('{*path}');
  }
}
