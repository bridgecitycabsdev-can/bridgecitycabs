import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_FILTER, APP_GUARD } from '@nestjs/core';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { ThrottlerModule } from '@nestjs/throttler';
import { REDIS } from './redis/redis.constants.js';
import { RedisModule } from './redis/redis.module.js';
import { RedisThrottlerStorage } from './redis/redis-throttler.storage.js';
import type { Redis } from 'ioredis';
import { AuthModule } from './auth/auth.module.js';
import { AppController } from './app.controller.js';
import { AppService } from './app.service.js';
import { AuditModule } from './audit/audit.module.js';
import { ApiExceptionFilter } from './common/api-exception.filter.js';
import { JwtAuthGuard } from './common/jwt-auth.guard.js';
import { RejectTokenQueryMiddleware } from './common/reject-token-query.middleware.js';
import { RolesGuard } from './common/roles.guard.js';
import { PrismaModule } from './prisma/prisma.module.js';
import { BranchesModule } from './branches/branches.module.js';
import { UsersModule } from './users/users.module.js';
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
import { FinanceModule } from './finance/finance.module.js';
import { LedgerModule } from './ledger/ledger.module.js';
import { CorporateModule } from './corporate/corporate.module.js';
import { LeaseModule } from './lease/lease.module.js';
import { PaymentsModule } from './payments/payments.module.js';
import { PassengersModule } from './passengers/passengers.module.js';
import { PromosModule } from './promos/promos.module.js';
import { RatingsModule } from './ratings/ratings.module.js';
import { NotificationsModule } from './notifications/notifications.module.js';
import { SupportModule } from './support/support.module.js';
import { SosModule } from './sos/sos.module.js';
import { ReportingModule } from './reporting/reporting.module.js';
import { PlacesModule } from './places/places.module.js';
import { PushModule } from './push/push.module.js';
import { RealtimeModule } from './realtime/realtime.module.js';
import { VehiclesModule } from './vehicles/vehicles.module.js';
import { DevBoardModule } from './dev/dev-board.module.js';
import { DispatchConfigModule } from './config/dispatch-config.module.js';
import { WebhooksModule } from './webhooks/webhooks.module.js';

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
    AuditModule,
    AuthModule,
    UsersModule,
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
    PlacesModule,
    DispatchConfigModule,
    BookingsModule,
    FaresModule,
    LedgerModule,
    LeaseModule,
    CorporateModule,
    PromosModule,
    RatingsModule,
    NotificationsModule,
    SupportModule,
    SosModule,
    ReportingModule,
    FinanceModule,
    PaymentsModule,
    WebhooksModule,
    DevicesModule,
    PushModule,
    RealtimeModule,
    ...(devBoardEnabled ? [DevBoardModule] : []),
  ],
  controllers: [AppController],
  providers: [
    AppService,
    { provide: APP_FILTER, useClass: ApiExceptionFilter },
    { provide: APP_GUARD, useClass: JwtAuthGuard },
    { provide: APP_GUARD, useClass: RolesGuard },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(RejectTokenQueryMiddleware).forRoutes('{*path}');
  }
}
