import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Inject,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { EventEmitter2 } from '@nestjs/event-emitter';
import type { SosStatus, SosTriggerType } from '@prisma/client';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import { normalizePage, paginate } from '../common/pagination.js';
import { STAFF_ROLES } from '../common/staff-roles.js';
import { NotificationsService } from '../notifications/notifications.service.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { SMS_PROVIDER, type SmsProvider } from '../sms/sms-provider.js';
import type { ResolveSosDto } from './dto/resolve-sos.dto.js';
import type { SosQuery } from './dto/sos-query.dto.js';
import { SOS_TRIGGERED } from './sos.events.js';

const STAFF = new Set<string>(STAFF_ROLES);
const TERMINAL: SosStatus[] = ['RESOLVED', 'FALSE_ALARM'];

@Injectable()
export class SosService {
  private readonly logger = new Logger(SosService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly config: ConfigService,
    private readonly events: EventEmitter2,
    private readonly notifications: NotificationsService,
    @Inject(SMS_PROVIDER) private readonly sms: SmsProvider,
  ) {}

  async trigger(i: {
    branchId: string;
    bookingId?: string;
    triggeredByType: SosTriggerType;
    triggeredByUserId: string;
    lat: number;
    lng: number;
  }) {
    if (i.bookingId) {
      const booking = await this.prisma.booking.findUnique({
        where: { id: i.bookingId },
        select: { id: true, branchId: true },
      });
      if (!booking) throw new NotFoundException('Booking not found');
      if (booking.branchId !== i.branchId) {
        throw new BadRequestException('bookingId is not in this branch');
      }
    }

    const windowSec = Number(
      this.config.get<string>('SOS_DEDUPE_WINDOW_SECONDS') ?? '30',
    );
    if (Number.isFinite(windowSec) && windowSec > 0) {
      const since = new Date(Date.now() - windowSec * 1000);
      const open = await this.prisma.sosAlert.findFirst({
        where: {
          triggeredByUserId: i.triggeredByUserId,
          status: { notIn: TERMINAL },
          createdAt: { gte: since },
        },
        orderBy: { createdAt: 'desc' },
      });
      if (open) {
        const updated = await this.prisma.sosAlert.update({
          where: { id: open.id },
          data: { lat: i.lat, lng: i.lng },
        });
        return this.present(updated);
      }
    }

    const alert = await this.prisma.sosAlert.create({ data: i });
    this.events.emit(SOS_TRIGGERED, alert);

    const phone = this.config.get<string>('SOS_BRANCH_FALLBACK_PHONE')?.trim();
    if (phone) {
      try {
        await this.sms.sendTransactional(
          phone,
          `SOS triggered, branch ${i.branchId}, alert ${alert.id}`,
        );
      } catch (error) {
        // Alert is already live on the dispatch socket; SMS must not roll it back.
        this.logger.error(
          `SOS fallback SMS failed for ${alert.id}: ${
            error instanceof Error ? error.message : 'unknown error'
          }`,
        );
      }
    }

    return this.present(alert);
  }

  async triggerAsDriver(user: AuthUser, dto: { bookingId?: string; lat: number; lng: number }) {
    const driver = await this.prisma.driver.findUnique({
      where: { userId: user.userId },
      select: { id: true, branchId: true },
    });
    if (!driver) throw new NotFoundException();
    if (dto.bookingId) {
      const booking = await this.prisma.booking.findUnique({
        where: { id: dto.bookingId },
        select: { driverId: true, branchId: true },
      });
      if (!booking || booking.driverId !== driver.id) throw new ForbiddenException();
    }
    return this.trigger({
      branchId: driver.branchId,
      bookingId: dto.bookingId,
      triggeredByType: 'DRIVER',
      triggeredByUserId: user.userId,
      lat: dto.lat,
      lng: dto.lng,
    });
  }

  async triggerAsPassenger(
    user: AuthUser,
    dto: { bookingId?: string; lat: number; lng: number },
  ) {
    const passenger = await this.prisma.passenger.findUnique({
      where: { userId: user.userId },
      select: { id: true },
    });
    if (!passenger) throw new NotFoundException();

    let branchId = user.branchId ?? undefined;
    if (dto.bookingId) {
      const booking = await this.prisma.booking.findUnique({
        where: { id: dto.bookingId },
        select: { passengerId: true, branchId: true },
      });
      if (!booking || booking.passengerId !== passenger.id) {
        throw new ForbiddenException();
      }
      branchId = booking.branchId;
    }
    if (!branchId) {
      throw new BadRequestException(
        'branchId is required (provide bookingId or a branch-scoped session)',
      );
    }

    return this.trigger({
      branchId,
      bookingId: dto.bookingId,
      triggeredByType: 'PASSENGER',
      triggeredByUserId: user.userId,
      lat: dto.lat,
      lng: dto.lng,
    });
  }

