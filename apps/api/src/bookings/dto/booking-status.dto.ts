import { BookingStatus, CancelReason } from '@prisma/client';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class BookingStatusDto {
  @IsEnum(BookingStatus)
  to: BookingStatus;

  @IsOptional()
  @IsEnum(CancelReason)
  reason?: CancelReason;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}