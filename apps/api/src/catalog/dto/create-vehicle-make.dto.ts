import { IsString, MinLength } from 'class-validator';

export class CreateVehicleMakeDto {
  @IsString()
  @MinLength(1)
  name: string;
}
