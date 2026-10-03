import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

/**
 * Global double-entry check: every debit has a credit somewhere.
 * Never mutates money — alert only.
 */
@Injectable()
export class LedgerIntegrityService {
  private readonly logger = new Logger(LedgerIntegrityService.name);

  constructor(private readonly prisma: PrismaService) {}

  async check() {
    const rows = await this.prisma.$queryRaw<[{ sum: bigint | null }]>`
      SELECT COALESCE(SUM("amountCents"), 0)::bigint AS sum FROM "LedgerEntry"
    `;
    const sum = Number(rows[0]?.sum ?? 0n);
    if (sum !== 0) {
      this.logger.error(
        `Ledger integrity failed: SUM(LedgerEntry.amountCents)=${sum} (expected 0). Alert ops — do not auto-correct.`,
      );
      return { ok: false as const, sumCents: sum };
    }
    this.logger.log('Ledger integrity ok: SUM(LedgerEntry.amountCents)=0');
    return { ok: true as const, sumCents: 0 };
  }
}
