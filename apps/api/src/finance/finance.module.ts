import { Module } from '@nestjs/common';
import { LedgerModule } from '../ledger/ledger.module.js';
import { DriverEarningsController } from './driver-earnings.controller.js';
import { FinanceController } from './finance.controller.js';
import { FinanceService } from './finance.service.js';

@Module({
  imports: [LedgerModule],
  controllers: [FinanceController, DriverEarningsController],
  providers: [FinanceService],
  exports: [FinanceService],
})
export class FinanceModule {}
