import { Module } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { ConsoleSmsProvider } from './console-sms.provider.js';
import { selectSmsProvider } from './select-sms-provider.js';
import { SMS_PROVIDER } from './sms-provider.js';

@Module({
  providers: [
    ConsoleSmsProvider,
    {
      provide: SMS_PROVIDER,
      inject: [ConfigService, ConsoleSmsProvider],
      useFactory: (config: ConfigService, consoleProvider: ConsoleSmsProvider) =>
        selectSmsProvider(
          {
            NODE_ENV: config.get<string>('NODE_ENV'),
            TWILIO_ACCOUNT_SID: config.get<string>('TWILIO_ACCOUNT_SID'),
            TWILIO_AUTH_TOKEN: config.get<string>('TWILIO_AUTH_TOKEN'),
            TWILIO_FROM_NUMBER: config.get<string>('TWILIO_FROM_NUMBER'),
          },
          consoleProvider,
        ),
    },
  ],
  exports: [SMS_PROVIDER],
})
export class SmsModule {}
