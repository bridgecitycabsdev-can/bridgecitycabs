import { IsBoolean, IsOptional, IsUUID } from 'class-validator';

export class AssignVehicleDto {
  @IsUUID()
  vehicleId: string;

  @IsOptional()
  @IsBoolean()
  reassign?: boolean;
}
