import { ConflictException, NotFoundException } from '@nestjs/common';
import type { ConfigService } from '@nestjs/config';
import type { Job } from 'bullmq';
import { describe, expect, it, vi } from 'vitest';
import { BullDispatchQueue } from '../jobs/dispatch-queue.js';
import { DISPATCH_RETRY_MS, JOB_NAMES } from '../jobs/job-names.js';
import { JobsWorker } from '../jobs/jobs.worker.js';
import { DispatchJobsService } from './dispatch-jobs.service.js';
import { DispatchListener } from './dispatch.listener.js';

const config = {
  get: (key: string) =>
    (
      {
        MAX_OFFERS_PER_BOOKING: '6',
        SEARCH_WINDOW_SECONDS: '120',
        SCHEDULE_LEAD_MINUTES: '15',
      } as Record<string, string>
    )[key],
} as ConfigService;

function harness() {
  const booking = {
    id: 'b1',
    status: 'SEARCHING_DRIVER' as string,
    assignMode: 'AUTO' as string,
    searchStartedAt: new Date() as Date | null,
    version: 4,
    scheduledAt: null as Date | null,
  };
  const prisma = {
    booking: {
      findUnique: vi.fn(async (): Promise<Record<string, unknown>> => ({ ...booking })),
      findMany: vi.fn(async () => [] as { id: string }[]),
    },
    bookingOffer: {
      count: vi.fn(async () => 0),
    },
    $transaction: vi.fn(),
  };
  const state = { transition: vi.fn(async () => ({ bookingId: 'b1' })) };
  const fleet = { releaseOffer: vi.fn(async () => true) };
  const matching = { offerNext: vi.fn(async (): Promise<{ id: string } | null> => null) };
  const events = { emitAsync: vi.fn(async () => []) };
  const queue = {
    enqueueAttempt: vi.fn(async () => undefined),
    scheduleRelease: vi.fn(async () => undefined),
  };
  const jobs = new DispatchJobsService(
    prisma as never,
    config,
    state as never,
    fleet as never,
    matching as never,
    events as never,
    queue,
  );
  return { booking, prisma, state, fleet, matching, events, queue, jobs };
}

