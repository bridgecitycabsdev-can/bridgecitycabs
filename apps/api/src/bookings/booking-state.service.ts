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
  from: BookingStatus;
  to: BookingStatus;
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
      return { bookingId: b.id, from: b.status, to };
    };

    const result = opts.tx
      ? await run(opts.tx)
      : await this.prisma.$transaction(run);
    if (!opts.tx) this.events.emit('booking.status_changed', result);
    return result;
  }
}
