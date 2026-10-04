import { Prisma } from '@prisma/client';

/** Best-effort JSON for AuditLog.after — never throws. */
export function safeJson(
  value: unknown,
): Prisma.InputJsonValue | typeof Prisma.JsonNull {
  if (value === undefined || value === null) {
    return Prisma.JsonNull;
  }
  if (typeof value !== 'object') {
    return value as Prisma.InputJsonValue;
  }
  if (Buffer.isBuffer(value)) {
    return { type: 'buffer', byteLength: value.byteLength };
  }
  const name = (value as { constructor?: { name?: string } }).constructor?.name;
  if (
    name === 'StreamableFile' ||
    name === 'Readable' ||
    name === 'PassThrough'
  ) {
    return { type: name };
  }
  try {
    return JSON.parse(JSON.stringify(value)) as Prisma.InputJsonValue;
  } catch {
    return { type: 'unserializable', name: name ?? 'object' };
  }
}
