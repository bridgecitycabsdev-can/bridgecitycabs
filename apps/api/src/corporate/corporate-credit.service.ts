import {
  ConflictException,
  Injectable,
  UnprocessableEntityException,
} from '@nestjs/common';
import { ApiCode } from '../common/api-code.js';
import { accountsReceivableKey } from '../ledger/account-keys.js';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class CorporateCreditService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Debit-positive AR balance: positive = amount the corporate account currently owes.
   */
  async getAccountReceivableBalance(corporateAccountId: string) {
    const key = accountsReceivableKey(corporateAccountId);
    const sum = await this.prisma.ledgerEntry.aggregate({
      _sum: { amountCents: true },
      where: { account: { key } },
    });
    return sum._sum.amountCents ?? 0;
  }

  /**
   * Rejects inactive accounts and bookings that would push AR over the credit limit.
   * `creditLimitCents === 0` means unlimited (unset), not "zero credit".
   */
  async checkCreditLimit(accountId: string, estimatedTotalCents: number) {
    const account = await this.prisma.corporateAccount.findUniqueOrThrow({
      where: { id: accountId },
    });
    if (!account.active) {
      throw new UnprocessableEntityException({
        code: ApiCode.ACCOUNT_INACTIVE,
        message: 'Corporate account is inactive',
      });
    }
    const current = await this.getAccountReceivableBalance(accountId);
    if (
      account.creditLimitCents > 0 &&
      current + estimatedTotalCents > account.creditLimitCents
    ) {
      throw new ConflictException({
        code: ApiCode.CREDIT_LIMIT_EXCEEDED,
        message: 'Corporate account credit limit exceeded',
        currentCents: current,
        limitCents: account.creditLimitCents,
        requestedCents: estimatedTotalCents,
      });
    }
    return {
      accountId,
      currentCents: current,
      limitCents: account.creditLimitCents,
      requestedCents: estimatedTotalCents,
    };
  }
}
