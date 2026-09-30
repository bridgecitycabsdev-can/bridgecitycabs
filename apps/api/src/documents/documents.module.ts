import { Module } from '@nestjs/common';
import { DocumentsController } from './documents.controller.js';
import { DocumentsService } from './documents.service.js';
import { DriverDocumentsController } from './driver-documents.controller.js';
import { VehicleDocumentsController } from './vehicle-documents.controller.js';

@Module({
  controllers: [
    DriverDocumentsController,
    VehicleDocumentsController,
    DocumentsController,
  ],
  providers: [DocumentsService],
})
export class DocumentsModule {}
