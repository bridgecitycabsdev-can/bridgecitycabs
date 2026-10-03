import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getMessaging, type Messaging, type MulticastMessage } from 'firebase-admin/messaging';
import type { PushMessage, PushProvider, PushTarget } from './push-provider.js';

const INVALID_TOKEN = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

/**
 * Visible notification + data (not data-only). TTL / collapse keep stale offers
 * from arriving late. Field names match firebase-admin@14 MulticastMessage.
 */
export function toFcmMulticast(tokens: string[], message: PushMessage): MulticastMessage {
  const notification = { title: message.title, body: message.body };
  const ttlMs =
    message.expiresAtMs != null
      ? Math.max(0, message.expiresAtMs - Date.now())
      : undefined;
  const unixExpiry =
    message.expiresAtMs != null
      ? String(Math.floor(message.expiresAtMs / 1000))
      : undefined;

  return {
    tokens,
    notification,
    data: message.data,
    android: {
      priority: message.highPriority ? 'high' : 'normal',
      ...(ttlMs != null ? { ttl: ttlMs } : {}),
      ...(message.collapseKey ? { collapseKey: message.collapseKey } : {}),
      notification: {
        channelId: message.androidChannelId ?? 'default',
        sound: 'default',
      },
    },
    apns: {
      headers: {
        'apns-push-type': 'alert',
        'apns-priority': '10',
        ...(unixExpiry ? { 'apns-expiration': unixExpiry } : {}),
        ...(message.collapseKey
          ? { 'apns-collapse-id': message.collapseKey }
          : {}),
      },
      payload: {
        aps: {
          alert: notification,
          sound: 'default',
          // Requires the Time Sensitive Notifications capability in Xcode.
          ...(message.timeSensitive
            ? { 'interruption-level': 'time-sensitive' }
            : {}),
        },
      },
    },
  };
}

export class FcmProvider implements PushProvider {
  private readonly messaging: Messaging;

  constructor(serviceAccountJson: string) {
    const credential = cert(JSON.parse(serviceAccountJson) as Parameters<typeof cert>[0]);
    const app = getApps()[0] ?? initializeApp({ credential });
    this.messaging = getMessaging(app);
  }

  async send(targets: PushTarget[], message: PushMessage) {
    const invalid: string[] = [];
    const tokens = targets.map((target) => target.token);
    for (let index = 0; index < tokens.length; index += 500) {
      const batch = tokens.slice(index, index + 500);
      const result = await this.messaging.sendEachForMulticast(
        toFcmMulticast(batch, message),
      );
      result.responses.forEach((response, responseIndex) => {
        const code = response.error?.code;
        const token = batch[responseIndex];
        if (code && INVALID_TOKEN.has(code) && token) invalid.push(token);
      });
    }
    return invalid;
  }
}
