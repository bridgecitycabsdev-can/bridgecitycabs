/**
 * Strip real PII from a staging database after a Neon branch / restore that
 * carried production-shaped data. Schema-only branches need no sanitization;
 * anything with real phones, documents, or payment refs must run this before
 * staging is reachable.
 *
 * Usage (from apps/api), pointed at STAGING only:
 *   DATABASE_URL="postgresql://..." pnpm exec tsx scripts/sanitize-staging.ts --confirm-staging
 *
 * Requires a role that can UPDATE ordinary tables and briefly disable
 * append-only triggers (provider admin / migrator). Never the app DML role alone.
 * Refuses to run unless DATABASE_URL looks non-production.
 */
import { PrismaClient } from '@prisma/client';
import { createHash } from 'node:crypto';
import { loadEnvFile } from './load-env.js';

loadEnvFile();

if (!process.argv.includes('--confirm-staging')) {
  console.error(
    'Refusing to run without --confirm-staging. Point DATABASE_URL at staging first.',
  );
  process.exit(1);
}

const databaseUrl = process.env.DATABASE_URL?.trim() ?? '';
if (!databaseUrl) {
  console.error('DATABASE_URL is required');
  process.exit(1);
}
assertStagingUrl(databaseUrl);

const prisma = new PrismaClient();

