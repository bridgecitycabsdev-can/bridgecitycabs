/**
 * Day 14 Step 7 — exercise Day 6 matching (Lua reserve + optimistic accept)
 * under concurrent passenger booking creates.
 *
 * Prereqs:
 *   1. API up with raised throttles for the run:
 *        THROTTLE_LIMIT=100000 BOOKING_THROTTLE_LIMIT=1000
 *   2. Sim drivers online:
 *        cd apps/api && pnpm exec tsx scripts/spawn-sim-drivers.ts \
 *          --count 100 --branch <branchId> --behavior accept
 *   3. Install k6 (https://k6.io), then from repo root:
 *        API_URL=http://localhost:3000 BRANCH_ID=<id> VEHICLE_TYPE_ID=<id> \
 *          k6 run loadtest/booking-matching.js
 *
 * Pass condition is not only latency — confirm zero driver double-booking rows
 * in Postgres (see docs/production-hardening.md § Load test).
 */
import http from 'k6/http';
import { check, sleep } from 'k6';
import { SharedArray } from 'k6/data';
import { uuidv4 } from 'https://jslib.k6.io/k6-utils/1.4.0/index.js';

const API_URL = (__ENV.API_URL || 'http://localhost:3000').replace(/\/$/, '');
const BRANCH_ID = __ENV.BRANCH_ID;
const VEHICLE_TYPE_ID = __ENV.VEHICLE_TYPE_ID;
const THINK = Number(__ENV.THINK_TIME || 1);

const pickup = {
  address: 'Lethbridge City Hall',
  lat: 49.6946,
  lng: -112.8328,
};
const dropoff = {
  address: 'Galt Museum',
  lat: 49.6856,
  lng: -112.8297,
};

const tokens = new SharedArray('passenger-tokens', () => {
  const raw = open('./passenger-tokens.json');
  const parsed = JSON.parse(raw);
  if (!Array.isArray(parsed.tokens) || parsed.tokens.length === 0) {
    throw new Error(
      'loadtest/passenger-tokens.json missing tokens — run spawn-sim-drivers.ts first',
    );
  }
  return parsed.tokens;
});

export const options = {
  stages: [
    { duration: '30s', target: 50 },
    { duration: '1m', target: 50 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],
    // Active GET may 404; booking create is what we care about for failure rate.
    'http_req_failed{name:create}': ['rate<0.01'],
    checks: ['rate>0.95'],
  },
};

export function setup() {
  if (!BRANCH_ID) throw new Error('Set BRANCH_ID');
  if (!VEHICLE_TYPE_ID) throw new Error('Set VEHICLE_TYPE_ID');
  return {
    branchId: BRANCH_ID,
    vehicleTypeId: VEHICLE_TYPE_ID,
  };
}

export default function (data) {
  const token = tokens[(__VU - 1) % tokens.length];
  const headers = {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  };

  cancelActiveIfAny(headers);

  const quotesRes = http.post(
    `${API_URL}/api/v1/passenger/fares/quotes`,
    JSON.stringify({
      branchId: data.branchId,
      stops: [
        { lat: pickup.lat, lng: pickup.lng },
        { lat: dropoff.lat, lng: dropoff.lng },
      ],
    }),
    { headers, tags: { name: 'quotes' } },
  );
  const quoted = check(quotesRes, {
    'quotes 200': (r) => r.status === 200,
  });
  if (!quoted) {
    sleep(THINK);
    return;
  }

  const body = quotesRes.json();
  const option =
    (body.options || []).find((row) => row.vehicleTypeId === data.vehicleTypeId) ||
    (body.options || [])[0];
  if (!option?.quoteToken || !body.zone) {
    sleep(THINK);
    return;
  }

  const res = http.post(
    `${API_URL}/api/v1/passenger/bookings`,
    JSON.stringify(bookingPayload(data, option.quoteToken, body.zone)),
    {
      headers: {
        ...headers,
        'Idempotency-Key': uuidv4(),
      },
      tags: { name: 'create' },
    },
  );
  check(res, { 'status is 201': (r) => r.status === 201 });
  sleep(THINK);
}

function bookingPayload(data, quoteToken, zone) {
  return {
    branchId: data.branchId,
    vehicleTypeId: data.vehicleTypeId,
    zone,
    quoteToken,
    paymentMethod: 'CASH',
    stops: [pickup, dropoff],
  };
}

function cancelActiveIfAny(headers) {
  const active = http.get(`${API_URL}/api/v1/passenger/bookings/active`, {
    headers,
    tags: { name: 'active' },
    responseCallback: http.expectedStatuses(200, 404),
  });
  if (active.status !== 200) return;
  const id = active.json('id');
  if (!id) return;
  http.post(
    `${API_URL}/api/v1/passenger/bookings/${id}/cancel`,
    JSON.stringify({ reason: 'OTHER', note: 'load-test recycle' }),
    {
      headers,
      tags: { name: 'cancel' },
      responseCallback: http.expectedStatuses(200, 409),
    },
  );
}
