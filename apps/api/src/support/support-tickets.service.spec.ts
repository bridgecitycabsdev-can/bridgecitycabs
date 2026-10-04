import { ConflictException, ForbiddenException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { ApiCode } from '../common/api-code.js';
import { SupportTicketsService } from './support-tickets.service.js';

const passenger = {
  userId: 'pass-user',
  role: 'passenger',
  branchId: 'branch-1',
};
const care = {
  userId: 'care-1',
  role: 'customer_care',
  branchId: 'branch-1',
};
const admin = {
  userId: 'admin-1',
  role: 'branch_admin',
  branchId: 'branch-1',
};

function detail(overrides: Record<string, unknown> = {}) {
  return {
    id: 't1',
    number: 'TCK-00001',
    branchId: 'branch-1',
    raisedByType: 'PASSENGER',
    raisedByUserId: 'pass-user',
    bookingId: null,
    subject: 'Lost bag',
    category: 'LOST_ITEM',
    priority: 'MEDIUM',
    status: 'OPEN',
    assignedToId: null,
    createdAt: new Date(),
    resolvedAt: null,
    closedAt: null,
    messages: [
      {
        id: 'm1',
        senderType: 'PASSENGER',
        senderUserId: 'pass-user',
        body: 'Left my bag',
        attachmentKey: null,
        createdAt: new Date(),
      },
    ],
    booking: null,
    ...overrides,
  };
}

describe('SupportTicketsService', () => {
  it('creates a ticket with an atomic TCK number and first message', async () => {
    const tx = {
      booking: { findUnique: vi.fn() },
      $queryRaw: vi.fn(async () => [{ ticketSeq: 1 }]),
      supportTicket: {
        create: vi.fn(async ({ data }) => ({ id: 't1', ...data })),
      },
      supportTicketMessage: {
        create: vi.fn(async () => ({ id: 'm1' })),
      },
    };
    const prisma = {
      $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
      supportTicket: {
        findUnique: vi.fn(async () => detail()),
      },
    };
    const service = new SupportTicketsService(
      prisma as never,
      { get: () => 'true' } as never,
      { notify: vi.fn() } as never,
    );

    const result = await service.create(passenger, {
      subject: 'Lost bag',
      category: 'LOST_ITEM',
      body: 'Left my bag',
    });
    expect(result.number).toBe('TCK-00001');
    expect(tx.supportTicket.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        number: 'TCK-00001',
        raisedByType: 'PASSENGER',
        raisedByUserId: 'pass-user',
      }),
    });
    expect(tx.supportTicketMessage.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        body: 'Left my bag',
        senderType: 'PASSENGER',
      }),
    });
  });

  it('reopens RESOLVED when the requester replies and auto-reopen is on', async () => {
    const tx = {
      supportTicketMessage: { create: vi.fn(async () => ({})) },
      supportTicket: { update: vi.fn(async () => ({})) },
    };
    const prisma = {
      supportTicket: {
        findUnique: vi
          .fn()
          .mockResolvedValueOnce({
            id: 't1',
            number: 'TCK-00001',
            branchId: 'branch-1',
            raisedByUserId: 'pass-user',
            status: 'RESOLVED',
          })
          .mockResolvedValueOnce(
            detail({ status: 'OPEN', resolvedAt: null }),
          ),
      },
      $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
    };
    const service = new SupportTicketsService(
      prisma as never,
      { get: () => 'true' } as never,
      { notify: vi.fn() } as never,
    );

    await service.addMessage(passenger, 't1', { body: 'Still missing' });
    expect(tx.supportTicket.update).toHaveBeenCalledWith({
      where: { id: 't1' },
      data: { status: 'OPEN', resolvedAt: null },
    });
  });

  it('notifies the requester on a staff reply', async () => {
    const notify = vi.fn(async () => ({}));
    const tx = {
      supportTicketMessage: { create: vi.fn(async () => ({})) },
      supportTicket: { update: vi.fn() },
    };
    const prisma = {
      supportTicket: {
        findUnique: vi
          .fn()
          .mockResolvedValueOnce({
            id: 't1',
            number: 'TCK-00001',
            branchId: 'branch-1',
            raisedByUserId: 'pass-user',
            status: 'IN_PROGRESS',
          })
          .mockResolvedValueOnce(detail({ status: 'IN_PROGRESS' })),
      },
      $transaction: vi.fn(async (fn: (c: typeof tx) => unknown) => fn(tx)),
    };
    const service = new SupportTicketsService(
      prisma as never,
      { get: () => 'true' } as never,
      { notify } as never,
    );

    await service.addMessage(care, 't1', { body: 'We found it' });
    expect(notify).toHaveBeenCalledWith(
      'pass-user',
      'SUPPORT_REPLY',
      'Reply on TCK-00001',
      'We found it',
      expect.objectContaining({ ticketId: 't1' }),
    );
  });

  it('rejects illegal status transitions and allows explicit reopen', async () => {
    const prisma = {
      supportTicket: {
        findUnique: vi
          .fn()
          .mockResolvedValueOnce({
            id: 't1',
            branchId: 'branch-1',
            status: 'CLOSED',
            resolvedAt: new Date(),
            closedAt: new Date(),
          })
          .mockResolvedValueOnce({
            id: 't1',
            branchId: 'branch-1',
            status: 'CLOSED',
            resolvedAt: new Date(),
            closedAt: new Date(),
          })
          .mockResolvedValueOnce(detail({ status: 'OPEN' })),
        update: vi.fn(async () => ({})),
      },
    };
    const service = new SupportTicketsService(
      prisma as never,
      { get: () => 'true' } as never,
      { notify: vi.fn() } as never,
    );

    await expect(
      service.setStatus(care, 't1', 'IN_PROGRESS'),
    ).rejects.toMatchObject({
      response: { code: ApiCode.ILLEGAL_TRANSITION },
    });
    await expect(service.setStatus(care, 't1', 'IN_PROGRESS')).rejects.toBeInstanceOf(
      ConflictException,
    );

    prisma.supportTicket.findUnique = vi
      .fn()
      .mockResolvedValueOnce({
        id: 't1',
        branchId: 'branch-1',
        status: 'CLOSED',
        resolvedAt: new Date(),
        closedAt: new Date(),
      })
      .mockResolvedValueOnce(detail({ status: 'OPEN' }));
    await expect(service.setStatus(care, 't1', 'OPEN')).resolves.toMatchObject({
      status: 'OPEN',
    });
  });

  it('counts OPEN and IN_PROGRESS for the pending badge', async () => {
    const prisma = {
      supportTicket: { count: vi.fn(async () => 4) },
    };
    const service = new SupportTicketsService(
      prisma as never,
      { get: () => 'true' } as never,
      { notify: vi.fn() } as never,
    );
    await expect(service.pendingCount(care)).resolves.toEqual({ count: 4 });
    expect(prisma.supportTicket.count).toHaveBeenCalledWith({
      where: {
        branchId: 'branch-1',
        status: { in: ['OPEN', 'IN_PROGRESS'] },
      },
    });
  });

  it('requires support.assign for assignment', async () => {
    const service = new SupportTicketsService(
      {
        supportTicket: {
          findUnique: vi.fn(async () => ({
            id: 't1',
            branchId: 'branch-1',
            status: 'OPEN',
          })),
        },
        rolePermission: { findFirst: vi.fn(async () => null) },
      } as never,
      { get: () => 'true' } as never,
      { notify: vi.fn() } as never,
    );
    await expect(
      service.assign(care, 't1', 'admin-1'),
    ).rejects.toBeInstanceOf(ForbiddenException);

    const ok = new SupportTicketsService(
      {
        supportTicket: {
          findUnique: vi
            .fn()
            .mockResolvedValueOnce({
              id: 't1',
              branchId: 'branch-1',
              status: 'OPEN',
            })
            .mockResolvedValueOnce(detail({ status: 'IN_PROGRESS', assignedToId: 'admin-1' })),
          update: vi.fn(async () => ({})),
        },
        rolePermission: { findFirst: vi.fn(async () => ({ roleId: 'r1' })) },
        user: {
          findUnique: vi.fn(async () => ({
            id: 'admin-1',
            branchId: 'branch-1',
            role: { name: 'branch_admin' },
          })),
        },
      } as never,
      { get: () => 'true' } as never,
      { notify: vi.fn() } as never,
    );
    await expect(ok.assign(admin, 't1', 'admin-1')).resolves.toMatchObject({
      assignedToId: 'admin-1',
    });
  });
});
