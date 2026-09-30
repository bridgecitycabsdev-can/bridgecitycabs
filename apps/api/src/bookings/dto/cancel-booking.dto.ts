import { CancelReason } from '@prisma/client';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class CancelBookingDto {
  @IsEnum(CancelReason)
  reason: CancelReason;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}
