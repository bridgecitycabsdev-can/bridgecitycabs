import { Injectable } from '@nestjs/common';
import type { AccountType, LedgerKind, Prisma } from '@prisma/client';

export type LedgerPostLine = {
  accountKey: string;
  type: AccountType;
  ownerId?: string;
  amountCents: number;
};

export type LedgerPostInput = {
  kind: LedgerKind;
  sourceType: string;
  sourceId: string;
  branchId: string;
  description?: string;
  createdById?: string;
  reversalOfId?: string;
  lines: LedgerPostLine[];
};

/** Sole writer for ledger rows. Callers must pass an open Prisma transaction. */
@Injectable()
export class LedgerService {
  async post(tx: Prisma.TransactionClient, p: LedgerPostInput) {
    // Idempotent: a second call for the same (sourceType, sourceId, kind) returns the first.
    // Concurrent losers hit the unique constraint and roll back the outer transaction.
    const existing = await tx.ledgerTransaction.findUnique({
      where: {
        sourceType_sourceId_kind: {
          sourceType: p.sourceType,
          sourceId: p.sourceId,
          kind: p.kind,
        },
      },
    });
    if (existing) return existing;

    const txn = await tx.ledgerTransaction.create({
      data: {
        kind: p.kind,
        sourceType: p.sourceType,
        sourceId: p.sourceId,
        branchId: p.branchId,
        description: p.description,
        createdById: p.createdById,
        reversalOfId: p.reversalOfId,
      },
    });

    for (const line of p.lines) {
      const acct = await tx.financialAccount.upsert({
        where: { key: line.accountKey },
        update: {},
        create: {
          key: line.accountKey,
          type: line.type,
          branchId: p.branchId,
          ownerId: line.ownerId,
        },
      });
      await tx.ledgerEntry.create({
        data: {
          transactionId: txn.id,
          accountId: acct.id,
          amountCents: line.amountCents,
        },
      });
    }

    return txn;
  }
}
