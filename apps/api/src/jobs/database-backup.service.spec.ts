import { describe, expect, it, vi } from 'vitest';
import {
  backupKeyDate,
  DatabaseBackupService,
  formatYmd,
} from './database-backup.service.js';

describe('DatabaseBackupService', () => {
  it('formats backup keys as backups/bridgecabs_yyyy-MM-dd.sql.gz', () => {
    expect(formatYmd(new Date('2026-10-04T18:00:00.000Z'))).toBe('2026-10-04');
    expect(backupKeyDate('backups/bridgecabs_2026-09-01.sql.gz')).toBe(
      '2026-09-01',
    );
    expect(backupKeyDate('backups/other.sql.gz')).toBeNull();
  });

  it('skips when MIGRATE_DATABASE_URL is unset', async () => {
    const putObject = vi.fn();
    const service = new DatabaseBackupService(
      { get: () => undefined } as never,
      { putObject, listObjectKeys: vi.fn(), deleteObject: vi.fn() } as never,
    );
    await expect(service.runNightlyBackup()).resolves.toEqual({
      skipped: true,
      reason: 'MIGRATE_DATABASE_URL unset',
    });
    expect(putObject).not.toHaveBeenCalled();
  });

  it('pruneOlderThan deletes keys past BACKUP_RETENTION_DAYS', async () => {
    const deleteObject = vi.fn(async () => undefined);
    const listObjectKeys = vi.fn(async () => [
      'backups/bridgecabs_2026-08-01.sql.gz',
      'backups/bridgecabs_2026-09-20.sql.gz',
      'backups/bridgecabs_2026-10-03.sql.gz',
      'backups/readme.txt',
    ]);
    const service = new DatabaseBackupService(
      { get: () => '30' } as never,
      { putObject: vi.fn(), listObjectKeys, deleteObject } as never,
    );
    const deleted = await service.pruneOlderThan(
      30,
      new Date('2026-10-04T12:00:00.000Z'),
    );
    expect(deleted).toBe(1);
    expect(deleteObject).toHaveBeenCalledTimes(1);
    expect(deleteObject).toHaveBeenCalledWith(
      'backups/bridgecabs_2026-08-01.sql.gz',
    );
  });
});
