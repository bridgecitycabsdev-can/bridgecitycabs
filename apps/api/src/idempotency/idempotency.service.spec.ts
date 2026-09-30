import {
  ConflictException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { describe, expect, it } from 'vitest';
import {
  hashRequestBody,
  IDEMPOTENCY_IN_PROGRESS,
  IDEMPOTENCY_REUSED,
  IdempotencyService,
} from './idempotency.service.js';

type Row = {
  id: string;
  userId: string;
  key: string;
  requestHash: string;
  responseCode: number | null;
  responseBody: Prisma.JsonValue;
};

describe('hashRequestBody', () => {
  it('is a stable sha-256 of the JSON body', () => {
    expect(hashRequestBody({ amount: 595 })).toBe(hashRequestBody({ amount: 595 }));
    expect(hashRequestBody({ amount: 595 })).not.toBe(hashRequestBody({ amount: 600 }));
  });
});

describe('IdempotencyService', () => {
  function setup() {
    const rows: Row[] = [];
    let nextId = 1;
    const prisma = {
      idempotencyKey: {
        findUnique: async ({
          where,
        }: {
          where: { userId_key: { userId: string; key: string } };
        }) =>
          rows.find(
            (row) =>
              row.userId === where.userId_key.userId &&
              row.key === where.userId_key.key,
          ) ?? null,
        create: async ({
          data,
        }: {
          data: { userId: string; key: string; requestHash: string };
        }) => {
          if (rows.some((row) => row.userId === data.userId && row.key === data.key)) {
            throw new Prisma.PrismaClientKnownRequestError('Unique constraint', {
              code: 'P2002',
              clientVersion: 'test',
            });
          }
          const row: Row = {
            id: `row-${nextId++}`,
            responseCode: null,
            responseBody: null,
            ...data,
          };
          rows.push(row);
          return row;
        },
        update: async ({
          where,
          data,
        }: {
          where: { id: string };
          data: { responseCode: number; responseBody: Prisma.InputJsonValue };
        }) => {
          const row = rows.find((item) => item.id === where.id);
          if (!row) throw new Error('missing');
          row.responseCode = data.responseCode;
          row.responseBody = data.responseBody as Prisma.JsonValue;
          return row;
        },
        delete: async ({ where }: { where: { id: string } }) => {
          const index = rows.findIndex((row) => row.id === where.id);
          if (index >= 0) rows.splice(index, 1);
        },
      },
    };
    return {
      service: new IdempotencyService(prisma as never),
      prisma,
      rows,
    };
  }

  it('stores a successful response and replays it for the same payload', async () => {
    const { service } = setup();
    const hash = hashRequestBody({ amount: 595 });
    const claim = await service.claim('user-1', 'key-1', hash);
    expect(claim.kind).toBe('proceed');
    if (claim.kind !== 'proceed') return;

    await service.complete(claim.id, 201, { bookingId: 'b1' });
    await expect(service.claim('user-1', 'key-1', hash)).resolves.toEqual({
      kind: 'replay',
      responseCode: 201,
      responseBody: { bookingId: 'b1' },
    });
  });

  it('rejects the same key used with a different payload', async () => {
    const { service } = setup();
    await service.claim('user-1', 'key-1', hashRequestBody({ amount: 595 }));
    await expect(
      service.claim('user-1', 'key-1', hashRequestBody({ amount: 600 })),
    ).rejects.toBeInstanceOf(UnprocessableEntityException);
    await expect(
      service.claim('user-1', 'key-1', hashRequestBody({ amount: 600 })),
    ).rejects.toThrow(IDEMPOTENCY_REUSED);
  });

  it('returns 409 while an identical request is still in progress', async () => {
    const { service } = setup();
    const hash = hashRequestBody({ amount: 595 });
    await service.claim('user-1', 'key-1', hash);
    await expect(service.claim('user-1', 'key-1', hash)).rejects.toThrow(
      IDEMPOTENCY_IN_PROGRESS,
    );
    await expect(service.claim('user-1', 'key-1', hash)).rejects.toBeInstanceOf(
      ConflictException,
    );
  });

  it('turns a lost insert race into 409 until the winner stores a response', async () => {
    const { service, prisma, rows } = setup();
    const hash = hashRequestBody({ amount: 595 });
    rows.push({
      id: 'winner',
      userId: 'user-1',
      key: 'key-1',
      requestHash: hash,
      responseCode: null,
      responseBody: null,
    });
    let lookups = 0;
    const find = prisma.idempotencyKey.findUnique;
    prisma.idempotencyKey.findUnique = async (args) => {
      lookups += 1;
      if (lookups === 1) return null;
      return find(args);
    };

    await expect(service.claim('user-1', 'key-1', hash)).rejects.toThrow(
      IDEMPOTENCY_IN_PROGRESS,
    );

    rows[0].responseCode = 201;
    rows[0].responseBody = { bookingId: 'b1' };
    lookups = 0;
    await expect(service.claim('user-1', 'key-1', hash)).resolves.toEqual({
      kind: 'replay',
      responseCode: 201,
      responseBody: { bookingId: 'b1' },
    });
  });

  it('releases a failed claim so the same payload can be retried', async () => {
    const { service, rows } = setup();
    const hash = hashRequestBody({ amount: 595 });
    const claim = await service.claim('user-1', 'key-1', hash);
    if (claim.kind !== 'proceed') throw new Error('expected a new claim');
    await service.release(claim.id);
    expect(rows).toHaveLength(0);
    await expect(service.claim('user-1', 'key-1', hash)).resolves.toMatchObject({
      kind: 'proceed',
    });
  });
});
