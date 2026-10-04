import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module.js';
import { FleetModule } from '../fleet/fleet.module.js';
import { PassengersModule } from '../passengers/passengers.module.js';
import { PushModule } from '../push/push.module.js';
import { BookingFleetSync } from './booking-fleet.sync.js';
import { DispatchGateway } from './dispatch.gateway.js';
import { DriverGateway } from './driver.gateway.js';
import { DriverPublisher } from './driver-publisher.js';
import { FleetBroadcaster } from './fleet-broadcaster.js';
import { FleetReconciler } from './fleet-reconciler.js';
import { OfferAckWaiter } from './offer-ack.waiter.js';
import { NotificationListener } from './notification.listener.js';
import { OfferSocketListener } from './offer-socket.listener.js';
import { PassengerGateway } from './passenger.gateway.js';
import { PassengerLocationRelay } from './passenger-location.relay.js';
import { PassengerPublisher } from './passenger-publisher.js';
import { PassengerPushListener } from './passenger-push.listener.js';
import { SocketAuth } from './socket-auth.js';
import { SocketLimits } from './socket-limits.js';
import { SosListener } from './sos.listener.js';

@Module({
  imports: [AuthModule, FleetModule, PushModule, PassengersModule],
  providers: [
    SocketAuth,
    SocketLimits,
    FleetBroadcaster,
    DriverPublisher,
    PassengerPublisher,
    PassengerLocationRelay,
    OfferAckWaiter,
    OfferSocketListener,
    PassengerPushListener,
    NotificationListener,
    SosListener,
    DriverGateway,
    PassengerGateway,
    DispatchGateway,
    BookingFleetSync,
    FleetReconciler,
  ],
})
export class RealtimeModule {}
