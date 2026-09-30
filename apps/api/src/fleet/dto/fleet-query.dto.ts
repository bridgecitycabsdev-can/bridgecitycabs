import { IsOptional, IsUUID } from 'class-validator';

export class FleetQuery {
  @IsOptional()
  @IsUUID()
  branchId?: string;
}