  async list(user: AuthUser, query: SosQuery) {
    this.assertStaff(user);
    const scope = branchWhere(user, query.branchId);
    const { page, pageSize, skip, take } = normalizePage(query);
    const where = {
      ...scope,
      ...(query.status ? { status: query.status } : {}),
    };
    const [total, rows] = await this.prisma.$transaction([
      this.prisma.sosAlert.count({ where }),
      this.prisma.sosAlert.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip,
        take,
        include: {
          booking: { select: { id: true, trackingId: true, status: true } },
        },
      }),
    ]);
    return paginate(
      rows.map((row) => this.present(row)),
      total,
      { page, pageSize },
    );
  }

  /**
   * Staff ack only. Notification to the triggerer runs after ACKNOWLEDGED is
   * persisted — never before, and never on a second ack.
   */
  async acknowledge(user: AuthUser, id: string) {
    this.assertStaff(user);
    const alert = await this.requireAlert(id);
    this.assertBranch(user, alert.branchId);
    if (TERMINAL.includes(alert.status)) {
      throw new ConflictException('SOS alert is already closed');
    }
    if (alert.status === 'ACKNOWLEDGED') {
      throw new ConflictException('SOS alert is already acknowledged');
    }

    const updated = await this.prisma.sosAlert.update({
      where: { id },
      data: {
        status: 'ACKNOWLEDGED',
        acknowledgedById: user.userId,
        acknowledgedAt: new Date(),
      },
    });

    await this.notifications.notify(
      alert.triggeredByUserId,
      'SOS_ACKNOWLEDGED',
      'Dispatch has been notified',
      'A dispatcher has acknowledged your emergency alert.',
      { alertId: alert.id, bookingId: alert.bookingId },
    );

    return this.present(updated);
  }

  /**
   * Terminal close from TRIGGERED or ACKNOWLEDGED. Ack is not required —
   * staff may mark FALSE_ALARM / RESOLVED immediately when the situation is
   * already clear. There is no delete or silent-close path.
   */
  async resolve(user: AuthUser, id: string, dto: ResolveSosDto) {
    this.assertStaff(user);
    const alert = await this.requireAlert(id);
    this.assertBranch(user, alert.branchId);
    if (TERMINAL.includes(alert.status)) {
      throw new ConflictException('SOS alert is already closed');
    }
    if (alert.status !== 'TRIGGERED' && alert.status !== 'ACKNOWLEDGED') {
      throw new ConflictException('SOS alert cannot be resolved from this status');
    }

    const before = {
      status: alert.status,
      acknowledgedById: alert.acknowledgedById,
      resolvedById: alert.resolvedById,
      resolutionNote: alert.resolutionNote,
    };

    const updated = await this.prisma.$transaction(async (tx) => {
      const row = await tx.sosAlert.update({
        where: { id },
        data: {
          status: dto.outcome,
          resolvedById: user.userId,
          resolvedAt: new Date(),
          resolutionNote: dto.note?.trim() || null,
        },
      });
      await tx.auditLog.create({
        data: {
          actorUserId: user.userId,
          actorType: 'STAFF',
          entity: 'sos_alert',
          entityId: id,
          action: 'sos.resolved',
          before,
          after: {
            status: row.status,
            resolvedById: row.resolvedById,
            resolutionNote: row.resolutionNote,
            outcome: dto.outcome,
          },
        },
      });
      return row;
    });

    return this.present(updated);
  }

  private async requireAlert(id: string) {
    const alert = await this.prisma.sosAlert.findUnique({ where: { id } });
    if (!alert) throw new NotFoundException();
    return alert;
  }

  private assertStaff(user: AuthUser) {
    if (!STAFF.has(user.role)) throw new ForbiddenException();
  }

  private assertBranch(user: AuthUser, branchId: string) {
    if (user.role === 'super_admin') return;
    if (!user.branchId || user.branchId !== branchId) {
      throw new NotFoundException();
    }
  }

  private present(row: {
    id: string;
    branchId: string;
    bookingId: string | null;
    triggeredByType: string;
    triggeredByUserId: string;
    lat: number;
    lng: number;
    status: string;
    acknowledgedById: string | null;
    acknowledgedAt: Date | null;
    resolvedById: string | null;
    resolvedAt: Date | null;
    resolutionNote: string | null;
    createdAt: Date;
    booking?: { id: string; trackingId: string; status: string } | null;
  }) {
    return {
      id: row.id,
      branchId: row.branchId,
      bookingId: row.bookingId,
      triggeredByType: row.triggeredByType,
      triggeredByUserId: row.triggeredByUserId,
      lat: row.lat,
      lng: row.lng,
      status: row.status,
      acknowledgedById: row.acknowledgedById,
      acknowledgedAt: row.acknowledgedAt?.toISOString() ?? null,
      resolvedById: row.resolvedById,
      resolvedAt: row.resolvedAt?.toISOString() ?? null,
      resolutionNote: row.resolutionNote,
      createdAt: row.createdAt.toISOString(),
      booking: row.booking ?? undefined,
    };
  }
}
