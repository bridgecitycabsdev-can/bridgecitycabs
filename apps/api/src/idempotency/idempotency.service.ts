import {
  ConflictException,
  Injectable,
  UnprocessableEntityException,
} from '@nestjs/common';
import { createHash } from 'node:crypto';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service.js';

export const IDEMPOTENCY_IN_PROGRESS =
  'A request with this idempotency key is already in progress';
export const IDEMPOTENCY_REUSED =
  'Idempotency key was reused with a different payload';

export type IdempotencyClaim =
  | { kind: 'proceed'; id: string }
  | {
      kind: 'replay';
      responseCode: number;
      responseBody: Prisma.JsonValue;
    };

export const IDEMPOTENCY_TTL_MS = 24 * 60 * 60 * 1000;

// Rows older than 24 hours are deleted by the daily idempotency-purge job.
@Injectable()
export class IdempotencyService {
  constructor(private readonly prisma: PrismaService) {}

  async purgeExpired(now = new Date()) {
    const result = await this.prisma.idempotencyKey.deleteMany({
      where: { createdAt: { lt: new Date(now.getTime() - IDEMPOTENCY_TTL_MS) } },
    });
    return result.count;
  }

  async claim(
    userId: string,
    key: string,
    requestHash: string,
  ): Promise<IdempotencyClaim> {
    const existing = await this.find(userId, key);
    if (existing) return this.interpret(existing, requestHash);

    try {
      const created = await this.prisma.idempotencyKey.create({
        data: { userId, key, requestHash },
      });
      return { kind: 'proceed', id: created.id };
    } catch (error) {
      if (!isUniqueConflict(error)) throw error;
      const raced = await this.find(userId, key);
      if (!raced || raced.responseCode === null) {
        throw new ConflictException(IDEMPOTENCY_IN_PROGRESS);
      }
      return this.interpret(raced, requestHash);
    }
  }

  async complete(id: string, responseCode: number, responseBody: unknown) {
    await this.prisma.idempotencyKey.update({
      where: { id },
      data: { responseCode, responseBody: toJson(responseBody) },
    });
  }

  async release(id: string) {
    await this.prisma.idempotencyKey.delete({ where: { id } }).catch(() => undefined);
  }

  private find(userId: string, key: string) {
    return this.prisma.idempotencyKey.findUnique({
      where: { userId_key: { userId, key } },
    });
  }

  private interpret(
    row: {
      requestHash: string;
      responseCode: number | null;
      responseBody: Prisma.JsonValue;
    },
    requestHash: string,
  ): IdempotencyClaim {
    if (row.requestHash !== requestHash) {
      throw new UnprocessableEntityException(IDEMPOTENCY_REUSED);
    }
    if (row.responseCode === null) {
      throw new ConflictException(IDEMPOTENCY_IN_PROGRESS);
    }
    return {
      kind: 'replay',
      responseCode: row.responseCode,
      responseBody: row.responseBody,
    };
  }
}

export function hashRequestBody(body: unknown) {
  const payload = body === undefined ? 'null' : JSON.stringify(body);
  return createHash('sha256').update(payload).digest('hex');
}

function toJson(value: unknown): Prisma.InputJsonValue | typeof Prisma.JsonNull {
  if (value === undefined) return Prisma.JsonNull;
  return JSON.parse(JSON.stringify(value)) as Prisma.InputJsonValue;
}

function isUniqueConflict(error: unknown) {
  return (
    error instanceof Prisma.PrismaClientKnownRequestError && error.code === 'P2002'
  );
}
