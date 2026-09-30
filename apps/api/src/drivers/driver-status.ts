import { BadRequestException } from '@nestjs/common';
import { DriverStatus } from '@prisma/client';

const TRANSITIONS: Record<DriverStatus, readonly DriverStatus[]> = {
  PENDING_DOCUMENTS: ['PENDING_APPROVAL', 'APPROVED'],
  PENDING_APPROVAL: ['APPROVED', 'REJECTED'],
  APPROVED: ['SUSPENDED'],
  SUSPENDED: ['APPROVED'],
  REJECTED: ['PENDING_APPROVAL'],
};

export function assertDriverTransition(from: DriverStatus, to: DriverStatus) {
  if (!TRANSITIONS[from].includes(to)) {
    throw new BadRequestException(
      `Cannot change driver status from ${from} to ${to}`,
    );
  }
}
