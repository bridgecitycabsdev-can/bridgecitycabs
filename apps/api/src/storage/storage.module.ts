import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { LocalObjectStorage } from './local-object-storage.js';
import { OBJECT_STORAGE } from './object-storage.js';
import { R2ObjectStorage } from './r2-object-storage.js';

function r2Configured(config: ConfigService) {
  return Boolean(
    config.get<string>('R2_ACCOUNT_ID')?.trim() &&
      config.get<string>('R2_ACCESS_KEY_ID')?.trim() &&
      config.get<string>('R2_SECRET_ACCESS_KEY')?.trim() &&
      config.get<string>('R2_BUCKET')?.trim(),
  );
}

@Module({
  imports: [ConfigModule],
  providers: [
    LocalObjectStorage,
    {
      provide: OBJECT_STORAGE,
      inject: [ConfigService, LocalObjectStorage],
      useFactory: (config: ConfigService, local: LocalObjectStorage) => {
        if (r2Configured(config)) {
          return new R2ObjectStorage(config);
        }
        return local;
      },
    },
  ],
  exports: [OBJECT_STORAGE, LocalObjectStorage],
})
export class StorageModule {}
