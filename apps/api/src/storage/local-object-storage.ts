import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHmac, timingSafeEqual } from 'node:crypto';
import { mkdir, readdir, rm, stat, writeFile } from 'node:fs/promises';
import { dirname, join, relative, sep } from 'node:path';
import type { ObjectStorage } from './object-storage.js';

/**
 * Dev/test fallback when R2 credentials are unset. Files land under
 * `.data/object-storage/` and signed URLs point at GET /reports/files/...
 */
@Injectable()
export class LocalObjectStorage implements ObjectStorage {
  private readonly logger = new Logger(LocalObjectStorage.name);
  private readonly root: string;
  private readonly publicBase: string;
  private readonly signingSecret: string;

  constructor(config: ConfigService) {
    this.root = join(process.cwd(), '.data', 'object-storage');
    this.publicBase = (
      config.get<string>('API_PUBLIC_URL')?.trim() ||
      'http://localhost:3000'
    ).replace(/\/$/, '');
    this.signingSecret =
      config.get<string>('QUOTE_SECRET')?.trim() ||
      config.get<string>('JWT_ACCESS_SECRET')?.trim() ||
      'local-object-storage';
  }

  async putObject(key: string, body: Buffer, contentType: string) {
    const path = join(this.root, key);
    await mkdir(dirname(path), { recursive: true });
    await writeFile(path, body);
    await writeFile(`${path}.ctype`, contentType, 'utf8');
    this.logger.debug(`Stored local object ${key} (${body.length} B)`);
  }

  async signedUrl(key: string, ttlSeconds: number) {
    const exp = Math.floor(Date.now() / 1000) + Math.max(60, ttlSeconds);
    const sig = sign(this.signingSecret, key, exp);
    const q = new URLSearchParams({
      key,
      exp: String(exp),
      sig,
    });
    return `${this.publicBase}/api/v1/reports/files?${q.toString()}`;
  }

  absolutePath(key: string) {
    return join(this.root, key);
  }

  verifySignature(key: string, exp: number, sig: string) {
    if (!Number.isFinite(exp) || exp * 1000 < Date.now()) return false;
    const expected = sign(this.signingSecret, key, exp);
    try {
      return timingSafeEqual(Buffer.from(expected), Buffer.from(sig));
    } catch {
      return false;
    }
  }

  async listObjectKeys(prefix: string) {
    const keys: string[] = [];
    await walkFiles(this.root, async (abs) => {
      if (abs.endsWith('.ctype')) return;
      const rel = relative(this.root, abs).split(sep).join('/');
      if (rel.startsWith(prefix)) keys.push(rel);
    });
    return keys;
  }

  async deleteObject(key: string) {
    const path = join(this.root, key);
    await rm(path, { force: true });
    await rm(`${path}.ctype`, { force: true });
  }
}

async function walkFiles(dir: string, visit: (abs: string) => Promise<void>) {
  let entries: string[];
  try {
    entries = await readdir(dir);
  } catch {
    return;
  }
  for (const name of entries) {
    const abs = join(dir, name);
    const info = await stat(abs);
    if (info.isDirectory()) await walkFiles(abs, visit);
    else await visit(abs);
  }
}

function sign(secret: string, key: string, exp: number) {
  return createHmac('sha256', secret)
    .update(`${key}:${exp}`)
    .digest('hex');
}
