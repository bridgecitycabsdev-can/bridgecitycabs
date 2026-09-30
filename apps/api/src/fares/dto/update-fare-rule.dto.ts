import { FareZone } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';

export class UpdateFareRuleDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsOptional()
  @IsUUID()
  vehicleTypeId?: string;

  @IsOptional()
  @IsEnum(FareZone)
  zone?: FareZone;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(80)
  title?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  baseFareCents?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  perKmCents?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  perMinuteCents?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  minFareCents?: number;

  @IsOptional()
  @IsBoolean()
  active?: boolean;
}
