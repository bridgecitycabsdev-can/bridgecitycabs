import { GoneException, NotFoundException } from '@nestjs/common';
import type { ConfigService } from '@nestjs/config';
import { describe, expect, it, vi } from 'vitest';
import type { AuthUser } from '../common/auth-user.js';
import { DispatchJobsService } from './dispatch-jobs.service.js';
import { BullOfferExpiryScheduler } from '../jobs/offer-expiry.scheduler.js';
import { DriverOffersController } from './driver-offers.controller.js';
import { DriverOffersService } from './driver-offers.service.js';

const user: AuthUser = { userId: 'user-1', role: 'driver', branchId: 'branch-1' };
const snapshot = { status: 'ASSIGNED', offer: null };

function harness() {
  const offer = {
    bookingId: 'b1',
    driverId: 'd1',
    vehicleId: 'v1',
    booking: { branchId: 'branch-1', status: 'MATCHED', driverId: 'd1' },
  };
  const tx = {
    bookingOffer: {
      updateMany: vi.fn(async () => ({ count: 1 })),
      findUnique: vi.fn(async () => offer),
    },
    bookingAssignment: {
      create: vi.fn(async () => ({ id: 'assignment-1' })),
    },
  };
  const prisma = {
    driver: {
      findUnique: vi.fn(async (): Promise<{ id: string } | null> => ({ id: 'd1' })),
    },
    booking: {
      findUnique: vi.fn(async () => ({
        version: 6,
        status: 'SEARCHING_DRIVER',
        assignMode: 'AUTO',
      })),
    },
    bookingOffer: {
      findUnique: vi.fn(async () => ({ driverId: 'd1', status: 'OFFERED' })),
    },
    $transaction: vi.fn(async (run: (client: typeof tx) => Promise<unknown>) => run(tx)),
  };
  const transition = {
    bookingId: 'b1',
    branchId: 'branch-1',
    from: 'MATCHED',
    to: 'DRIVER_ASSIGNED',
    prevDriverId: 'd1',
    driverId: 'd1',
  };
  const state = {
    transition: vi.fn(async (): Promise<{
      bookingId: string;
      branchId: string;
      from: string;
      to: string;
      prevDriverId: string | null;
      driverId: string | null;
    }> => transition),
  };
  const fleet = {
    state: vi.fn(async () => snapshot),
    releaseOffer: vi.fn(async () => true),
  };
  const events = { emitAsync: vi.fn(async () => []) };
  const queue = { enqueueAttempt: vi.fn(async () => undefined), scheduleRelease: vi.fn() };
  const expiry = { schedule: vi.fn(), cancel: vi.fn(async () => undefined) };
  const offers = new DriverOffersService(
    prisma as never,
    state as never,
    fleet as never,
    events as never,
    queue,
    expiry,
  );
  return { offer, tx, prisma, transition, state, fleet, events, queue, expiry, offers };
}

describe('DriverOffersService.accept', () => {
  it('accepts an open offer, assigns the driver, and returns the snapshot', async () => {
    const { offers, tx, state, events, expiry, fleet, queue } = harness();

    await expect(offers.accept(user, 'offer-1')).resolves.toBe(snapshot);

    expect(tx.bookingOffer.updateMany).toHaveBeenCalledWith({
      where: {
        id: 'offer-1',
        driverId: 'd1',
        status: 'OFFERED',
        expiresAt: { gt: expect.any(Date) },
      },
      data: { status: 'ACCEPTED', respondedAt: expect.any(Date) },
    });
    expect(state.transition).toHaveBeenCalledWith(
      'b1',
      'DRIVER_ASSIGNED',
      { type: 'DRIVER', userId: 'user-1' },
      { tx, patch: { assignedAt: expect.any(Date) } },
    );
    expect(tx.bookingAssignment.create).toHaveBeenCalledWith({
      data: {
        bookingId: 'b1',
        driverId: 'd1',
        vehicleId: 'v1',
        method: 'AUTO',
      },
    });
    expect(events.emitAsync).toHaveBeenCalledWith('booking.status_changed', {
      bookingId: 'b1',
      branchId: 'branch-1',
      from: 'MATCHED',
      to: 'DRIVER_ASSIGNED',
      prevDriverId: 'd1',
      driverId: 'd1',
    });
    expect(expiry.cancel).toHaveBeenCalledWith('offer-1');
    expect(fleet.releaseOffer).not.toHaveBeenCalled();
    expect(queue.enqueueAttempt).not.toHaveBeenCalled();
    expect(fleet.state).toHaveBeenCalledWith(user);
  });

  it('returns the current snapshot when this driver already accepted', async () => {
    const { offers, tx, prisma, state, fleet } = harness();
    tx.bookingOffer.updateMany.mockResolvedValue({ count: 0 });
    prisma.bookingOffer.findUnique.mockResolvedValue({ driverId: 'd1', status: 'ACCEPTED' });

    await expect(offers.accept(user, 'offer-1')).resolves.toBe(snapshot);

    expect(state.transition).not.toHaveBeenCalled();
    expect(tx.bookingAssignment.create).not.toHaveBeenCalled();
    expect(fleet.state).toHaveBeenCalledWith(user);
  });

  it('returns gone when the offer was answered by someone else or has expired', async () => {
    const expired = harness();
    expired.tx.bookingOffer.updateMany.mockResolvedValue({ count: 0 });
    expired.prisma.bookingOffer.findUnique.mockResolvedValue({
      driverId: 'd1',
      status: 'EXPIRED',
    });

    const other = harness();
    other.tx.bookingOffer.updateMany.mockResolvedValue({ count: 0 });
    other.prisma.bookingOffer.findUnique.mockResolvedValue({
      driverId: 'd2',
      status: 'ACCEPTED',
    });

    await expect(expired.offers.accept(user, 'offer-1')).rejects.toBeInstanceOf(GoneException);
    await expect(other.offers.accept(user, 'offer-1')).rejects.toBeInstanceOf(GoneException);
    try {
      await expired.offers.accept(user, 'offer-1');
    } catch (error) {
      expect(error).toBeInstanceOf(GoneException);
      expect((error as GoneException).getStatus()).toBe(410);
    }
  });

  it('returns not found when the user is not a driver', async () => {
    const { offers, prisma } = harness();
    prisma.driver.findUnique.mockResolvedValue(null);

    await expect(offers.accept(user, 'offer-1')).rejects.toBeInstanceOf(NotFoundException);
  });
});

