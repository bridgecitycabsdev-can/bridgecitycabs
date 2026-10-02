import { describe, expect, it, vi } from 'vitest';
import { BookingsService } from './bookings.service.js';

describe('BookingsService.findAll zone', () => {
  function build() {
    const count = vi.fn(async () => 0);
    const findMany = vi.fn(async () => []);
    const prisma = {
      booking: { count, findMany },
      $transaction: (ops: Promise<unknown>[]) => Promise.all(ops),
    };
    const service = new BookingsService(
      prisma as never,
      {} as never,
      {} as never,
      {} as never,
      {} as never,
      {} as never,
      {} as never,
      {} as never,
    );
    return { service, count };
  }

  const user = { userId: 'user-1', role: 'dispatcher', branchId: 'branch-1' };

  it('limits the list to the requested zone', async () => {
    const { service, count } = build();
    await service.findAll(user, { page: 1, pageSize: 20, zone: 'OUT_OF_TOWN' });
    expect(count).toHaveBeenCalledWith({
      where: expect.objectContaining({ branchId: 'branch-1', zone: 'OUT_OF_TOWN' }),
    });
  });

  it('leaves zone off the query when the panel asks for every booking', async () => {
    const { service, count } = build();
    await service.findAll(user, { page: 1, pageSize: 20 });
    const where = count.mock.calls[0]?.[0]?.where as { zone?: string };
    expect(where.zone).toBeUndefined();
  });
});
