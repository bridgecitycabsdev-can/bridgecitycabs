import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { Prisma, TicketSenderType, TicketStatus } from '@prisma/client';
import { ApiCode } from '../common/api-code.js';
import type { AuthUser } from '../common/auth-user.js';
import { branchIdForCreate, branchWhere } from '../common/branch-scope.js';
import { normalizePage, paginate } from '../common/pagination.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { NotificationsService } from '../notifications/notifications.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { AddTicketMessageDto } from './dto/add-ticket-message.dto.js';
import type { CreateTicketDto } from './dto/create-ticket.dto.js';
import type { TicketQuery } from './dto/ticket-query.dto.js';

type Tx = Prisma.TransactionClient;

const STAFF = new Set<string>(STAFF_ROLES);

const ALLOWED_TRANSITIONS: Record<TicketStatus, readonly TicketStatus[]> = {
  OPEN: ['IN_PROGRESS', 'RESOLVED', 'CLOSED'],
  IN_PROGRESS: ['RESOLVED', 'CLOSED', 'OPEN'],
  RESOLVED: ['CLOSED', 'OPEN'],
  CLOSED: ['OPEN'],
};

@Injectable()
export class SupportTicketsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly notifications: NotificationsService,
  ) {}

  async create(user: AuthUser, dto: CreateTicketDto) {
    const { raisedByType, raisedByUserId, branchId } =
      await this.resolveCreateActors(user, dto);

    const ticket = await this.prisma.$transaction(async (tx) => {
      if (dto.bookingId) {
        const booking = await tx.booking.findUnique({
          where: { id: dto.bookingId },
          select: { id: true, branchId: true },
        });
        if (!booking) throw new NotFoundException('Booking not found');
        if (booking.branchId !== branchId) {
          throw new BadRequestException('bookingId is not in this branch');
        }
      }

      const number = await this.nextTicketNumber(tx, branchId);
      const created = await tx.supportTicket.create({
        data: {
          number,
          branchId,
          raisedByType,
          raisedByUserId,
          bookingId: dto.bookingId,
          subject: dto.subject.trim(),
          category: dto.category,
          priority: dto.priority ?? 'MEDIUM',
        },
      });
      await tx.supportTicketMessage.create({
        data: {
          ticketId: created.id,
          senderType: raisedByType,
          senderUserId: raisedByUserId,
          body: dto.body.trim(),
        },
      });
      return created;
    });

    return this.get(user, ticket.id);
  }

  async list(user: AuthUser, query: TicketQuery) {
    this.assertStaff(user);
    const scope = branchWhere(user, query.branchId);
    const { page, pageSize, skip, take } = normalizePage(query);
    const where = {
      ...scope,
      ...(query.status ? { status: query.status } : {}),
      ...(query.assignedToId ? { assignedToId: query.assignedToId } : {}),
    };
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.supportTicket.count({ where }),
      this.prisma.supportTicket.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        include: { _count: { select: { messages: true } } },
      }),
    ]);
    return paginate(
      rows.map((row) => this.presentSummary(row)),
      total,
      { page, pageSize },
    );
  }

  async mine(user: AuthUser, query: TicketQuery) {
    const { page, pageSize, skip, take } = normalizePage(query);
    const where = {
      raisedByUserId: user.userId,
      ...(query.status ? { status: query.status } : {}),
    };
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.supportTicket.count({ where }),
      this.prisma.supportTicket.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        include: { _count: { select: { messages: true } } },
      }),
    ]);
    return paginate(
      rows.map((row) => this.presentSummary(row)),
      total,
      { page, pageSize },
    );
  }

  async get(user: AuthUser, id: string) {
    const ticket = await this.prisma.supportTicket.findUnique({
      where: { id },
      include: {
        messages: { orderBy: { createdAt: 'asc' } },
        booking: {
          select: { id: true, trackingId: true, status: true },
        },
      },
    });
    if (!ticket) throw new NotFoundException();
    this.assertCanView(user, ticket);
    return this.presentDetail(ticket);
  }

  async addMessage(user: AuthUser, id: string, dto: AddTicketMessageDto) {
    const ticket = await this.requireTicket(id);
    this.assertCanView(user, ticket);

    const senderType = this.senderTypeFor(user);
    const isRequester = user.userId === ticket.raisedByUserId;
    const autoReopen = this.readBool('TICKET_AUTO_REOPEN_ON_REPLY', true);

    await this.prisma.$transaction(async (tx) => {
      await tx.supportTicketMessage.create({
        data: {
          ticketId: ticket.id,
          senderType,
          senderUserId: user.userId,
          body: dto.body.trim(),
          attachmentKey: dto.attachmentKey?.trim(),
        },
      });

      if (autoReopen && isRequester && ticket.status === 'RESOLVED') {
        await tx.supportTicket.update({
          where: { id: ticket.id },
          data: { status: 'OPEN', resolvedAt: null },
        });
      }
    });

    if (this.isStaff(user) && user.userId !== ticket.raisedByUserId) {
      await this.notifications.notify(
        ticket.raisedByUserId,
        'SUPPORT_REPLY',
        `Reply on ${ticket.number}`,
        dto.body.trim().slice(0, 200),
        { ticketId: ticket.id, number: ticket.number },
      );
    }

    return this.get(user, id);
  }

  async assign(user: AuthUser, id: string, assignedToId: string) {
    this.assertStaff(user);
    if (!(await this.hasPermission(user, 'support.assign'))) {
      throw new ForbiddenException('Missing permission support.assign');
    }
    const ticket = await this.requireTicket(id);
    this.assertBranch(user, ticket.branchId);

    const assignee = await this.prisma.user.findUnique({
      where: { id: assignedToId },
      select: { id: true, branchId: true, role: { select: { name: true } } },
    });
    if (!assignee) throw new NotFoundException('Assignee not found');
    if (!STAFF.has(assignee.role.name)) {
      throw new BadRequestException('assignedToId must be a staff user');
    }
    if (
      user.role !== 'super_admin' &&
      assignee.branchId &&
      assignee.branchId !== ticket.branchId
    ) {
      throw new BadRequestException('Assignee is not in this branch');
    }

    await this.prisma.supportTicket.update({
      where: { id },
      data: {
        assignedToId,
        status: ticket.status === 'OPEN' ? 'IN_PROGRESS' : ticket.status,
      },
    });
    return this.get(user, id);
  }

  async setStatus(user: AuthUser, id: string, status: TicketStatus) {
    this.assertStaff(user);
    const ticket = await this.requireTicket(id);
    this.assertBranch(user, ticket.branchId);

    if (ticket.status === status) return this.get(user, id);
    if (!ALLOWED_TRANSITIONS[ticket.status].includes(status)) {
      throw new ConflictException({
        code: ApiCode.ILLEGAL_TRANSITION,
        message: `Cannot move ticket from ${ticket.status} to ${status}`,
      });
    }

    const now = new Date();
    await this.prisma.supportTicket.update({
      where: { id },
      data: {
        status,
        resolvedAt:
          status === 'RESOLVED'
            ? now
            : status === 'OPEN'
              ? null
              : ticket.resolvedAt,
        closedAt:
          status === 'CLOSED'
            ? now
            : status === 'OPEN' || status === 'IN_PROGRESS'
              ? null
              : ticket.closedAt,
      },
    });
    return this.get(user, id);
  }

  async pendingCount(user: AuthUser, branchId?: string) {
    this.assertStaff(user);
    const scope = branchWhere(user, branchId);
    const count = await this.prisma.supportTicket.count({
      where: {
        ...scope,
        status: { in: ['OPEN', 'IN_PROGRESS'] },
      },
    });
    return { count };
  }

  /** Atomic Branch.ticketSeq increment → TCK-{seq padded to 5}. */
  async nextTicketNumber(tx: Tx, branchId: string) {
    const rows = await tx.$queryRaw<Array<{ ticketSeq: number }>>`
      UPDATE "Branch"
      SET "ticketSeq" = "ticketSeq" + 1
      WHERE id = ${branchId}
      RETURNING "ticketSeq"
    `;
    const seq = rows[0]?.ticketSeq;
    if (seq == null) throw new NotFoundException('Branch not found');
    return `TCK-${String(seq).padStart(5, '0')}`;
  }

  private async resolveCreateActors(user: AuthUser, dto: CreateTicketDto) {
    if (this.isStaff(user)) {
      const branchId = branchIdForCreate(user, dto.branchId);
      if (!branchId) throw new BadRequestException('branchId is required');
      this.assertBranch(user, branchId);

      if (dto.raisedByUserId) {
        if (!dto.raisedByType || dto.raisedByType === 'STAFF') {
          throw new BadRequestException(
            'raisedByType must be PASSENGER or DRIVER when raising on behalf',
          );
        }
        return {
          branchId,
          raisedByUserId: dto.raisedByUserId,
          raisedByType: dto.raisedByType,
        };
      }
      return {
        branchId,
        raisedByUserId: user.userId,
        raisedByType: 'STAFF' as const,
      };
    }

    if (user.role === 'passenger' || user.role === 'driver') {
      let branchId = user.branchId ?? undefined;
      if (dto.bookingId) {
        const booking = await this.prisma.booking.findUnique({
          where: { id: dto.bookingId },
          select: {
            branchId: true,
            passenger: { select: { userId: true } },
            driver: { select: { userId: true } },
          },
        });
        if (!booking) throw new NotFoundException('Booking not found');
        const owns =
          (user.role === 'passenger' &&
            booking.passenger?.userId === user.userId) ||
          (user.role === 'driver' && booking.driver?.userId === user.userId);
        if (!owns) throw new ForbiddenException();
        branchId = booking.branchId;
      }
      if (!branchId) {
        if (user.role === 'driver') {
          const driver = await this.prisma.driver.findUnique({
            where: { userId: user.userId },
            select: { branchId: true },
          });
          branchId = driver?.branchId;
        }
      }
      if (!branchId) throw new BadRequestException('branchId is required');
      return {
        branchId,
        raisedByUserId: user.userId,
        raisedByType: (user.role === 'passenger'
          ? 'PASSENGER'
          : 'DRIVER') as TicketSenderType,
      };
    }

    throw new ForbiddenException();
  }

  private async requireTicket(id: string) {
    const ticket = await this.prisma.supportTicket.findUnique({
      where: { id },
    });
    if (!ticket) throw new NotFoundException();
    return ticket;
  }

  private assertCanView(
    user: AuthUser,
    ticket: { raisedByUserId: string; branchId: string },
  ) {
    if (this.isStaff(user)) {
      this.assertBranch(user, ticket.branchId);
      return;
    }
    if (ticket.raisedByUserId !== user.userId) throw new NotFoundException();
  }

  private assertStaff(user: AuthUser) {
    if (!this.isStaff(user)) throw new ForbiddenException();
  }

  private isStaff(user: AuthUser) {
    return STAFF.has(user.role);
  }

  private senderTypeFor(user: AuthUser): TicketSenderType {
    if (user.role === 'passenger') return 'PASSENGER';
    if (user.role === 'driver') return 'DRIVER';
    if (this.isStaff(user)) return 'STAFF';
    return 'SYSTEM';
  }

  private assertBranch(user: AuthUser, branchId: string) {
    if (user.role === 'super_admin') return;
    if (!user.branchId || user.branchId !== branchId) {
      throw new NotFoundException();
    }
  }

  private async hasPermission(user: AuthUser, code: string) {
    const row = await this.prisma.rolePermission.findFirst({
      where: {
        role: { name: user.role },
        permission: { code },
      },
      select: { roleId: true },
    });
    return Boolean(row);
  }

  private readBool(key: string, fallback: boolean) {
    const raw = this.config.get<string>(key);
    if (raw == null || raw === '') return fallback;
    if (raw === 'true' || raw === '1') return true;
    if (raw === 'false' || raw === '0') return false;
    return fallback;
  }

  private presentSummary(row: {
    id: string;
    number: string;
    branchId: string;
    raisedByType: string;
    raisedByUserId: string;
    bookingId: string | null;
    subject: string;
    category: string;
    priority: string;
    status: string;
    assignedToId: string | null;
    createdAt: Date;
    resolvedAt: Date | null;
    closedAt: Date | null;
    _count?: { messages: number };
  }) {
    return {
      id: row.id,
      number: row.number,
      branchId: row.branchId,
      raisedByType: row.raisedByType,
      raisedByUserId: row.raisedByUserId,
      bookingId: row.bookingId,
      subject: row.subject,
      category: row.category,
      priority: row.priority,
      status: row.status,
      assignedToId: row.assignedToId,
      createdAt: row.createdAt.toISOString(),
      resolvedAt: row.resolvedAt?.toISOString() ?? null,
      closedAt: row.closedAt?.toISOString() ?? null,
      messageCount: row._count?.messages ?? undefined,
    };
  }

  private presentDetail(row: {
    id: string;
    number: string;
    branchId: string;
    raisedByType: string;
    raisedByUserId: string;
    bookingId: string | null;
    subject: string;
    category: string;
    priority: string;
    status: string;
    assignedToId: string | null;
    createdAt: Date;
    resolvedAt: Date | null;
    closedAt: Date | null;
    messages: Array<{
      id: string;
      senderType: string;
      senderUserId: string | null;
      body: string;
      attachmentKey: string | null;
      createdAt: Date;
    }>;
    booking: {
      id: string;
      trackingId: string;
      status: string;
    } | null;
  }) {
    return {
      ...this.presentSummary(row),
      booking: row.booking,
      messages: row.messages.map((m) => ({
        id: m.id,
        senderType: m.senderType,
        senderUserId: m.senderUserId,
        body: m.body,
        attachmentKey: m.attachmentKey,
        createdAt: m.createdAt.toISOString(),
      })),
    };
  }
}
