import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { FleetStateService } from '../fleet/fleet-state.service.js';
import { DriverPublisher } from './driver-publisher.js';
import { FleetBroadcaster } from './fleet-broadcaster.js';

export const RECONCILE_INTERVAL_MS = 60_000;

@Injectable()
export class FleetReconciler implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(FleetReconciler.name);
  private timer?: ReturnType<typeof setInterval>;
  private tail: Promise<void> = Promise.resolve();

  constructor(
    private readonly fleet: FleetStateService,
    private readonly drivers: DriverPublisher,
    private readonly broadcaster: FleetBroadcaster,
  ) {}

  onModuleInit() {
    void this.sweep();
    this.timer = setInterval(() => void this.sweep(), RECONCILE_INTERVAL_MS);
    this.timer.unref?.();
  }

  onModuleDestroy() {
    if (this.timer) clearInterval(this.timer);
  }

  sweep() {
    const job = this.tail.then(() => this.run());
    this.tail = job.then(
      () => undefined,
      () => undefined,
    );
    return job;
  }

  private async run() {
    try {
      const changes = await this.fleet.reconcile();
      for (const change of changes) {
        this.drivers.emitState(change.driverId, change.snapshot);
        this.broadcaster.mark(change.branchId, change.driverId);
      }
      return changes;
    } catch (error) {
      this.logger.error(
        `Fleet reconcile failed: ${error instanceof Error ? error.message : 'unknown error'}`,
      );
      return [];
    }
  }
}