describe('accept and expire', () => {
  it('produces one outcome when both run together', async () => {
    let status = 'OFFERED';
    const updateMany = vi.fn(
      async (args: { where: { status?: string; driverId?: string }; data: { status: string } }) => {
        if (args.where.status !== 'OFFERED' || status !== 'OFFERED') return { count: 0 };
        if (args.where.driverId && args.where.driverId !== 'd1') return { count: 0 };
        status = args.data.status;
        return { count: 1 };
      },
    );
    const offerRow = () => ({
      driverId: 'd1',
      status,
      bookingId: 'b1',
      vehicleId: 'v1',
      booking: { branchId: 'branch-1', status: 'MATCHED', driverId: 'd1' },
    });
    const tx = {
      bookingOffer: {
        updateMany,
        findUnique: vi.fn(async () => offerRow()),
      },
      bookingAssignment: { create: vi.fn(async () => ({ id: 'assignment-1' })) },
    };
    const prisma = {
      driver: { findUnique: vi.fn(async () => ({ id: 'd1' })) },
      booking: {
        findUnique: vi.fn(async () => ({
          version: 8,
          status: 'SEARCHING_DRIVER',
          assignMode: 'AUTO',
        })),
      },
      bookingOffer: { findUnique: vi.fn(async () => offerRow()) },
      $transaction: vi.fn(async (run: (client: typeof tx) => Promise<unknown>) => run(tx)),
    };
    const state = {
      transition: vi.fn(async () => ({
        bookingId: 'b1',
        branchId: 'branch-1',
        from: 'MATCHED',
        to: status === 'ACCEPTED' ? 'DRIVER_ASSIGNED' : 'SEARCHING_DRIVER',
        prevDriverId: 'd1',
        driverId: status === 'ACCEPTED' ? 'd1' : null,
      })),
    };
    const fleet = { state: vi.fn(async () => snapshot), releaseOffer: vi.fn(async () => true) };
    const events = { emitAsync: vi.fn(async () => []) };
    const queue = { enqueueAttempt: vi.fn(async () => undefined), scheduleRelease: vi.fn() };
    const expiry = { schedule: vi.fn(), cancel: vi.fn(async () => undefined) };
    const offers = new DriverOffersService(
      prisma as never,
      state as never,
      fleet as never,
      events as never,
      queue,
      expiry,
    );
    const jobs = new DispatchJobsService(
      prisma as never,
      { get: () => undefined } as ConfigService,
      state as never,
      fleet as never,
      {} as never,
      events as never,
      queue,
    );

    const [accepted, expired] = await Promise.allSettled([
      offers.accept(user, 'offer-1'),
      jobs.expireOffer('offer-1'),
    ]);

    const assigned = tx.bookingAssignment.create.mock.calls.length;
    const requeued = queue.enqueueAttempt.mock.calls.length;
    expect(assigned + requeued).toBe(1);
    expect(['ACCEPTED', 'EXPIRED']).toContain(status);
    if (status === 'ACCEPTED') {
      expect(accepted.status).toBe('fulfilled');
      expect(expired.status).toBe('fulfilled');
      expect(fleet.releaseOffer).not.toHaveBeenCalled();
    } else {
      expect(accepted.status).toBe('rejected');
      expect(expired.status).toBe('fulfilled');
      expect(fleet.releaseOffer).toHaveBeenCalledTimes(1);
    }
  });
});

