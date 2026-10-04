import { IsOptional, IsUUID } from 'class-validator';

export class RunPayoutsQuery {
  @IsOptional()
  @IsUUID()
  branchId?: string;
}
