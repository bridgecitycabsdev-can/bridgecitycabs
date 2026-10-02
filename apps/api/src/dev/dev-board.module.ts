import { Module } from '@nestjs/common';
import { BullMQAdapter } from '@bull-board/api/bullMQAdapter';
import { ExpressAdapter } from '@bull-board/express';
import { BullBoardModule } from '@bull-board/nestjs';
import { JOBS_QUEUE } from '../jobs/job-names.js';
import { QueueModule } from '../jobs/queue.module.js';

/** Dev-only view of the bridgecabs queue. Not registered in production or tests. */
@Module({
  imports: [
    QueueModule,
    BullBoardModule.forRoot({
      route: 'admin/queues',
      adapter: ExpressAdapter,
    }),
    BullBoardModule.forFeature({
      name: JOBS_QUEUE,
      adapter: BullMQAdapter,
    }),
  ],
})
export class DevBoardModule {}
