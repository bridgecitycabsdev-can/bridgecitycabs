import { Inject, Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { spawn } from 'node:child_process';
import { createWriteStream } from 'node:fs';
import { mkdtemp, readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { pipeline } from 'node:stream/promises';
import { createGzip } from 'node:zlib';
import {
  OBJECT_STORAGE,
  type ObjectStorage,
} from '../storage/object-storage.js';

export const BACKUP_KEY_PREFIX = 'backups/';
const DEFAULT_RETENTION_DAYS = 30;

/**
 * Independent nightly logical dump to object storage so we are not solely
 * dependent on the managed Postgres vendor's PITR window.
 *
 * Uses MIGRATE_DATABASE_URL (migrator role — read-everything for pg_dump).
 * Never expose that URL on the public API surface; only the job worker.
 */
@Injectable()
export class DatabaseBackupService {
  private readonly logger = new Logger(DatabaseBackupService.name);

  constructor(
    private readonly config: ConfigService,
    @Inject(OBJECT_STORAGE) private readonly storage: ObjectStorage,
  ) {}

  async runNightlyBackup(now = new Date()) {
    const databaseUrl = this.config.get<string>('MIGRATE_DATABASE_URL')?.trim();
    if (!databaseUrl) {
      this.logger.warn(
        'MIGRATE_DATABASE_URL unset — skipping nightly DB backup (set the migrator connection string on the worker)',
      );
      return { skipped: true as const, reason: 'MIGRATE_DATABASE_URL unset' };
    }

    const ymd = formatYmd(now);
    const filename = `${BACKUP_KEY_PREFIX}bridgecabs_${ymd}.sql.gz`;
    const dir = await mkdtemp(join(tmpdir(), 'bridgecabs-backup-'));
    const tmpPath = join(dir, 'backup.sql.gz');

    try {
      await this.pgDumpGzip(databaseUrl, tmpPath);
      const body = await readFile(tmpPath);
      await this.storage.putObject(
        filename,
        body,
        'application/gzip',
      );
      this.logger.log(
        `Nightly backup uploaded ${filename} (${body.byteLength} B)`,
      );

      const pruned = await this.pruneOlderThan(this.retentionDays(), now);
      return {
        skipped: false as const,
        key: filename,
        bytes: body.byteLength,
        pruned,
      };
    } finally {
      await rm(dir, { recursive: true, force: true }).catch(() => undefined);
    }
  }

  /** Delete backup objects older than `days` (by date embedded in the key). */
  async pruneOlderThan(days: number, now = new Date()) {
    const keys = await this.storage.listObjectKeys(BACKUP_KEY_PREFIX);
    const cutoff = startOfUtcDay(now);
    cutoff.setUTCDate(cutoff.getUTCDate() - Math.max(0, days));
    let deleted = 0;
    for (const key of keys) {
      const ymd = backupKeyDate(key);
      if (!ymd) continue;
      const fileDay = new Date(`${ymd}T00:00:00.000Z`);
      if (fileDay.getTime() < cutoff.getTime()) {
        await this.storage.deleteObject(key);
        deleted += 1;
      }
    }
    if (deleted > 0) {
      this.logger.log(`Pruned ${deleted} backup(s) older than ${days} days`);
    }
    return deleted;
  }

  private retentionDays() {
    const raw = this.config.get<string>('BACKUP_RETENTION_DAYS');
    const n = Number.parseInt(raw?.trim() ?? '', 10);
    return Number.isFinite(n) && n > 0 ? n : DEFAULT_RETENTION_DAYS;
  }

  private async pgDumpGzip(databaseUrl: string, outPath: string) {
    const dump = spawn('pg_dump', [databaseUrl], {
      stdio: ['ignore', 'pipe', 'pipe'],
      shell: false,
    });
    const stderr: Buffer[] = [];
    dump.stderr?.on('data', (chunk: Buffer) => stderr.push(chunk));

    try {
      await pipeline(dump.stdout!, createGzip(), createWriteStream(outPath));
    } catch (err) {
      dump.kill('SIGTERM');
      throw err;
    }

    const code = await new Promise<number | null>((resolve) => {
      if (dump.exitCode != null) resolve(dump.exitCode);
      else dump.on('close', (c) => resolve(c));
    });
    if (code !== 0) {
      const detail = Buffer.concat(stderr).toString('utf8').trim();
      throw new Error(
        `pg_dump exited ${code}${detail ? `: ${detail}` : ''}`,
      );
    }
  }
}

export function formatYmd(date: Date) {
  return date.toISOString().slice(0, 10);
}

export function backupKeyDate(key: string): string | null {
  const m = /^backups\/bridgecabs_(\d{4}-\d{2}-\d{2})\.sql\.gz$/.exec(key);
  return m?.[1] ?? null;
}

function startOfUtcDay(date: Date) {
  return new Date(
    Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()),
  );
}
