import { IsString, MaxLength, MinLength } from 'class-validator';

export class ReleaseBookingDto {
  @IsString()
  @MinLength(1)
  @MaxLength(500)
  reason!: string;
}
