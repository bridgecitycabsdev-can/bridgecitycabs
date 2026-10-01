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
};

export interface PushProvider {
  /** Returns tokens FCM reported as invalid. */
  send(targets: PushTarget[], message: PushMessage): Promise<string[]>;
}

export const PUSH_PROVIDER = Symbol('PUSH_PROVIDER');
