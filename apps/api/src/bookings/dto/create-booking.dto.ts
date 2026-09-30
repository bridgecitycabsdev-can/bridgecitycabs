import { FareZone, PaymentMethod } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsBoolean,
  IsDateString,
  IsEnum,
  IsInt,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  Min,
  MinLength,
  ValidateNested,
} from 'class-validator';

export class CreateBookingStopDto {
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  address: string;

  @Type(() => Number)
  @IsLatitude()
  lat: number;

  @Type(() => Number)
  @IsLongitude()
  lng: number;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  placeId?: string;
}

export class CreateBookingDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsString()
  @MinLength(1)
  @MaxLength(120)
  passengerName: string;

  @IsString()
  @MinLength(1)
  @MaxLength(32)
  passengerPhone: string;

  @IsUUID()
  vehicleTypeId: string;

  @IsEnum(FareZone)
  zone: FareZone;

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

  @ArrayMinSize(2)
  @ArrayMaxSize(10)
  @ValidateNested({ each: true })
  @Type(() => CreateBookingStopDto)
  stops: CreateBookingStopDto[];
}