describe('DispatchJobsService', () => {
  it('enqueues a search when an auto booking starts looking', async () => {
    const { jobs, queue } = harness();

    await jobs.onStatus({ bookingId: 'b1', to: 'SEARCHING_DRIVER' });

    expect(queue.enqueueAttempt).toHaveBeenCalledWith('b1', 4);
  });

  it('leaves manual bookings and other statuses alone', async () => {
    const manual = harness();
    manual.booking.assignMode = 'MANUAL';
    await manual.jobs.onStatus({ bookingId: 'b1', to: 'SEARCHING_DRIVER' });

    const other = harness();
    await other.jobs.onStatus({ bookingId: 'b1', to: 'MATCHED' });

    expect(manual.queue.enqueueAttempt).not.toHaveBeenCalled();
    expect(other.prisma.booking.findUnique).not.toHaveBeenCalled();
  });

  it('schedules a release when a scheduled booking is created', async () => {
    const { jobs, queue } = harness();
    const scheduledAt = new Date(Date.now() + 60 * 60_000).toISOString();

    await jobs.onCreated({ id: 'b1', status: 'SCHEDULED', scheduledAt });
    await jobs.onCreated({ id: 'b1', status: 'CREATED', scheduledAt: null });

    expect(queue.scheduleRelease).toHaveBeenCalledTimes(1);
    expect(queue.scheduleRelease).toHaveBeenCalledWith('b1', new Date(scheduledAt));
  });

  it('searches again in five seconds when nobody is free', async () => {
    const { jobs, queue, matching } = harness();

    await jobs.runAttempt('b1', 4);

    expect(matching.offerNext).toHaveBeenCalledWith('b1');
    expect(queue.enqueueAttempt).toHaveBeenCalledWith('b1', 5, DISPATCH_RETRY_MS);
  });

  it('stops once an offer is out', async () => {
    const { jobs, queue, matching } = harness();
    matching.offerNext.mockResolvedValue({ id: 'offer-1' });

    await jobs.runAttempt('b1', 4);

    expect(queue.enqueueAttempt).not.toHaveBeenCalled();
  });

  it('marks the booking when the search window or the offer cap is over', async () => {
    const window = harness();
    window.booking.searchStartedAt = new Date(Date.now() - 121_000);
    await window.jobs.runAttempt('b1', 2);

    const cap = harness();
    cap.prisma.bookingOffer.count.mockResolvedValue(6);
    await cap.jobs.runAttempt('b1', 2);

    expect(window.matching.offerNext).not.toHaveBeenCalled();
    expect(window.state.transition).toHaveBeenCalledWith(
      'b1',
      'NO_DRIVER_FOUND',
      { type: 'SYSTEM' },
      { reason: 'No driver found' },
    );
    expect(cap.state.transition).toHaveBeenCalledWith(
      'b1',
      'NO_DRIVER_FOUND',
      { type: 'SYSTEM' },
      { reason: 'No driver found' },
    );
  });

  it('ignores a booking that left the search before the retry', async () => {
    const { jobs, queue, prisma, booking } = harness();
    prisma.booking.findUnique
      .mockResolvedValueOnce({ ...booking })
      .mockResolvedValueOnce({ ...booking, status: 'CANCELLED' });

    await jobs.runAttempt('b1', 4);

    expect(queue.enqueueAttempt).not.toHaveBeenCalled();
  });

  it('swallows a lost race when giving up', async () => {
    const { jobs, state, booking } = harness();
    booking.searchStartedAt = new Date(Date.now() - 121_000);
    state.transition.mockRejectedValue(new ConflictException('Booking changed, retry'));

    await expect(jobs.runAttempt('b1', 1)).resolves.toBeUndefined();
  });

  it('exits when the offer was already answered', async () => {
    const { jobs, prisma, fleet, queue } = harness();
    prisma.$transaction.mockImplementation(async (run: (tx: unknown) => Promise<unknown>) =>
      run({
        bookingOffer: {
          updateMany: vi.fn(async () => ({ count: 0 })),
          findUnique: vi.fn(),
        },
      }),
    );

    await jobs.expireOffer('offer-1');

    expect(fleet.releaseOffer).not.toHaveBeenCalled();
    expect(queue.enqueueAttempt).not.toHaveBeenCalled();
  });

  it('releases the driver and queues the next search after an expiry', async () => {
    const { jobs, prisma, state, fleet, events, queue, booking } = harness();
    booking.status = 'SEARCHING_DRIVER';
    booking.version = 8;
    const transition = {
      bookingId: 'b1',
      branchId: 'branch-1',
      from: 'MATCHED',
      to: 'SEARCHING_DRIVER',
      prevDriverId: 'd1',
      driverId: null,
    };
    const tx = {
      bookingOffer: {
        updateMany: vi.fn(async () => ({ count: 1 })),
        findUnique: vi.fn(async () => ({
          bookingId: 'b1',
          driverId: 'd1',
          booking: { branchId: 'branch-1', status: 'MATCHED', driverId: 'd1' },
        })),
      },
    };
    prisma.$transaction.mockImplementation(async (run: (client: typeof tx) => Promise<unknown>) =>
      run(tx),
    );
    state.transition.mockResolvedValue(transition);

    await jobs.expireOffer('offer-1');

    expect(tx.bookingOffer.updateMany).toHaveBeenCalledWith({
      where: { id: 'offer-1', status: 'OFFERED' },
      data: { status: 'EXPIRED', respondedAt: expect.any(Date) },
    });
    expect(state.transition).toHaveBeenCalledWith(
      'b1',
      'SEARCHING_DRIVER',
      { type: 'SYSTEM' },
      { tx, reason: 'Offer expired' },
    );
    expect(fleet.releaseOffer).toHaveBeenCalledWith({
      branchId: 'branch-1',
      driverId: 'd1',
      bookingId: 'b1',
    });
    expect(events.emitAsync).toHaveBeenCalledWith('booking.status_changed', transition);
    expect(queue.enqueueAttempt).toHaveBeenCalledWith('b1', 8);
  });

  it('still queues the next search when the status event fails', async () => {
    const { jobs, prisma, state, events, queue, booking } = harness();
    booking.version = 3;
    prisma.$transaction.mockImplementation(async (run: (tx: unknown) => Promise<unknown>) =>
      run({
        bookingOffer: {
          updateMany: async () => ({ count: 1 }),
          findUnique: async () => ({
            bookingId: 'b1',
            driverId: 'd1',
            booking: { branchId: 'branch-1', status: 'MATCHED', driverId: 'd1' },
          }),
        },
      }),
    );
    state.transition.mockResolvedValue({ bookingId: 'b1' });
    events.emitAsync.mockRejectedValue(new Error('socket down'));

    await jobs.expireOffer('offer-1');

    expect(queue.enqueueAttempt).toHaveBeenCalledWith('b1', 3);
  });

  it('releases a driver whose booking already moved on, without searching again', async () => {
    const { jobs, prisma, state, fleet, queue } = harness();
    prisma.$transaction.mockImplementation(async (run: (tx: unknown) => Promise<unknown>) =>
      run({
        bookingOffer: {
          updateMany: async () => ({ count: 1 }),
          findUnique: async () => ({
            bookingId: 'b1',
            driverId: 'd1',
            booking: { branchId: 'branch-1', status: 'DRIVER_ASSIGNED', driverId: 'd1' },
          }),
        },
      }),
    );

    await jobs.expireOffer('offer-1');

    expect(fleet.releaseOffer).toHaveBeenCalled();
    expect(state.transition).not.toHaveBeenCalled();
    expect(queue.enqueueAttempt).not.toHaveBeenCalled();
  });

  it('opens a due scheduled booking into search', async () => {
    const { jobs, prisma, state } = harness();
    const scheduledAt = new Date(Date.now() + 10 * 60_000);
    prisma.booking.findUnique
      .mockResolvedValueOnce({ status: 'SCHEDULED', scheduledAt })
      .mockResolvedValueOnce({ status: 'CREATED', scheduledAt });

    await jobs.releaseScheduled('b1');

    expect(state.transition).toHaveBeenNthCalledWith(1, 'b1', 'CREATED', { type: 'SYSTEM' });
    expect(state.transition).toHaveBeenNthCalledWith(2, 'b1', 'SEARCHING_DRIVER', {
      type: 'SYSTEM',
    });
  });

  it('leaves a scheduled booking that is not due yet', async () => {
    const { jobs, prisma, state } = harness();
    prisma.booking.findUnique.mockResolvedValue({
      status: 'SCHEDULED',
      scheduledAt: new Date(Date.now() + 40 * 60_000),
    });

    await jobs.releaseScheduled('b1');

    expect(state.transition).not.toHaveBeenCalled();
  });

  it('continues the sweep when one release loses a race', async () => {
    const { jobs, prisma } = harness();
    prisma.booking.findMany.mockResolvedValue([{ id: 'b1' }, { id: 'b2' }]);
    const release = vi
      .spyOn(jobs, 'releaseScheduled')
      .mockRejectedValueOnce(new ConflictException('Booking changed, retry'))
      .mockRejectedValueOnce(new NotFoundException());

    await expect(jobs.sweepScheduled()).resolves.toBeUndefined();
    expect(release).toHaveBeenCalledTimes(2);
  });

  it('releases a due booking whose delayed job never ran', async () => {
    const { jobs, prisma } = harness();
    prisma.booking.findMany.mockResolvedValue([{ id: 'dropped' }]);
    const release = vi.spyOn(jobs, 'releaseScheduled').mockResolvedValue(undefined);

    await jobs.sweepScheduled();

    expect(prisma.booking.findMany).toHaveBeenCalledWith({
      where: {
        scheduledAt: { lte: expect.any(Date) },
        OR: [{ status: 'SCHEDULED' }, { status: 'CREATED' }],
      },
      select: { id: true },
    });
    const dueAt = prisma.booking.findMany.mock.calls[0]?.[0] as {
      where: { scheduledAt: { lte: Date } };
    };
    const leadMs = dueAt.where.scheduledAt.lte.getTime() - Date.now();
    expect(leadMs).toBeGreaterThan(14 * 60_000);
    expect(leadMs).toBeLessThanOrEqual(15 * 60_000);
    expect(release).toHaveBeenCalledWith('dropped');
  });
});

