import { FareZone, PaymentMethod } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsBoolean,
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { CreateBookingStopDto } from './create-booking.dto.js';

export class UpdateBookingDto {
  @Type(() => Number)
  @IsInt()
  @Min(0)
  version!: number;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  passengerName?: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(32)
  passengerPhone?: string;

  @IsOptional()
  @IsUUID()
  vehicleTypeId?: string;

  @IsOptional()
  @IsEnum(FareZone)
  zone?: FareZone;

  @IsOptional()
  @IsBoolean()
  vanOnly?: boolean;

  @IsOptional()
  @IsBoolean()
  ladyDriverOnly?: boolean;

  @IsOptional()
  @IsDateString()
  scheduledAt?: string;

  @IsOptional()
  @IsEnum(PaymentMethod)
  paymentMethod?: PaymentMethod;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  notes?: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  fixedFareCents?: number;

  @IsOptional()
  @ArrayMinSize(2)
  @ArrayMaxSize(10)
  @ValidateNested({ each: true })
  @Type(() => CreateBookingStopDto)
  stops?: CreateBookingStopDto[];
}
