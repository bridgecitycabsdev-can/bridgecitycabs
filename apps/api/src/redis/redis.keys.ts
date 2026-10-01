import { createHash } from 'node:crypto';

/** Hash fields on `driver:{id}`. Fleet broadcasts read name and unit from here. */
export const DRIVER_HASH_FIELDS = {
  status: 'status',
  version: 'v',
  lat: 'lat',
  lng: 'lng',
  heading: 'heading',
  speed: 'speed',
  accuracy: 'acc',
  ts: 'ts',
  branchId: 'branchId',
  bookingId: 'bookingId',
  name: 'name',
  unit: 'unit',
  vehicleType: 'vehicleType',
  vehicleId: 'vehicleId',
  ladyDriverEligible: 'ladyDriverEligible',
  /** Unix ms when this driver last became AVAILABLE. Ranking uses it. */
  availableSince: 'availableSince',
  staleSince: 'staleSince',
  /** Last time a point was copied into the location history buffer. */
  histAt: 'histAt',
} as const;

export function phoneHash(phone: string) {
  return createHash('sha256').update(phone).digest('hex');
}

export function utcDay(now = new Date()) {
  return now.toISOString().slice(0, 10);
}

export function driverKey(driverId: string) {
  return `driver:${driverId}`;
}

export function presenceKey(driverId: string) {
  return `presence:driver:${driverId}`;
}

export function onlineKey(branchId: string) {
  return `online:${branchId}`;
}

export function geoAvailableKey(branchId: string) {
  return `geo:available:${branchId}`;
}

/** Hash claim for the driver's open offer: offerId, bookingId, driverId. TTL is the offer timeout. */
export function offerReserveKey(driverId: string) {
  return `offer:driver:${driverId}`;
}

/** Drivers already offered this booking. Expires after an hour. */
export function offeredDriversKey(bookingId: string) {
  return `booking:${bookingId}:offered`;
}

export function sessionKey(driverId: string) {
  return `session:driver:${driverId}`;
}

export function otpKey(phone: string) {
  return `otp:${phoneHash(phone)}`;
}

export function otpCooldownKey(phone: string) {
  return `otp:cooldown:${phoneHash(phone)}`;
}

export function otpDailyPhoneKey(phone: string, day = utcDay()) {
  return `otp:daily:phone:${phoneHash(phone)}:${day}`;
}

export function otpDailyIpKey(ip: string, day = utcDay()) {
  return `otp:daily:ip:${ip}:${day}`;
}

export const LOC_BUFFER_KEY = 'loc:buffer';

export function socketConnKey(userId: string) {
  return `socket:conns:${userId}`;
}

export function socketRateKey(userId: string) {
  return `socket:rate:${userId}`;
}

export function throttleHitKey(throttlerName: string, key: string) {
  return `throttle:${throttlerName}:${key}:hits`;
}

export function throttleBlockKey(throttlerName: string, key: string) {
  return `throttle:${throttlerName}:${key}:blocked`;
}
