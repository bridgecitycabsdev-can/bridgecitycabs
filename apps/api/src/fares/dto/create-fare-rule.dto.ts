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

export class CreateFareRuleDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsUUID()
  vehicleTypeId: string;

  @IsEnum(FareZone)
  zone: FareZone;

  @IsString()
  @MinLength(1)
  @MaxLength(80)
  title: string;

  @Type(() => Number)
  @IsInt()
  @Min(0)
  baseFareCents: number;

  @Type(() => Number)
  @IsInt()
  @Min(0)
  perKmCents: number;

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
