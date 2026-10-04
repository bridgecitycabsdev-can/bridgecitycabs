import { Module } from '@nestjs/common';
import { NotificationsModule } from '../notifications/notifications.module.js';
import { SmsModule } from '../sms/sms.module.js';
import { SosController } from './sos.controller.js';
import { SosService } from './sos.service.js';

@Module({
  imports: [NotificationsModule, SmsModule],
  controllers: [SosController],
  providers: [SosService],
  exports: [SosService],
})
export class SosModule {}
