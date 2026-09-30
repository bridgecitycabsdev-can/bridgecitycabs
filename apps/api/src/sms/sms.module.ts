import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ConsoleSmsProvider, UnconfiguredSmsProvider } from './console-sms.provider.js';
import { SMS_PROVIDER } from './sms-provider.js';

@Module({
  providers: [
    ConsoleSmsProvider,
    {
      provide: SMS_PROVIDER,
      inject: [ConfigService, ConsoleSmsProvider],
      useFactory: (config: ConfigService, consoleProvider: ConsoleSmsProvider) => {
        if (config.get<string>('NODE_ENV') === 'production') {
          return new UnconfiguredSmsProvider();
        }
        return consoleProvider;
      },
    },
  ],
  exports: [SMS_PROVIDER],
})
export class SmsModule {}
