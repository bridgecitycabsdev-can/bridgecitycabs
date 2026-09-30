import { IsOptional, IsString, MaxLength } from 'class-validator';

export class UnassignBookingDto {
  @IsOptional()
  @IsString()
  @MaxLength(500)
  reason?: string;
}
