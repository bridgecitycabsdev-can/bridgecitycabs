import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module.js';
import { FleetModule } from '../fleet/fleet.module.js';
import { BookingFleetSync } from './booking-fleet.sync.js';
import { DispatchGateway } from './dispatch.gateway.js';
import { DriverGateway } from './driver.gateway.js';
import { DriverPublisher } from './driver-publisher.js';
import { FleetBroadcaster } from './fleet-broadcaster.js';
import { FleetReconciler } from './fleet-reconciler.js';
import { SocketAuth } from './socket-auth.js';
import { SocketLimits } from './socket-limits.js';

/** Passenger sockets arrive when that app has something to receive. */
@Module({
  imports: [AuthModule, FleetModule],
  providers: [
    SocketAuth,
    SocketLimits,
    FleetBroadcaster,
    DriverPublisher,
    DriverGateway,
    DispatchGateway,
    BookingFleetSync,
    FleetReconciler,
  ],
})
export class RealtimeModule {}
