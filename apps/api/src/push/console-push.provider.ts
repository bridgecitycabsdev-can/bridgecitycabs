import { Injectable, Logger } from '@nestjs/common';
import type { PushMessage, PushProvider, PushTarget } from './push-provider.js';

@Injectable()
export class ConsolePushProvider implements PushProvider {
  private readonly logger = new Logger(ConsolePushProvider.name);

  async send(targets: PushTarget[], message: PushMessage) {
    const platforms = targets.map((target) => target.platform).join(', ') || 'none';
    this.logger.log(
      `Push "${message.title}" to ${targets.length} device(s) [${platforms}] ${JSON.stringify(message.data)}`,
    );
    return [];
  }
}
