import { ConflictException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { SOS_TRIGGERED } from './sos.events.js';
import { SosService } from './sos.service.js';

const care = {
  userId: 'care-1',
  role: 'customer_care',
  branchId: 'branch-1',
};

const alertRow = {
  id: 'sos-1',
  branchId: 'branch-1',
  bookingId: 'b1',
  triggeredByType: 'DRIVER',
  triggeredByUserId: 'driver-user',
  lat: 49.7,
  lng: -112.8,
  status: 'TRIGGERED',
  acknowledgedById: null,
  acknowledgedAt: null,
  resolvedById: null,
  resolvedAt: null,
  resolutionNote: null,
  createdAt: new Date(),
};

describe('SosService', () => {
  it('creates an alert, emits sos.triggered, and SMS when configured', async () => {
    const prisma = {
      booking: {
        findUnique: vi.fn(async () => ({ id: 'b1', branchId: 'branch-1' })),
      },
      sosAlert: { create: vi.fn(async ({ data }) => ({ id: 'sos-1', ...data, ...alertRow, ...data })) },
    };
    const events = { emit: vi.fn() };
    const sms = { sendTransactional: vi.fn(async () => undefined) };
    const service = new SosService(
      prisma as never,
      { get: (k: string) => (k === 'SOS_BRANCH_FALLBACK_PHONE' ? '+14035550999' : undefined) } as never,
      events as never,
      { notify: vi.fn() } as never,
      sms as never,
    );

    await expect(
      service.trigger({
        branchId: 'branch-1',
        bookingId: 'b1',
        triggeredByType: 'DRIVER',
        triggeredByUserId: 'driver-user',
        lat: 49.7,
        lng: -112.8,
      }),
    ).resolves.toMatchObject({ id: 'sos-1', status: 'TRIGGERED' });

    expect(events.emit).toHaveBeenCalledWith(
      SOS_TRIGGERED,
      expect.objectContaining({ id: 'sos-1', branchId: 'branch-1' }),
    );
    expect(sms.sendTransactional).toHaveBeenCalledWith(
      '+14035550999',
      expect.stringContaining('sos-1'),
    );
  });

  it('acknowledges then notifies — never before ACKNOWLEDGED is saved', async () => {
    const order: string[] = [];
    const prisma = {
      sosAlert: {
        findUnique: vi.fn(async () => alertRow),
        update: vi.fn(async ({ data }) => {
          order.push('update');
          return { ...alertRow, ...data, acknowledgedAt: new Date() };
        }),
      },
    };
    const notify = vi.fn(async () => {
      order.push('notify');
      return {};
    });
    const service = new SosService(
      prisma as never,
      { get: () => undefined } as never,
      { emit: vi.fn() } as never,
      { notify } as never,
      { sendTransactional: vi.fn() } as never,
    );

    await expect(service.acknowledge(care, 'sos-1')).resolves.toMatchObject({
      status: 'ACKNOWLEDGED',
    });
    expect(order).toEqual(['update', 'notify']);
    expect(notify).toHaveBeenCalledWith(
      'driver-user',
      'SOS_ACKNOWLEDGED',
      'Dispatch has been notified',
      expect.any(String),
      expect.objectContaining({ alertId: 'sos-1' }),
    );

    prisma.sosAlert.findUnique = vi.fn(async () => ({
      ...alertRow,
      status: 'ACKNOWLEDGED',
    }));
    await expect(service.acknowledge(care, 'sos-1')).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('resolves from TRIGGERED or ACKNOWLEDGED with audit; rejects a second resolve', async () => {
    const make = (status: string) => {
      const tx = {
        sosAlert: {
          update: vi.fn(async ({ data }) => ({
            ...alertRow,
            ...data,
            resolvedAt: new Date(),
          })),
        },
        auditLog: { create: vi.fn(async () => ({})) },
      };
      const prisma = {
        sosAlert: {
          findUnique: vi.fn(async () => ({
            ...alertRow,
            status,
            acknowledgedById: status === 'ACKNOWLEDGED' ? 'care-1' : null,
          })),
        },
        $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      };
      const service = new SosService(
        prisma as never,
        { get: () => undefined } as never,
        { emit: vi.fn() } as never,
        { notify: vi.fn() } as never,
        { sendTransactional: vi.fn() } as never,
      );
      return { service, tx, prisma };
    };

    // Decision: ack is not required — resolve from TRIGGERED is allowed.
    const fromTriggered = make('TRIGGERED');
    await expect(
      fromTriggered.service.resolve(care, 'sos-1', {
        outcome: 'FALSE_ALARM',
        note: 'Accidental press',
      }),
    ).resolves.toMatchObject({ status: 'FALSE_ALARM' });
    expect(fromTriggered.tx.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        entity: 'sos_alert',
        action: 'sos.resolved',
        before: expect.objectContaining({ status: 'TRIGGERED' }),
        after: expect.objectContaining({
          status: 'FALSE_ALARM',
          outcome: 'FALSE_ALARM',
        }),
      }),
    });

    const fromAck = make('ACKNOWLEDGED');
    await expect(
      fromAck.service.resolve(care, 'sos-1', { outcome: 'RESOLVED' }),
    ).resolves.toMatchObject({ status: 'RESOLVED' });

    fromAck.prisma.sosAlert.findUnique = vi.fn(async () => ({
      ...alertRow,
      status: 'RESOLVED',
    }));
    await expect(
      fromAck.service.resolve(care, 'sos-1', { outcome: 'RESOLVED' }),
    ).rejects.toBeInstanceOf(ConflictException);
  });

  it('lists branch-scoped alerts for staff', async () => {
    const prisma = {
      $transaction: vi.fn(async (ops: Promise<unknown>[]) => Promise.all(ops)),
      sosAlert: {
        count: vi.fn(async () => 1),
        findMany: vi.fn(async () => [alertRow]),
      },
    };
    const service = new SosService(
      prisma as never,
      { get: () => undefined } as never,
      { emit: vi.fn() } as never,
      { notify: vi.fn() } as never,
      { sendTransactional: vi.fn() } as never,
    );
    await expect(
      service.list(care, { page: 1, pageSize: 20, status: 'TRIGGERED' }),
    ).resolves.toMatchObject({ meta: { total: 1 } });
    expect(prisma.sosAlert.count).toHaveBeenCalledWith({
      where: { branchId: 'branch-1', status: 'TRIGGERED' },
    });
  });
});
