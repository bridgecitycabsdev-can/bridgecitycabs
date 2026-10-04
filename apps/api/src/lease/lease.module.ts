import { Module } from '@nestjs/common';
import { LedgerModule } from '../ledger/ledger.module.js';
import { LeaseAgreementsController } from './lease-agreements.controller.js';
import { LeaseAgreementsService } from './lease-agreements.service.js';
import { LeaseDeductionService } from './lease-deduction.service.js';

@Module({
  imports: [LedgerModule],
  controllers: [LeaseAgreementsController],
  providers: [LeaseAgreementsService, LeaseDeductionService],
  exports: [LeaseDeductionService, LeaseAgreementsService],
})
export class LeaseModule {}
