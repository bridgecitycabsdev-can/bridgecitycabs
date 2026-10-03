import { locationPingIntervalMs } from '@bridgecabs/shared-types';
import { describe, expect, it } from 'vitest';
import { passengerDriverLocationSchema, SOCKET_EVENTS, socketPayloads } from './socket-contract.js';

const at = '2026-09-30T08:42:00.000Z';

describe('socket contract', () => {
  it('names the telemetry and snapshot events', () => {
    expect(SOCKET_EVENTS).toEqual({
      driverLocation: 'driver:location',
      driverHeartbeat: 'driver:heartbeat',
      driverState: 'driver:state',
      sessionReplaced: 'session:replaced',
      authExpiring: 'auth:expiring',
      authToken: 'auth:token',
      fleetSubscribe: 'fleet:subscribe',
      fleetSnapshot: 'fleet:snapshot',
      fleetDriverUpdated: 'fleet:driver_updated',
      bookingStatusChanged: 'booking:status_changed',
      bookingCreated: 'booking:created',
      bookingEdited: 'booking:edited',
      offerNew: 'offer:new',
      offerCancelled: 'offer:cancelled',
      offerExpired: 'offer:expired',
      offerReceived: 'offer:received',
      offerCreated: 'offer:created',
      offerResolved: 'offer:resolved',
      tripUpdate: 'trip:update',
      bookingUpdated: 'booking:updated',
    });
  });

  it('accepts the driver snapshot and rejects a passenger phone number', () => {
    const snapshot = {
      v: 4,
      status: 'ON_TRIP',
      shift: {
        startedAt: at,
        vehicle: {
          id: '33333333-3333-4333-8333-333333333333',
          unitNumber: '111',
          plate: 'LTH111',
        },
      },
      booking: {
        id: '22222222-2222-4222-8222-222222222222',
        trackingId: 'BC-7K3MQ9XT',
        status: 'TRIP_STARTED',
        stops: [
          {
            id: '44444444-4444-4444-8444-444444444444',
            sequence: 0,
            type: 'PICKUP',
            address: 'City Hall',
            lat: 49.6935,
            lng: -112.8418,
          },
        ],
        passengerFirstName: 'Leila',
        scheduledAt: at,
        notes: null,
        quotedFareCents: 2500,
      },
      offer: null,
    };
    expect(socketPayloads['driver:state'].parse(snapshot)).toEqual(snapshot);
    expect(
      socketPayloads['driver:state'].safeParse({
        ...snapshot,
        booking: { ...snapshot.booking, passengerPhone: '+14035550100' },
      }).success,
    ).toBe(false);
  });

  it('pings every 5 seconds while active and about every 15 seconds while idle', () => {
    expect(locationPingIntervalMs('ON_TRIP')).toBe(5_000);
    expect(locationPingIntervalMs('EN_ROUTE_PICKUP')).toBe(5_000);
    expect(locationPingIntervalMs('AVAILABLE')).toBe(15_000);
    expect(locationPingIntervalMs('AWAY')).toBe(15_000);
    expect(locationPingIntervalMs('OFFLINE')).toBeNull();
  });

  it('parses a location ping, a heartbeat, and a session replacement', () => {
    expect(
      socketPayloads['driver:location'].parse({
        lat: 49.7,
        lng: -112.83,
        heading: 90,
        recordedAt: at,
      }).heading,
    ).toBe(90);
    expect(socketPayloads['driver:heartbeat'].parse({ sentAt: at }).sentAt).toBe(at);
    expect(socketPayloads['session:replaced'].parse({ at }).at).toBe(at);
    const offerId = '55555555-5555-4555-8555-555555555555';
    const bookingId = '22222222-2222-4222-8222-222222222222';
    const driverId = '11111111-1111-4111-8111-111111111111';
    expect(
      socketPayloads['offer:received'].parse({ offerId }),
    ).toEqual({ offerId });
    expect(
      socketPayloads['offer:expired'].parse({ offerId, bookingId }),
    ).toEqual({ offerId, bookingId });
    expect(socketPayloads['offer:resolved'].parse({
      bookingId,
      offerId,
      driverId,
      outcome: 'EXPIRED',
    }).outcome).toBe('EXPIRED');
    expect(
      socketPayloads['offer:new'].safeParse({
        offerId,
        bookingId,
        expiresAt: at,
        serverNow: at,
        pickup: { address: 'City Hall', lat: 49.69, lng: -112.84 },
        dropoff: { address: 'Airport', lat: 49.63, lng: -112.8 },
        distanceToPickupM: 400,
        tripDistanceM: 8000,
        quotedFareCents: 2500,
        paymentMethod: 'CASH',
        vanOnly: false,
        ladyDriverOnly: false,
        passengerFirstName: 'Leila',
        notes: null,
        passengerPhone: '+14035550100',
      }).success,
    ).toBe(false);
    expect(
      socketPayloads['offer:new'].parse({
        offerId,
        bookingId,
        expiresAt: at,
        serverNow: at,
        pickup: { address: 'City Hall', lat: 49.69, lng: -112.84 },
        dropoff: { address: 'Airport', lat: 49.63, lng: -112.8 },
        distanceToPickupM: 400,
        tripDistanceM: 8000,
        quotedFareCents: 2500,
        paymentMethod: 'CARD',
        vanOnly: true,
        ladyDriverOnly: false,
        passengerFirstName: 'Leila',
        notes: null,
      }).paymentMethod,
    ).toBe('CARD');
  });

  it('sends the passenger a booking card and their own driver point, without a phone number', () => {
    const bookingId = '22222222-2222-4222-8222-222222222222';
    const card = {
      id: bookingId,
      trackingId: 'BC-7K3MQ9XT',
      status: 'DRIVER_ASSIGNED',
      etaSeconds: 90,
      scheduledAt: null,
      quotedFareCents: 1500,
      quotedTaxCents: 75,
      notes: null,
      passengerName: 'Leila Khan',
      vehicleType: {
        id: '33333333-3333-4333-8333-333333333333',
        name: 'Sedan',
      },
      stops: [
        {
          sequence: 1,
          type: 'PICKUP' as const,
          address: 'City Hall',
          lat: 49.69,
          lng: -112.84,
        },
      ],
      driver: {
        firstName: 'Sam',
        rating: 4.8,
        vehicle: {
          make: 'Toyota',
          model: 'Camry',
          colour: 'White',
          plate: 'LTH111',
          unitNumber: '111',
        },
      },
    };
    expect(socketPayloads['booking:updated'].parse(card)).toEqual(card);
    expect(socketPayloads['booking:updated'].safeParse({ ...card, phone: '+14035550100' }).success).toBe(
      false,
    );
    const point = { bookingId, lat: 49.7, lng: -112.83, heading: 90, ts: 1_700_000_000_000 };
    expect(passengerDriverLocationSchema.parse(point)).toEqual(point);
    expect(passengerDriverLocationSchema.safeParse({ ...point, phone: '+14035550199' }).success).toBe(
      false,
    );
  });
});