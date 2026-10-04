import { Module } from '@nestjs/common';
import { CorporateAccountGroupsController } from './corporate-account-groups.controller.js';
import { CorporateAccountGroupsService } from './corporate-account-groups.service.js';
import { CorporateAccountsController } from './corporate-accounts.controller.js';
import { CorporateAccountsService } from './corporate-accounts.service.js';
import { CorporateCreditService } from './corporate-credit.service.js';

@Module({
  controllers: [
    CorporateAccountsController,
    CorporateAccountGroupsController,
  ],
  providers: [
    CorporateCreditService,
    CorporateAccountsService,
    CorporateAccountGroupsService,
  ],
  exports: [CorporateCreditService, CorporateAccountsService],
})
export class CorporateModule {}
