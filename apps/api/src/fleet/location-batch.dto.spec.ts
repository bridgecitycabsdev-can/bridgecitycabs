import 'reflect-metadata';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { describe, expect, it } from 'vitest';
import { LocationBatchDto } from './dto/location-batch.dto.js';

function point(n: number) {
  return {
    lat: 49.69 + n * 0.0001,
    lng: -112.84,
    accuracy: 8,
    recordedAt: new Date(Date.UTC(2026, 9, 3, 12, 0, n)).toISOString(),
  };
}

describe('LocationBatchDto', () => {
  it('rejects more than 20 points', async () => {
    const dto = plainToInstance(LocationBatchDto, {
      points: Array.from({ length: 21 }, (_, i) => point(i)),
    });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(JSON.stringify(errors)).toMatch(/points|arrayMaxSize|max/i);
  });

  it('accepts up to 20 points', async () => {
    const dto = plainToInstance(LocationBatchDto, {
      points: Array.from({ length: 20 }, (_, i) => point(i)),
    });
    const errors = await validate(dto);
    expect(errors).toHaveLength(0);
  });
});
