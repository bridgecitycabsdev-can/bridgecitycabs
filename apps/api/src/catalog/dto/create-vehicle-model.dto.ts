import { IsOptional, IsString, IsUUID, MinLength } from 'class-validator';

export class CreateVehicleModelDto {
  @IsUUID()
  makeId: string;

  @IsUUID()
  vehicleTypeId: string;

  @IsString()
  @MinLength(1)
  name: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  bodyType?: string;
}
