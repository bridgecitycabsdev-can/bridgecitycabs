import { Transform } from 'class-transformer';
import { IsOptional, IsString, Length, MaxLength, MinLength } from 'class-validator';

function trimString(value: unknown) {
  return typeof value === 'string' ? value.trim() : value;
}

export class DeletePassengerAccountDto {
  @Transform(({ value }) => trimString(value))
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  reason: string;

  @IsOptional()
  @Transform(({ value }) => trimString(value))
  @IsString()
  @MaxLength(500)
  feedback?: string;

  @Transform(({ value }) => trimString(value))
  @IsString()
  @Length(4, 8)
  otp: string;
}
