import {
  ConflictException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { BookingStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';
import {
  driverRelease,
  stampFor,
  TRANSITIONS,
  type Actor,
} from './booking-transitions.js';

export type BookingTransitionResult = {
  bookingId: string;
  branchId: string;
  from: BookingStatus;
  to: BookingStatus;
  prevDriverId: string | null;
  driverId: string | null;
};

@Injectable()
export class BookingStateService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly events: EventEmitter2,
  ) {}

  async transition(
    bookingId: string,
    to: BookingStatus,
    actor: { type: Actor; userId?: string },
    opts: {
      reason?: string;
      metadata?: Prisma.InputJsonValue;
      patch?: Prisma.BookingUncheckedUpdateManyInput;
      tx?: Prisma.TransactionClient;
    } = {},
  ): Promise<BookingTransitionResult> {
    const run = async (tx: Prisma.TransactionClient) => {
      const b = await tx.booking.findUnique({ where: { id: bookingId } });
      if (!b) throw new NotFoundException();

      const allowed = TRANSITIONS[b.status]?.[to];
      if (!allowed) {
        throw new ConflictException(`Illegal transition ${b.status} → ${to}`);
      }
      if (!allowed.includes(actor.type)) throw new ForbiddenException();

      const prevDriverId = b.driverId;
      const driverId = resultingDriverId(prevDriverId, b.status, to, opts.patch);
      const res = await tx.booking.updateMany({
        where: { id: b.id, status: b.status, version: b.version },
        data: {
          status: to,
          version: { increment: 1 },
          ...stampFor(to),
          ...driverRelease(b.status, to),
          ...opts.patch,
        },
      });
      if (res.count !== 1) throw new ConflictException('Booking changed, retry');

      await tx.bookingStatusHistory.create({
        data: {
          bookingId: b.id,
          fromStatus: b.status,
          toStatus: to,
          actorType: actor.type,
          actorUserId: actor.userId,
          reason: opts.reason,
          metadata: opts.metadata,
        },
      });
      return { bookingId: b.id, branchId: b.branchId, from: b.status, to, prevDriverId, driverId };
    };

    const result = opts.tx
      ? await run(opts.tx)
      : await this.prisma.$transaction(run);
    if (!opts.tx) await this.events.emitAsync('booking.status_changed', result);
    return result;
  }
}

function resultingDriverId(
  current: string | null,
  from: BookingStatus,
  to: BookingStatus,
  patch?: Prisma.BookingUncheckedUpdateManyInput,
) {
  if (patch && Object.prototype.hasOwnProperty.call(patch, 'driverId')) {
    const value = patch.driverId;
    if (typeof value === 'string' || value === null) return value;
    if (value && typeof value === 'object' && 'set' in value) {
      return typeof value.set === 'string' ? value.set : null;
    }
  }
  if (Object.prototype.hasOwnProperty.call(driverRelease(from, to), 'driverId')) return null;
  return current;
}
