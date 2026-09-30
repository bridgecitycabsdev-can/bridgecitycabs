import { IsOptional, IsUUID } from 'class-validator';

export class AssignBookingDto {
  @IsUUID()
  driverId: string;

  @IsOptional()
  @IsUUID()
  vehicleId?: string;
}
