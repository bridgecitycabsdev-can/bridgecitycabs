import { describe, expect, it, vi } from 'vitest';
import { LedgerIntegrityService } from './ledger-integrity.service.js';

describe('LedgerIntegrityService', () => {
  it('passes when the global sum is zero', async () => {
    const prisma = {
      $queryRaw: vi.fn(async () => [{ sum: 0n }]),
    };
    const service = new LedgerIntegrityService(prisma as never);
    await expect(service.check()).resolves.toEqual({ ok: true, sumCents: 0 });
  });

  it('errors when the global sum is non-zero and does not mutate rows', async () => {
    const prisma = {
      $queryRaw: vi.fn(async () => [{ sum: 12n }]),
      ledgerEntry: { deleteMany: vi.fn(), updateMany: vi.fn() },
    };
    const service = new LedgerIntegrityService(prisma as never);
    const logError = vi.spyOn(
      (service as unknown as { logger: { error: (...args: unknown[]) => void } })
        .logger,
      'error',
    );
    await expect(service.check()).resolves.toEqual({ ok: false, sumCents: 12 });
    expect(logError).toHaveBeenCalled();
    expect(prisma.ledgerEntry.deleteMany).not.toHaveBeenCalled();
    expect(prisma.ledgerEntry.updateMany).not.toHaveBeenCalled();
  });
});
