export type PushTarget = {
  token: string;
  platform: string;
};

export type PushMessage = {
  title: string;
  body: string;
  data: Record<string, string>;
  /** FCM delivery priority. Offer alerts are high so a locked phone still wakes. */
  highPriority: boolean;
  /** iOS time-sensitive alert. Silent data-only pushes are unreliable there. */
  timeSensitive: boolean;
  /** Android channel for the system notification (offers use `offers`). */
  androidChannelId?: string;
  /** Collapse / replace prior notifications for the same offer. */
  collapseKey?: string;
  /** Drop the message if undelivered by this Unix second (APNs) / ms TTL (Android). */
  expiresAtMs?: number;
};

export interface PushProvider {
  /** Returns tokens FCM reported as unregistered or invalid. */
  send(targets: PushTarget[], message: PushMessage): Promise<string[]>;
}

export const PUSH_PROVIDER = Symbol('PUSH_PROVIDER');
