import { Module } from '@nestjs/common';
import { LedgerModule } from '../ledger/ledger.module.js';
import { DriverEarningsController } from './driver-earnings.controller.js';
import { FinanceController } from './finance.controller.js';
import { FinanceService } from './finance.service.js';
import { WeeklyClosingService } from './weekly-closing.service.js';

@Module({
  imports: [LedgerModule],
  controllers: [FinanceController, DriverEarningsController],
  providers: [FinanceService, WeeklyClosingService],
  exports: [FinanceService, WeeklyClosingService],
})
export class FinanceModule {}
