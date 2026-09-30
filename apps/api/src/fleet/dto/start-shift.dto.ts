import { IsOptional, IsUUID } from 'class-validator';

export class StartShiftDto {
  @IsOptional()
  @IsUUID()
  vehicleId?: string;
}
