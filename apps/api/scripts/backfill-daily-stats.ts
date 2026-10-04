/**
 * Populate DailyBranchStat for calendar days before the nightly rollup existed.
 *
 * Usage (from apps/api):
 *   pnpm exec tsx scripts/backfill-daily-stats.ts --branch <id> --from 2026-09-01 --to 2026-10-03
 */
import { PrismaClient } from '@prisma/client';
import { DailyStatsService } from '../src/reporting/daily-stats.service.js';
import { loadEnvFile } from './load-env.js';

loadEnvFile();

const branchId = flag('branch');
const from = flag('from');
const to = flag('to');
if (!branchId || !from || !to) {
  console.error(
    'Usage: pnpm exec tsx scripts/backfill-daily-stats.ts --branch <id> --from YYYY-MM-DD --to YYYY-MM-DD',
  );
  process.exit(1);
}
if (!/^\d{4}-\d{2}-\d{2}$/.test(from) || !/^\d{4}-\d{2}-\d{2}$/.test(to)) {
  console.error('--from and --to must be YYYY-MM-DD');
  process.exit(1);
}

const prisma = new PrismaClient();
const service = new DailyStatsService(prisma);

try {
  const branch = await prisma.branch.findUnique({
    where: { id: branchId },
    select: { id: true, name: true, timezone: true },
  });
  if (!branch) {
    console.error(`Branch ${branchId} not found`);
    process.exit(1);
  }
  const timezone = branch.timezone?.trim() || 'America/Edmonton';
  const result = await service.backfill(branch.id, from, to, timezone);
  console.log(
    `Backfilled ${result.days} day(s) for ${branch.name} (${timezone}) ${from} → ${to}`,
  );
} finally {
  await prisma.$disconnect();
}

function flag(name: string) {
  const index = process.argv.indexOf(`--${name}`);
  if (index === -1) return undefined;
  const value = process.argv[index + 1];
  if (!value || value.startsWith('--')) {
    throw new Error(`--${name} needs a value`);
  }
  return value;
}