describe('dispatch queue ids', () => {
  it('names each attempt so a requeue cannot collide with the running job', async () => {
    const add = vi.fn(async (..._args: unknown[]) => undefined);
    const bull = new BullDispatchQueue({ add } as never, config);

    await bull.enqueueAttempt('b1', 4, 5_000);
    await bull.scheduleRelease('b1', new Date(Date.now() + 20 * 60_000));

    expect(add).toHaveBeenNthCalledWith(
      1,
      JOB_NAMES.dispatchAttempt,
      { bookingId: 'b1', n: 4 },
      expect.objectContaining({
        jobId: 'dispatch:b1:4',
        delay: 5_000,
        removeOnComplete: true,
      }),
    );
    const releaseOpts = add.mock.calls[1]?.[2] as { jobId: string; delay: number };
    expect(releaseOpts).toMatchObject({ jobId: 'scheduled:b1' });
    const delay = releaseOpts.delay;
    expect(delay).toBeGreaterThan(4 * 60_000);
    expect(delay).toBeLessThanOrEqual(5 * 60_000);
  });

  it('treats a duplicate job id as already queued', async () => {
    const add = vi.fn(async () => {
      throw new Error('Job dispatch:b1:4 already exists');
    });
    const bull = new BullDispatchQueue({ add } as never, config);

    await expect(bull.enqueueAttempt('b1', 4)).resolves.toBeUndefined();
  });
});

