import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsDate,
  IsInt,
  IsOptional,
  IsUUID,
  Min,
} from 'class-validator';

export class CreateLeaseAgreementDto {
  @IsUUID()
  driverId!: string;

  @IsUUID()
  vehicleId!: string;

  @IsInt()
  @Min(1)
  weeklyAmountCents!: number;

  @Type(() => Date)
  @IsDate()
  startDate!: Date;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  endDate?: Date;

  @IsOptional()
  @IsBoolean()
  active?: boolean;
}
