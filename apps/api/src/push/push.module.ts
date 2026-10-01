import { Logger, Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ConsolePushProvider } from './console-push.provider.js';
import { FcmProvider } from './fcm-push.provider.js';
import { PUSH_PROVIDER, type PushProvider } from './push-provider.js';
import { PushService } from './push.service.js';

@Module({
  providers: [
    ConsolePushProvider,
    {
      provide: PUSH_PROVIDER,
      inject: [ConfigService, ConsolePushProvider],
      useFactory: (config: ConfigService, consolePush: ConsolePushProvider): PushProvider => {
        const raw = config.get<string>('FIREBASE_SERVICE_ACCOUNT_JSON')?.trim();
        if (!raw) {
          if (config.get<string>('NODE_ENV') === 'production') {
            new Logger('PushModule').warn(
              'FIREBASE_SERVICE_ACCOUNT_JSON is empty; pushes are logged instead of sent',
            );
          }
          return consolePush;
        }
        return new FcmProvider(raw);
      },
    },
    PushService,
  ],
  exports: [PushService],
})
export class PushModule {}
