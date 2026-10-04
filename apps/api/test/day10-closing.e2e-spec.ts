import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { ConflictException } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { WeeklyClosingService } from '../src/finance/weekly-closing.service.js';
import {
  companyRevenueKey,
  driverBalanceKey,
} from '../src/ledger/account-keys.js';
import { LedgerService } from '../src/ledger/ledger.service.js';
import { assertIsolatedTestEnv } from './test-env.js';

loadEnvFile();
assertIsolatedTestEnv();

const prisma = new PrismaClient();
const stamp = Date.now();

describe('day10 weekly closing (e2e)', () => {
  const ledger = new LedgerService();
  const closing = new WeeklyClosingService(prisma);
  let branchId = '';
  let driverId = '';
  let userId = '';
  const weekStart = new Date('2026-09-21T06:00:00.000Z');
  const weekEnd = new Date('2026-09-28T06:00:00.000Z');
  /** Mid-week posting instant inside [weekStart, weekEnd). */
  const midWeek = new Date('2026-09-24T12:00:00.000Z');

  beforeAll(async () => {
    const branch = await prisma.branch.create({
      data: {
        name: `E2E Closing ${stamp}`,
        city: 'Lethbridge',
        timezone: 'America/Edmonton',
        gstRateBps: 500,
        commissionBps: 0,
      },
    });
    branchId = branch.id;

    const role = await prisma.role.upsert({
      where: { name: 'driver' },
      update: {},
      create: { name: 'driver' },
    });
    const user = await prisma.user.create({
      data: {
        email: `e2e-closing-${stamp}@example.com`,
        roleId: role.id,
        branchId,
      },
    });
    userId = user.id;
    const driver = await prisma.driver.create({
      data: {
        userId: user.id,
        branchId,
        firstName: 'Close',
        lastName: 'Test',
        phone: `+1403${String(stamp).slice(-7)}`,
        status: 'APPROVED',
        approvedAt: new Date(),
      },
    });
    driverId = driver.id;

    // Known postings: debit DRIVER_BALANCE 1000, credit COMPANY_REVENUE -1000.
    await prisma.$transaction(async (tx) => {
      await ledger.post(tx, {
        kind: 'ADJUSTMENT',
        sourceType: 'TEST',
        sourceId: `closing-open-${stamp}`,
        branchId,
        description: 'opening before week',
        lines: [
          {
            accountKey: driverBalanceKey(driverId),
            type: 'DRIVER_BALANCE',
            ownerId: driverId,
            amountCents: 200,
          },
          {
            accountKey: companyRevenueKey(branchId),
            type: 'COMPANY_REVENUE',
            amountCents: -200,
          },
        ],
      });
    });
    // Backdate opening txn before weekStart.
    await prisma.$executeRawUnsafe(
      'ALTER TABLE "LedgerTransaction" DISABLE TRIGGER ledger_txn_immutable',
    );
    await prisma.$executeRawUnsafe(
      'ALTER TABLE "LedgerEntry" DISABLE TRIGGER ledger_entry_immutable',
    );
    try {
      await prisma.ledgerTransaction.updateMany({
        where: { sourceType: 'TEST', sourceId: `closing-open-${stamp}` },
        data: { createdAt: new Date('2026-09-14T12:00:00.000Z') },
      });
      await prisma.ledgerEntry.updateMany({
        where: {
          transaction: {
            sourceType: 'TEST',
            sourceId: `closing-open-${stamp}`,
          },
        },
        data: { createdAt: new Date('2026-09-14T12:00:00.000Z') },
      });
    } finally {
      await prisma.$executeRawUnsafe(
        'ALTER TABLE "LedgerEntry" ENABLE TRIGGER ledger_entry_immutable',
      );
      await prisma.$executeRawUnsafe(
        'ALTER TABLE "LedgerTransaction" ENABLE TRIGGER ledger_txn_immutable',
      );
    }

    await prisma.$transaction(async (tx) => {
      await ledger.post(tx, {
        kind: 'ADJUSTMENT',
        sourceType: 'TEST',
        sourceId: `closing-week-${stamp}`,
        branchId,
        description: 'in-week movement',
        lines: [
          {
            accountKey: driverBalanceKey(driverId),
            type: 'DRIVER_BALANCE',
            ownerId: driverId,
            amountCents: 1000,
          },
          {
            accountKey: companyRevenueKey(branchId),
            type: 'COMPANY_REVENUE',
            amountCents: -1000,
          },
        ],
      });
    });
    await prisma.$executeRawUnsafe(
      'ALTER TABLE "LedgerTransaction" DISABLE TRIGGER ledger_txn_immutable',
    );
    await prisma.$executeRawUnsafe(
      'ALTER TABLE "LedgerEntry" DISABLE TRIGGER ledger_entry_immutable',
    );
    try {
      await prisma.ledgerTransaction.updateMany({
        where: { sourceType: 'TEST', sourceId: `closing-week-${stamp}` },
        data: { createdAt: midWeek },
      });
      await prisma.ledgerEntry.updateMany({
        where: {
          transaction: {
            sourceType: 'TEST',
            sourceId: `closing-week-${stamp}`,
          },
        },
        data: { createdAt: midWeek },
      });
    } finally {
      await prisma.$executeRawUnsafe(
        'ALTER TABLE "LedgerEntry" ENABLE TRIGGER ledger_entry_immutable',
      );
      await prisma.$executeRawUnsafe(
        'ALTER TABLE "LedgerTransaction" ENABLE TRIGGER ledger_txn_immutable',
      );
    }
  }, 60_000);

  afterAll(async () => {
    const periods = await prisma.closingPeriod.findMany({
      where: { branchId },
      select: { id: true },
    });
    const periodIds = periods.map((p) => p.id);
    if (periodIds.length) {
      await prisma.$executeRawUnsafe(
        'ALTER TABLE "ClosingLine" DISABLE TRIGGER closing_line_immutable',
      );
      try {
        await prisma.closingLine.deleteMany({
          where: { closingPeriodId: { in: periodIds } },
        });
      } finally {
        await prisma.$executeRawUnsafe(
          'ALTER TABLE "ClosingLine" ENABLE TRIGGER closing_line_immutable',
        );
      }
      await prisma.closingPeriod.deleteMany({ where: { id: { in: periodIds } } });
    }

    await prisma.$executeRawUnsafe(
      'ALTER TABLE "LedgerEntry" DISABLE TRIGGER ledger_entry_immutable',
    );
    await prisma.$executeRawUnsafe(
      'ALTER TABLE "LedgerTransaction" DISABLE TRIGGER ledger_txn_immutable',
    );
    try {
      const txns = await prisma.ledgerTransaction.findMany({
        where: { branchId, sourceType: 'TEST' },
        select: { id: true },
      });
      const txnIds = txns.map((t) => t.id);
      if (txnIds.length) {
        await prisma.ledgerEntry.deleteMany({
          where: { transactionId: { in: txnIds } },
        });
        await prisma.ledgerTransaction.deleteMany({
          where: { id: { in: txnIds } },
        });
      }
    } finally {
      await prisma.$executeRawUnsafe(
        'ALTER TABLE "LedgerTransaction" ENABLE TRIGGER ledger_txn_immutable',
      );
      await prisma.$executeRawUnsafe(
        'ALTER TABLE "LedgerEntry" ENABLE TRIGGER ledger_entry_immutable',
      );
    }

    await prisma.financialAccount.deleteMany({ where: { branchId } });
    await prisma.driver.deleteMany({ where: { id: driverId } });
    await prisma.user.deleteMany({ where: { id: userId } });
    await prisma.branch.deleteMany({ where: { id: branchId } });
    await prisma.$disconnect();
  }, 60_000);

  it('reconciles movementCents to a hand SUM and locks FINALIZED lines', async () => {
    const first = await closing.closeWeek(branchId, weekStart, weekEnd, userId);
    const second = await closing.closeWeek(branchId, weekStart, weekEnd, userId);

    expect(first.status).toBe('DRAFT');
    expect(second.status).toBe('DRAFT');
    const stripIds = (lines: typeof first.lines) =>
      lines.map(({ id: _id, ...rest }) => rest);
    expect(stripIds(second.lines)).toEqual(stripIds(first.lines));

    const driverLine = second.lines.find(
      (l) => l.accountKey === driverBalanceKey(driverId),
    );
    expect(driverLine).toBeDefined();

    const account = await prisma.financialAccount.findFirstOrThrow({
      where: { branchId, key: driverBalanceKey(driverId) },
    });
    const openingAgg = await prisma.ledgerEntry.aggregate({
      where: { accountId: account.id, createdAt: { lt: weekStart } },
      _sum: { amountCents: true },
    });
    const throughAgg = await prisma.ledgerEntry.aggregate({
      where: { accountId: account.id, createdAt: { lt: weekEnd } },
      _sum: { amountCents: true },
    });
    const opening = openingAgg._sum.amountCents ?? 0;
    const through = throughAgg._sum.amountCents ?? 0;
    const handMovement = -(through - opening);

    expect(opening).toBe(200);
    expect(through).toBe(1200);
    expect(driverLine!.openingCents).toBe(-opening);
    expect(driverLine!.movementCents).toBe(handMovement);
    expect(driverLine!.closingCents).toBe(-through);
    expect(driverLine!.movementCents).toBe(-1000);

    const finalized = await closing.finalize(
      { userId, role: 'accounts_admin', branchId },
      first.id,
    );
    expect(finalized.status).toBe('FINALIZED');

    await expect(
      closing.finalize(
        { userId, role: 'accounts_admin', branchId },
        first.id,
      ),
    ).rejects.toBeInstanceOf(ConflictException);

    await expect(
      closing.closeWeek(branchId, weekStart, weekEnd, userId),
    ).rejects.toBeInstanceOf(ConflictException);

    const lineId = driverLine!.id;
    await expect(
      prisma.$executeRaw`UPDATE "ClosingLine" SET "movementCents" = 0 WHERE "id" = ${lineId}`,
    ).rejects.toThrow(/immutable once finalized/);
  }, 60_000);
});

function loadEnvFile() {
  const contents = readFileSync(resolve(process.cwd(), '.env'), 'utf8');
  for (const rawLine of contents.split(/\r?\n/)) {
    const line = rawLine.trim();
    if (!line || line.startsWith('#')) continue;
    const separator = line.indexOf('=');
    if (separator === -1) continue;
    const key = line.slice(0, separator).trim();
    if (process.env[key] !== undefined) continue;
    let value = line.slice(separator + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    process.env[key] = value;
  }
}
