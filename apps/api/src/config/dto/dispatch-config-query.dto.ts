import { IsOptional, IsUUID } from 'class-validator';

export class DispatchConfigQuery {
  @IsOptional()
  @IsUUID()
  branchId?: string;
}
