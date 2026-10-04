import { NotFoundException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { NOTIFICATION_CREATED } from './notifications.events.js';
import { NotificationsService } from './notifications.service.js';

describe('NotificationsService', () => {
  it('persists, emits, and pushes on notify', async () => {
    const created = {
      id: 'n1',
      userId: 'user-1',
      type: 'SUPPORT_REPLY',
      title: 'Reply',
      body: 'We looked into it',
      data: { ticketId: 't1' },
      readAt: null,
      createdAt: new Date(),
    };
    const prisma = {
      notification: { create: vi.fn(async () => created) },
    };
    const events = { emit: vi.fn() };
    const push = { sendToUser: vi.fn(async () => undefined) };
    const service = new NotificationsService(
      prisma as never,
      events as never,
      push as never,
    );

    await expect(
      service.notify('user-1', 'SUPPORT_REPLY', 'Reply', 'We looked into it', {
        ticketId: 't1',
      }),
    ).resolves.toMatchObject({
      id: 'n1',
      type: 'SUPPORT_REPLY',
      readAt: null,
    });
    expect(events.emit).toHaveBeenCalledWith(NOTIFICATION_CREATED, created);
    expect(push.sendToUser).toHaveBeenCalledWith('user-1', {
      title: 'Reply',
      body: 'We looked into it',
      data: { type: 'SUPPORT_REPLY', ticketId: 't1' },
      highPriority: false,
      timeSensitive: false,
    });
  });

  it('lists with unreadOnly and returns unread count', async () => {
    const prisma = {
      $transaction: vi.fn(async (ops: Promise<unknown>[]) => Promise.all(ops)),
      notification: {
        count: vi.fn(async () => 2),
        findMany: vi.fn(async () => [
          {
            id: 'n1',
            userId: 'user-1',
            type: 'SOS_ACKNOWLEDGED',
            title: 'Ack',
            body: 'Staff saw your alert',
            data: null,
            readAt: null,
            createdAt: new Date(),
          },
        ]),
      },
    };
    const service = new NotificationsService(
      prisma as never,
      { emit: vi.fn() } as never,
      { sendToUser: vi.fn() } as never,
    );

    const page = await service.list('user-1', {
      page: 1,
      pageSize: 20,
      unreadOnly: true,
    });
    expect(page.data).toHaveLength(1);
    expect(prisma.notification.count).toHaveBeenCalledWith({
      where: { userId: 'user-1', readAt: null },
    });
    await expect(service.unreadCount('user-1')).resolves.toEqual({ count: 2 });
  });

  it('marks one and all as read, scoped to the caller', async () => {
    const prisma = {
      notification: {
        updateMany: vi
          .fn()
          .mockResolvedValueOnce({ count: 1 })
          .mockResolvedValueOnce({ count: 0 })
          .mockResolvedValueOnce({ count: 3 }),
        findUniqueOrThrow: vi.fn(async () => ({
          id: 'n1',
          userId: 'user-1',
          type: 'SUPPORT_REPLY',
          title: 'Reply',
          body: 'ok',
          data: null,
          readAt: new Date(),
          createdAt: new Date(),
        })),
      },
    };
    const service = new NotificationsService(
      prisma as never,
      { emit: vi.fn() } as never,
      { sendToUser: vi.fn() } as never,
    );

    await expect(service.markRead('user-1', 'n1')).resolves.toMatchObject({
      id: 'n1',
      readAt: expect.any(String),
    });
    await expect(service.markRead('user-1', 'missing')).rejects.toBeInstanceOf(
      NotFoundException,
    );
    await expect(service.markAllRead('user-1')).resolves.toEqual({ updated: 3 });
  });
});