describe('JobsWorker dispatch jobs', () => {
  it('routes each dispatch job to the matching service method', async () => {
    const dispatch = {
      runAttempt: vi.fn(async () => undefined),
      expireOffer: vi.fn(async () => undefined),
      releaseScheduled: vi.fn(async () => undefined),
      sweepScheduled: vi.fn(async () => undefined),
    };
    const worker = new JobsWorker(
      { sweep: vi.fn() } as never,
      { flush: vi.fn() } as never,
      { purgeExpired: vi.fn() } as never,
      { purge: vi.fn() } as never,
      dispatch as never,
    );

    await worker.process({ name: JOB_NAMES.dispatchAttempt, data: { bookingId: 'b1', n: 2 } } as Job);
    await worker.process({ name: JOB_NAMES.offerExpire, data: { offerId: 'offer-1' } } as Job);
    await worker.process({ name: JOB_NAMES.scheduledRelease, data: { bookingId: 'b1' } } as Job);
    await worker.process({ name: JOB_NAMES.scheduledSweep, data: {} } as Job);
    await worker.process({ name: JOB_NAMES.offerExpire, data: {} } as Job);

    expect(dispatch.runAttempt).toHaveBeenCalledWith('b1', 2);
    expect(dispatch.expireOffer).toHaveBeenCalledTimes(1);
    expect(dispatch.expireOffer).toHaveBeenCalledWith('offer-1');
    expect(dispatch.releaseScheduled).toHaveBeenCalledWith('b1');
    expect(dispatch.sweepScheduled).toHaveBeenCalledTimes(1);
  });
});

describe('DispatchListener', () => {
  it('forwards booking events into the job service', async () => {
    const jobs = { onStatus: vi.fn(async () => undefined), onCreated: vi.fn(async () => undefined) };
    const listener = new DispatchListener(jobs as never);

    await listener.onStatus({ bookingId: 'b1', to: 'SEARCHING_DRIVER' });
    await listener.onCreated({ id: 'b1', status: 'SCHEDULED', scheduledAt: '2026-10-02T10:00:00.000Z' });

    expect(jobs.onStatus).toHaveBeenCalledWith({ bookingId: 'b1', to: 'SEARCHING_DRIVER' });
    expect(jobs.onCreated).toHaveBeenCalledWith({
      id: 'b1',
      status: 'SCHEDULED',
      scheduledAt: '2026-10-02T10:00:00.000Z',
    });
  });
});
