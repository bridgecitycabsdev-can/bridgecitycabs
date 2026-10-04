import { Module } from '@nestjs/common';
import { LedgerModule } from '../ledger/ledger.module.js';
import { PdfModule } from '../pdf/pdf.module.js';
import { StorageModule } from '../storage/storage.module.js';
import { DriverEarningsController } from './driver-earnings.controller.js';
import { FinanceController } from './finance.controller.js';
import { FinanceService } from './finance.service.js';
import { InvoiceService } from './invoice.service.js';
import { WeeklyClosingService } from './weekly-closing.service.js';

@Module({
  imports: [LedgerModule, PdfModule, StorageModule],
  controllers: [FinanceController, DriverEarningsController],
  providers: [FinanceService, WeeklyClosingService, InvoiceService],
  exports: [FinanceService, WeeklyClosingService, InvoiceService],
})
export class FinanceModule {}
