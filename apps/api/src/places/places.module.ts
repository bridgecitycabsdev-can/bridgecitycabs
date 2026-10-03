import { Module } from '@nestjs/common';
import { GooglePlacesProvider } from './google-places.provider.js';
import { PLACES_PROVIDER } from './places.provider.js';
import { PlacesController } from './places.controller.js';
import { PlacesService } from './places.service.js';

@Module({
  controllers: [PlacesController],
  providers: [
    PlacesService,
    GooglePlacesProvider,
    { provide: PLACES_PROVIDER, useExisting: GooglePlacesProvider },
  ],
})
export class PlacesModule {}
