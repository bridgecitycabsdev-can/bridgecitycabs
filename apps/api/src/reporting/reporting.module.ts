import { Module } from '@nestjs/common';
import { QueueModule } from '../jobs/queue.module.js';
import { NotificationsModule } from '../notifications/notifications.module.js';
import { PdfModule } from '../pdf/pdf.module.js';
import { StorageModule } from '../storage/storage.module.js';
import { BookingReportService } from './booking-report.service.js';
import { DailyStatsService } from './daily-stats.service.js';
import { DashboardController } from './dashboard.controller.js';
import { DashboardService } from './dashboard.service.js';
import { ReportsController } from './reports.controller.js';

@Module({
  imports: [QueueModule, NotificationsModule, StorageModule, PdfModule],
  controllers: [DashboardController, ReportsController],
  providers: [DailyStatsService, DashboardService, BookingReportService],
  exports: [DailyStatsService, DashboardService, BookingReportService],
})
export class ReportingModule {}
