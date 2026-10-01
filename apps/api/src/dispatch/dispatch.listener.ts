import { Injectable } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import type { BookingStatus } from '@prisma/client';
import { DispatchJobsService } from './dispatch-jobs.service.js';

type StatusEvent = {
  bookingId: string;
  to: BookingStatus;
};

type CreatedEvent = {
  id: string;
  status: string;
  scheduledAt: string | null;
};

@Injectable()
export class DispatchListener {
  constructor(private readonly jobs: DispatchJobsService) {}

  @OnEvent('booking.status_changed')
  onStatus(event: StatusEvent) {
    return this.jobs.onStatus(event);
  }

  @OnEvent('booking.created')
  onCreated(event: CreatedEvent) {
    return this.jobs.onCreated(event);
  }
}
