import { PromoType } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsDate,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
  MinLength,
  ValidateIf,
} from 'class-validator';

export class CreatePromoCodeDto {
  @IsString()
  @MinLength(1)
  @MaxLength(40)
  code!: string;

  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsEnum(PromoType)
  type!: PromoType;

  @ValidateIf((o: CreatePromoCodeDto) => o.type === PromoType.PERCENT)
  @Type(() => Number)
  @IsInt()
  @Min(1)
  valueBps?: number;

  @ValidateIf((o: CreatePromoCodeDto) => o.type === PromoType.FIXED)
  @Type(() => Number)
  @IsInt()
  @Min(1)
  valueCents?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  maxDiscountCents?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  minSubtotalCents?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  usageLimitTotal?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  usageLimitPerPassenger?: number | null;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  startAt?: Date;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  endAt?: Date;

  @IsOptional()
  @IsBoolean()
  active?: boolean;
}
