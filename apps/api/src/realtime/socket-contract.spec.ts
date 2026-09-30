import { locationPingIntervalMs } from '@bridgecabs/shared-types';
import { describe, expect, it } from 'vitest';
import { SOCKET_EVENTS, socketPayloads } from './socket-contract.js';

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
  });
});