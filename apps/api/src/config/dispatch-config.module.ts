import { Module } from '@nestjs/common';
import { DispatchConfigController } from './dispatch-config.controller.js';

@Module({
  controllers: [DispatchConfigController],
})
export class DispatchConfigModule {}
