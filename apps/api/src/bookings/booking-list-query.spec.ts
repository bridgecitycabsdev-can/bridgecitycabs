import { describe, expect, it, vi } from 'vitest';
import { BookingsService } from './bookings.service.js';

describe('BookingsService.findAll zone', () => {
  function build() {
    const count = vi.fn(async (_query: { where?: { zone?: string; AND?: unknown[] } }) => 0);
    const findMany = vi.fn(async () => []);
    const prisma = {
      booking: { count, findMany },
      $transaction: (ops: Promise<unknown>[]) => Promise.all(ops),
    };
    const service = new BookingsService(
      prisma as never,
      {} as never,
      {} as never,
      { get: () => undefined } as never,
      {} as never,
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

  it('filters by passenger name, phone, tracking id, and driver', async () => {
    const { service, count } = build();
    await service.findAll(user, {
      page: 1,
      pageSize: 20,
      q: ' Amira ',
      phone: '403-555-0100',
      trackingId: 'bc-7k3mq9xt',
      driverId: '11111111-1111-4111-8111-111111111111',
    });
    expect(count).toHaveBeenCalledWith({
      where: expect.objectContaining({
        passengerName: { contains: 'Amira', mode: 'insensitive' },
        passengerPhone: '+14035550100',
        trackingId: 'BC-7K3MQ9XT',
        driverId: '11111111-1111-4111-8111-111111111111',
      }),
    });
  });

  it('normalises phone filters from common Canadian formats', async () => {
    const { service, count } = build();
    for (const phone of ['(403) 555-0100', '14035550100', '+1 403 555 0100']) {
      count.mockClear();
      await service.findAll(user, { page: 1, pageSize: 20, phone });
      expect(count).toHaveBeenCalledWith({
        where: expect.objectContaining({ passengerPhone: '+14035550100' }),
      });
    }
  });

  it('scopes a dispatcher to their branch and lets super_admin pick one', async () => {
    const { service, count } = build();
    await service.findAll(user, { page: 1, pageSize: 20 });
    expect(count).toHaveBeenCalledWith({
      where: expect.objectContaining({ branchId: 'branch-1' }),
    });

    count.mockClear();
    await service.findAll(
      { userId: 'admin', role: 'super_admin', branchId: null },
      { page: 1, pageSize: 20, branchId: 'branch-9' },
    );
    expect(count).toHaveBeenCalledWith({
      where: expect.objectContaining({ branchId: 'branch-9' }),
    });
  });

  it('keeps an ISO instant as the window boundary', async () => {
    const { service, count } = build();
    await service.findAll(user, {
      page: 1,
      pageSize: 20,
      from: '2026-10-02T18:00:00.000Z',
      to: '2026-10-02T19:00:00.000Z',
    });
    const where = count.mock.calls[0]?.[0]?.where as {
      AND: { OR: { scheduledAt: { gte: Date; lte: Date } }[] }[];
    };
    expect(where.AND[0]?.OR[0]?.scheduledAt.gte.toISOString()).toBe(
      '2026-10-02T18:00:00.000Z',
    );
    expect(where.AND[0]?.OR[0]?.scheduledAt.lte.toISOString()).toBe(
      '2026-10-02T19:00:00.000Z',
    );
  });

  it('puts missed jobs and long manual waits on the timeout tab', async () => {
    const { service, count } = build();
    const before = Date.now();
    await service.findAll(user, { page: 1, pageSize: 20, tab: 'timeout' });
    const where = count.mock.calls[0]?.[0]?.where as {
      AND: {
        OR: {
          status?: string;
          assignMode?: string;
          OR?: { searchStartedAt?: { lt: Date } }[];
        }[];
      }[];
    };
    const arms = where.AND[0]?.OR ?? [];
    expect(arms[0]).toEqual({ status: 'NO_DRIVER_FOUND' });
    expect(arms[1]).toMatchObject({
      status: 'SEARCHING_DRIVER',
      assignMode: 'MANUAL',
    });
    const cutoff = arms[1]?.OR?.[0]?.searchStartedAt?.lt.getTime() ?? 0;
    expect(before - cutoff).toBeGreaterThanOrEqual(5 * 60_000 - 1000);
    expect(before - cutoff).toBeLessThanOrEqual(5 * 60_000 + 1000);
  });
});