try {
  const users = await prisma.user.findMany({ select: { id: true } });
  for (const u of users) {
    const n = shortHash(u.id);
    await prisma.user.update({
      where: { id: u.id },
      data: {
        email: `user-${n}@example.invalid`,
        phone: syntheticPhone(u.id, 1),
        displayName: `Staging User ${n}`,
        passwordHash: null,
      },
    });
  }
  console.log(`Sanitized ${users.length} users`);

  const drivers = await prisma.driver.findMany({ select: { id: true } });
  for (const d of drivers) {
    const n = shortHash(d.id);
    await prisma.driver.update({
      where: { id: d.id },
      data: {
        firstName: 'Staging',
        lastName: `Driver ${n}`,
        phone: syntheticPhone(d.id, 2),
      },
    });
  }
  console.log(`Sanitized ${drivers.length} drivers`);

  const passengers = await prisma.passenger.findMany({ select: { id: true } });
  for (const p of passengers) {
    const n = shortHash(p.id);
    await prisma.passenger.update({
      where: { id: p.id },
      data: {
        firstName: 'Staging',
        lastName: `Passenger ${n}`,
        phone: syntheticPhone(p.id, 3),
        email: `passenger-${n}@example.invalid`,
      },
    });
  }
  console.log(`Sanitized ${passengers.length} passengers`);

  const bookings = await prisma.booking.updateMany({
    data: {
      passengerName: 'Staging Passenger',
      passengerPhone: '+15550000000',
    },
  });
  console.log(`Sanitized ${bookings.count} booking snapshots`);

  const contacts = await prisma.corporateAccountContact.findMany({
    select: { id: true },
  });
  for (const c of contacts) {
    const n = shortHash(c.id);
    await prisma.corporateAccountContact.update({
      where: { id: c.id },
      data: {
        name: `Staging Contact ${n}`,
        phone: syntheticPhone(c.id, 4),
        email: `contact-${n}@example.invalid`,
      },
    });
  }
  console.log(`Sanitized ${contacts.length} corporate contacts`);

  const accounts = await prisma.corporateAccount.updateMany({
    data: {
      billingEmail: 'billing@example.invalid',
      billingAddress: '100 Staging St',
      gstNumber: null,
      notes: null,
    },
  });
  console.log(`Sanitized ${accounts.count} corporate accounts`);

  const docs = await prisma.document.findMany({ select: { id: true } });
  for (const doc of docs) {
    await prisma.document.update({
      where: { id: doc.id },
      data: {
        storageKey: `sanitized/documents/${doc.id}`,
        rejectionNote: null,
      },
    });
  }
  console.log(`Sanitized ${docs.length} document storage keys`);

  const payments = await prisma.payment.updateMany({
    data: { providerRef: null, idempotencyKey: null },
  });
  console.log(`Cleared ${payments.count} payment provider refs`);

  const payouts = await prisma.driverPayout.updateMany({
    data: { reference: null, failureNote: null },
  });
  console.log(`Cleared ${payouts.count} payout references`);

  // Unique Stripe ids — replace with deterministic fakes so uniqueness holds.
  const pms = await prisma.passengerPaymentMethod.findMany({
    select: { id: true },
  });
  for (const pm of pms) {
    await prisma.passengerPaymentMethod.update({
      where: { id: pm.id },
      data: {
        stripePmId: `pm_staging_${shortHash(pm.id)}`,
        last4: '0000',
        brand: 'visa',
      },
    });
  }
  console.log(`Sanitized ${pms.length} saved payment methods`);

  const customers = await prisma.stripeCustomer.findMany({ select: { id: true } });
  for (const c of customers) {
    await prisma.stripeCustomer.update({
      where: { id: c.id },
      data: { stripeCustomerId: `cus_staging_${shortHash(c.id)}` },
    });
  }
  console.log(`Sanitized ${customers.length} Stripe customers`);

  // Sessions / push targets must not work against real devices.
  const [refresh, devices] = await Promise.all([
    prisma.refreshToken.deleteMany(),
    prisma.deviceToken.deleteMany(),
  ]);
  console.log(
    `Deleted ${refresh.count} refresh tokens, ${devices.count} device tokens`,
  );

  // Append-only tables that may hold PII — truncate via trigger bypass (owner).
  await prisma.$executeRawUnsafe(
    'ALTER TABLE "AuditLog" DISABLE TRIGGER USER',
  );
  await prisma.$executeRawUnsafe('TRUNCATE TABLE "AuditLog"');
  await prisma.$executeRawUnsafe(
    'ALTER TABLE "AuditLog" ENABLE TRIGGER USER',
  );
  console.log('Truncated AuditLog');

  await prisma.$executeRawUnsafe(
    'ALTER TABLE "SupportTicketMessage" DISABLE TRIGGER USER',
  );
  await prisma.$executeRawUnsafe('TRUNCATE TABLE "SupportTicketMessage"');
  await prisma.$executeRawUnsafe(
    'ALTER TABLE "SupportTicketMessage" ENABLE TRIGGER USER',
  );
  console.log('Truncated SupportTicketMessage');

  await prisma.webhookEvent.deleteMany();
  console.log('Deleted WebhookEvent payloads');

  console.log('Staging sanitization complete.');
} finally {
  await prisma.$disconnect();
}

function assertStagingUrl(url: string) {
  const lower = url.toLowerCase();
  const blocked = [
    'bridgecabs-production',
    'api.bridgecitycabs.com',
    'neon.tech/production',
  ];
  if (blocked.some((b) => lower.includes(b))) {
    console.error(
      'DATABASE_URL looks like production. Refusing to sanitize. Use a staging URL.',
    );
    process.exit(1);
  }
  if (
    !lower.includes('staging') &&
    !lower.includes('localhost') &&
    !lower.includes('127.0.0.1') &&
    !process.argv.includes('--allow-nonstaging-name')
  ) {
    console.error(
      'DATABASE_URL does not contain "staging" (or localhost). Re-check the target, or pass --allow-nonstaging-name if intentional.',
    );
    process.exit(1);
  }
}

function shortHash(id: string) {
  return createHash('sha256').update(id).digest('hex').slice(0, 8);
}

/** North American fictional 555 numbers, unique per id + bucket. */
function syntheticPhone(id: string, bucket: number) {
  const n = Number.parseInt(shortHash(`${bucket}:${id}`).slice(0, 7), 16) % 10_000_000;
  return `+1555${String(n).padStart(7, '0')}`;
}
