import { BadRequestException } from '@nestjs/common';

export function assertScheduledAt(
  scheduledAt: Date,
  now: Date,
  leadMinutes: number,
  maxAdvanceDays: number,
) {
  const earliest = now.getTime() + leadMinutes * 60_000;
  const latest = now.getTime() + maxAdvanceDays * 24 * 60 * 60_000;
  if (scheduledAt.getTime() < earliest) {
    throw new BadRequestException(
      `scheduledAt must be at least ${leadMinutes} minutes ahead`,
    );
  }
  if (scheduledAt.getTime() > latest) {
    throw new BadRequestException(
      `scheduledAt must be no more than ${maxAdvanceDays} days out`,
    );
  }
}
