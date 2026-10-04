import { Injectable, Logger } from '@nestjs/common';
import { LedgerService } from '../ledger/ledger.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { startOfBranchWeek } from './lease-week.js';

/**
 * Posts one LEASE_DEDUCTION per active agreement for the branch-local week.
 * Idempotent via LedgerTransaction (sourceType, sourceId, kind).
 */
@Injectable()
export class LeaseDeductionService {
  private readonly logger = new Logger(LeaseDeductionService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: LedgerService,
  ) {}

  /** Run for leases whose branch timezone matches (or all if timezone omitted). */
  async run(input: { timezone?: string; now?: Date } = {}) {
    const now = input.now ?? new Date();
    const leases = await this.prisma.leaseAgreement.findMany({
      where: {
        active: true,
        startDate: { lte: now },
        OR: [{ endDate: null }, { endDate: { gt: now } }],
        ...(input.timezone
          ? { driver: { branch: { timezone: input.timezone } } }
          : {}),
      },
      include: {
        driver: {
          select: {
            id: true,
            branchId: true,
            branch: { select: { id: true, timezone: true } },
          },
        },
      },
    });

    let posted = 0;
    for (const lease of leases) {
      const weekStart = startOfBranchWeek(lease.driver.branch.timezone, now);
      if (lease.startDate > weekStart) continue;

      const sourceId = `${lease.id}:${weekStart.toISOString()}`;
      await this.prisma.$transaction(async (tx) => {
        // Debit DRIVER_BALANCE (driver owes company); credit LEASE_RECEIVABLE.
        // Signs follow Day 9: debit positive.
        await this.ledger.post(tx, {
          kind: 'LEASE_DEDUCTION',
          sourceType: 'LEASE_WEEK',
          sourceId,
          branchId: lease.driver.branchId,
          description: `Lease deduction week of ${weekStart.toDateString()}`,
          lines: [
            {
              accountKey: `DRIVER_BALANCE:${lease.driverId}`,
              type: 'DRIVER_BALANCE',
              ownerId: lease.driverId,
              amountCents: lease.weeklyAmountCents,
            },
            {
              accountKey: `LEASE_RECEIVABLE:${lease.driver.branchId}`,
              type: 'COMPANY_REVENUE',
              amountCents: -lease.weeklyAmountCents,
            },
          ],
        });
      });
      posted += 1;
    }

    this.logger.log(
      `Lease deductions: ${posted}/${leases.length} agreement(s)` +
        (input.timezone ? ` tz=${input.timezone}` : ''),
    );
    return { considered: leases.length, posted };
  }
}