describe('DriverOffersService.decline', () => {
  it('declines, releases the driver, and re-queues the search immediately', async () => {
    const { offers, tx, state, fleet, events, queue, expiry } = harness();
    const searching = {
      bookingId: 'b1',
      branchId: 'branch-1',
      from: 'MATCHED',
      to: 'SEARCHING_DRIVER',
      prevDriverId: 'd1',
      driverId: null,
    };
    state.transition.mockResolvedValue(searching);

    await expect(offers.decline(user, 'offer-1', '  too far  ')).resolves.toBe(snapshot);

    expect(tx.bookingOffer.updateMany).toHaveBeenCalledWith({
      where: { id: 'offer-1', driverId: 'd1', status: 'OFFERED' },
      data: {
        status: 'DECLINED',
        respondedAt: expect.any(Date),
        declineReason: 'too far',
      },
    });
    expect(state.transition).toHaveBeenCalledWith(
      'b1',
      'SEARCHING_DRIVER',
      { type: 'SYSTEM' },
      { tx, reason: 'too far' },
    );
    expect(fleet.releaseOffer).toHaveBeenCalledWith({
      branchId: 'branch-1',
      driverId: 'd1',
      bookingId: 'b1',
    });
    expect(expiry.cancel).toHaveBeenCalledWith('offer-1');
    expect(events.emitAsync).toHaveBeenCalledWith('booking.status_changed', searching);
    expect(queue.enqueueAttempt).toHaveBeenCalledTimes(1);
    expect(queue.enqueueAttempt.mock.calls[0]).toEqual(['b1', 6]);
  });

  it('uses a default history reason when the driver gives none', async () => {
    const { offers, state } = harness();

    await offers.decline(user, 'offer-1');

    expect(state.transition).toHaveBeenCalledWith(
      'b1',
      'SEARCHING_DRIVER',
      { type: 'SYSTEM' },
      { tx: expect.any(Object), reason: 'Offer declined' },
    );
  });

  it('returns the snapshot when this driver already declined', async () => {
    const { offers, tx, prisma, fleet, queue } = harness();
    tx.bookingOffer.updateMany.mockResolvedValue({ count: 0 });
    prisma.bookingOffer.findUnique.mockResolvedValue({ driverId: 'd1', status: 'DECLINED' });

    await expect(offers.decline(user, 'offer-1')).resolves.toBe(snapshot);

    expect(fleet.releaseOffer).not.toHaveBeenCalled();
    expect(queue.enqueueAttempt).not.toHaveBeenCalled();
  });

  it('returns gone when the offer is no longer open', async () => {
    const { offers, tx, prisma } = harness();
    tx.bookingOffer.updateMany.mockResolvedValue({ count: 0 });
    prisma.bookingOffer.findUnique.mockResolvedValue({ driverId: 'd1', status: 'EXPIRED' });

    await expect(offers.decline(user, 'offer-1')).rejects.toBeInstanceOf(GoneException);
  });

  it('releases a driver whose booking already moved on, without searching again', async () => {
    const { offers, offer, state, fleet, queue } = harness();
    offer.booking.status = 'CANCELLED';

    await offers.decline(user, 'offer-1', 'busy');

    expect(state.transition).not.toHaveBeenCalled();
    expect(fleet.releaseOffer).toHaveBeenCalled();
    expect(queue.enqueueAttempt).not.toHaveBeenCalled();
    expect(fleet.state).toHaveBeenCalled();
  });

  it('still re-queues when telling dispatch fails', async () => {
    const { offers, events, queue } = harness();
    events.emitAsync.mockRejectedValue(new Error('socket down'));

    await offers.decline(user, 'offer-1');

    expect(queue.enqueueAttempt).toHaveBeenCalledWith('b1', 6);
  });
});

describe('offer expiry cancel', () => {
  it('removes the delayed job and ignores one that is already running', async () => {
    const remove = vi
      .fn()
      .mockResolvedValueOnce(1)
      .mockRejectedValueOnce(new Error('Job is locked'));
    const scheduler = new BullOfferExpiryScheduler({ remove } as never);

    await scheduler.cancel('offer-1');
    await expect(scheduler.cancel('offer-1')).resolves.toBeUndefined();
    expect(remove).toHaveBeenCalledWith('offer-1');
  });
});

describe('DriverOffersController', () => {
  it('forwards accept and decline to the service', async () => {
    const offers = {
      accept: vi.fn(async () => snapshot),
      decline: vi.fn(async () => snapshot),
    };
    const controller = new DriverOffersController(offers as never);

    await controller.accept(user, 'offer-1');
    await controller.decline(user, 'offer-1', { reason: 'far' });

    expect(offers.accept).toHaveBeenCalledWith(user, 'offer-1');
    expect(offers.decline).toHaveBeenCalledWith(user, 'offer-1', 'far');
  });
});
