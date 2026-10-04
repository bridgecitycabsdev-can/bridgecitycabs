import { IsOptional, IsUUID } from 'class-validator';

export class ClosingPeriodQuery {
  @IsOptional()
  @IsUUID()
  branchId?: string;
}
