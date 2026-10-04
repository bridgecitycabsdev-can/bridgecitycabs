import { CancelReason, FareZone, PaymentMethod } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsBoolean,
  IsDateString,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
  ValidateIf,
  ValidateNested,
} from 'class-validator';
import { CreateBookingStopDto } from '../../bookings/dto/create-booking.dto.js';

export class PassengerCreateBookingDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsUUID()
  vehicleTypeId: string;

  @IsEnum(FareZone)
  zone: FareZone;

  @IsString()
  @MinLength(1)
  @MaxLength(4000)
  quoteToken!: string;

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

  /** Saved PassengerPaymentMethod id; required when paymentMethod is CARD. */
  @ValidateIf((dto: PassengerCreateBookingDto) => dto.paymentMethod === 'CARD')
  @IsUUID()
  paymentMethodId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  notes?: string;

  @ArrayMinSize(2)
  @ArrayMaxSize(10)
  @ValidateNested({ each: true })
  @Type(() => CreateBookingStopDto)
  stops!: CreateBookingStopDto[];
}

export class PassengerCancelBookingDto {
  @IsOptional()
  @IsEnum(CancelReason)
  reason?: CancelReason;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}
