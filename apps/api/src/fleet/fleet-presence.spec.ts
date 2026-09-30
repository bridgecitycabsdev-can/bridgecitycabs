import { describe, expect, it } from 'vitest';
import {
  driverIdReleasedBy,
  passengerFirstName,
  presenceFromBooking,
  presenceOnBookingStatus,
} from './fleet-presence.js';

describe('fleet presence', () => {
  it('maps a live booking onto the driver chip and stays available otherwise', () => {
    expect(presenceFromBooking(null)).toBe('AVAILABLE');
    expect(presenceFromBooking('DRIVER_ASSIGNED')).toBe('ASSIGNED');
    expect(presenceFromBooking('DRIVER_ARRIVING')).toBe('EN_ROUTE_PICKUP');
    expect(presenceFromBooking('DRIVER_ARRIVED')).toBe('ARRIVED');
    expect(presenceFromBooking('TRIP_STARTED')).toBe('ON_TRIP');
    expect(presenceFromBooking('PAYMENT_PENDING')).toBe('AVAILABLE');
  });

  it('frees a driver at dropoff and ignores payment', () => {
    expect(presenceOnBookingStatus('DRIVER_ASSIGNED')).toBe('ASSIGNED');
    expect(presenceOnBookingStatus('DRIVER_ARRIVING')).toBe('EN_ROUTE_PICKUP');
    expect(presenceOnBookingStatus('DRIVER_ARRIVED')).toBe('ARRIVED');
    expect(presenceOnBookingStatus('TRIP_STARTED')).toBe('ON_TRIP');
    expect(presenceOnBookingStatus('TRIP_COMPLETED')).toBe('AVAILABLE');
    expect(presenceOnBookingStatus('SEARCHING_DRIVER')).toBe('AVAILABLE');
    expect(presenceOnBookingStatus('CANCELLED')).toBe('AVAILABLE');
    expect(presenceOnBookingStatus('NO_DRIVER_FOUND')).toBe('AVAILABLE');
    expect(presenceOnBookingStatus('PAYMENT_PENDING')).toBeNull();
    expect(presenceOnBookingStatus('MATCHED')).toBeNull();
  });

  it('frees the previous driver when the booking has already been reassigned', () => {
    expect(
      driverIdReleasedBy('CANCELLED', { status: 'CANCELLED', driverId: 'driver-a' }, []),
    ).toBe('driver-a');
    expect(
      driverIdReleasedBy('SEARCHING_DRIVER', { status: 'SEARCHING_DRIVER', driverId: null }, [
        'driver-b',
        'driver-a',
      ]),
    ).toBe('driver-b');
    expect(
      driverIdReleasedBy(
        'SEARCHING_DRIVER',
        { status: 'DRIVER_ASSIGNED', driverId: 'driver-c' },
        ['driver-b', 'driver-a', 'driver-c'],
      ),
    ).toBe('driver-b');
    expect(
      driverIdReleasedBy('NO_DRIVER_FOUND', { status: 'NO_DRIVER_FOUND', driverId: null }, []),
    ).toBeNull();
  });

  it('uses the account first name and never needs the phone number', () => {
    expect(passengerFirstName('Leila', 'Someone Else')).toBe('Leila');
    expect(passengerFirstName('  ', 'Amina Khan')).toBe('Amina');
    expect(passengerFirstName(null, '   ')).toBe('Passenger');
  });
});
