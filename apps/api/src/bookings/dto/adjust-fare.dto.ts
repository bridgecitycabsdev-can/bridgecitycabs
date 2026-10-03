import { IsInt, IsString, MaxLength, Min, MinLength } from 'class-validator';

export class AdjustFareDto {
  @IsInt()
  @Min(0)
  subtotalCents!: number;

  @IsString()
  @MinLength(1)
  @MaxLength(500)
  reason!: string;
}
