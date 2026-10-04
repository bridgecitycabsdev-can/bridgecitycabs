import { IsISO8601, IsOptional, IsUUID } from 'class-validator';

export class RunClosingQuery {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  /** ISO weekStart (branch-local Monday UTC instant). Defaults to previous week. */
  @IsOptional()
  @IsISO8601()
  weekStart?: string;
}
