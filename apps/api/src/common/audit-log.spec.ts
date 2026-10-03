import { readFileSync, readdirSync, statSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';

const here = dirname(fileURLToPath(import.meta.url));
const schemaPath = join(here, '../../prisma/schema.prisma');
const srcRoot = join(here, '..');

function walkTs(dir: string, out: string[] = []) {
  for (const name of readdirSync(dir)) {
    if (name === 'node_modules' || name.endsWith('.spec.ts')) continue;
    const path = join(dir, name);
    if (statSync(path).isDirectory()) walkTs(path, out);
    else if (name.endsWith('.ts')) out.push(path);
  }
  return out;
}

describe('AuditLog', () => {
  it('is append-only in the Prisma schema', () => {
    const schema = readFileSync(schemaPath, 'utf8');
    const block = schema.match(/model AuditLog \{[\s\S]*?\n\}/)?.[0] ?? '';
    expect(block).toContain('createdAt');
    expect(block).not.toMatch(/updatedAt|@updatedAt|deletedAt/);
    expect(schema).toMatch(/Append-only/);
  });

  it('never updates or deletes audit rows from API code', () => {
    const hits: string[] = [];
    for (const file of walkTs(srcRoot)) {
      const text = readFileSync(file, 'utf8');
      if (/auditLog\.(update|delete|updateMany|deleteMany)\b/.test(text)) {
        hits.push(file);
      }
    }
    expect(hits).toEqual([]);
  });
});
