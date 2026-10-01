import { BadRequestException, ForbiddenException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { FaresService } from './fares.service.js';

const vehicleTypeId = '33333333-3333-4333-8333-333333333333';
const quote = {
  vehicleTypeId,
  zone: 'INSIDE_TOWN' as const,
  stops: [
    { lat: 49.69, lng: -112.84 },
    { lat: 49.63, lng: -112.8 },
  ],
};

function service() {
  const prisma = {
    branch: {
      findUnique: vi.fn(async ({ where }: { where: { id: string } }) => ({
        id: where.id,
        gstRateBps: 500,
      })),
    },
    vehicleType: { findUnique: vi.fn(async () => null) },
    fareRule: { findUnique: vi.fn() },
  };
  const fares = new FaresService(prisma as never, { estimate: vi.fn() } as never);
  return { fares, prisma };
}

describe('FaresService quote branch', () => {
  it('lets a passenger quote their own branch, or a branch they name when they have none', async () => {
    const own = service();
    await expect(
      own.fares.quote(
        { ...quote, branchId: 'branch-other' },
        { userId: 'user-1', role: 'passenger', branchId: 'branch-own' },
      ),
    ).rejects.toThrow();
    expect(own.prisma.branch.findUnique).toHaveBeenCalledWith({ where: { id: 'branch-own' } });

    const named = service();
    await expect(
      named.fares.quote(
        { ...quote, branchId: 'branch-named' },
        { userId: 'user-1', role: 'passenger', branchId: null },
      ),
    ).rejects.toThrow();
    expect(named.prisma.branch.findUnique).toHaveBeenCalledWith({ where: { id: 'branch-named' } });

    const missing = service();
    await expect(
      missing.fares.quote(quote, { userId: 'user-1', role: 'passenger', branchId: null }),
    ).rejects.toBeInstanceOf(BadRequestException);
    expect(missing.prisma.branch.findUnique).not.toHaveBeenCalled();
  });

  it('still refuses a staff user with no branch', async () => {
    const { fares, prisma } = service();
    await expect(
      fares.quote(quote, { userId: 'user-1', role: 'dispatcher', branchId: null }),
    ).rejects.toBeInstanceOf(ForbiddenException);
    expect(prisma.branch.findUnique).not.toHaveBeenCalled();
  });
});
