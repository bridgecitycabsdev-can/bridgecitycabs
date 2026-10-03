/**
 * Send a real offer push through PushService (FCM when FIREBASE_SERVICE_ACCOUNT_JSON
 * is set, otherwise the console provider).
 *
 * Usage (from apps/api):
 *   pnpm exec tsx scripts/send-test-push.ts <userId>
 *   pnpm exec tsx scripts/send-test-push.ts <userId> --ttl-seconds 30
 */
import { randomUUID } from 'node:crypto';
import { PrismaClient } from '@prisma/client';
import { loadEnvFile } from './load-env.js';
import { ConsolePushProvider } from '../src/push/console-push.provider.js';
import { FcmProvider } from '../src/push/fcm-push.provider.js';
import {
  offerNotification,
  OFFER_PUSH_BODY,
  OFFER_PUSH_TITLE,
  PushService,
} from '../src/push/push.service.js';

async function main() {
  loadEnvFile();

  const userId = process.argv[2];
  if (!userId || userId.startsWith('--')) {
    console.error(
      'Usage: pnpm exec tsx scripts/send-test-push.ts <userId> [--ttl-seconds 30]',
    );
    process.exit(1);
  }

  const ttlSeconds = readTtlSeconds();
  const offerId = randomUUID();
  const expiresAt = new Date(Date.now() + ttlSeconds * 1000).toISOString();
  const message = offerNotification({
    type: 'OFFER',
    offerId,
    expiresAt,
  });

  const prisma = new PrismaClient();
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON?.trim();
  const provider = raw ? new FcmProvider(raw) : new ConsolePushProvider();
  const push = new PushService(prisma, provider);

  try {
    const tokens = await prisma.deviceToken.findMany({
      where: { userId, revokedAt: null },
      select: { token: true, platform: true },
    });
    if (!tokens.length) {
      console.error(`No active device tokens for user ${userId}`);
      process.exit(2);
    }

    console.log(
      `Sending offer push to ${tokens.length} device(s) for ${userId}\n` +
        `  title=${OFFER_PUSH_TITLE}\n` +
        `  body=${OFFER_PUSH_BODY}\n` +
        `  offerId=${offerId}\n` +
        `  expiresAt=${expiresAt}\n` +
        `  ttlSeconds≈${ttlSeconds}\n` +
        `  channel=${message.androidChannelId}\n` +
        `  collapseKey=${message.collapseKey}\n` +
        `  provider=${raw ? 'FCM' : 'console'}\n` +
        `  platforms=${tokens.map((t) => t.platform).join(',')}`,
    );

    await push.sendOffer(userId, { type: 'OFFER', offerId, expiresAt });
    console.log(
      'PushService.sendOffer finished (invalid tokens soft-revoked if FCM rejected them).',
    );
  } finally {
    await prisma.$disconnect();
  }
}

function readTtlSeconds() {
  const index = process.argv.indexOf('--ttl-seconds');
  if (index === -1) return 30;
  const value = Number(process.argv[index + 1]);
  if (!Number.isFinite(value) || value <= 0) {
    throw new Error('--ttl-seconds must be a positive number');
  }
  return value;
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
});
