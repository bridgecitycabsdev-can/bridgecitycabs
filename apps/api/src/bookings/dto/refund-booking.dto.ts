import { IsInt, IsString, MaxLength, Min, MinLength } from 'class-validator';

export class RefundBookingDto {
  @IsInt()
  @Min(1)
  amountCents!: number;

  @IsString()
  @MinLength(1)
  @MaxLength(500)
  reason!: string;
}
