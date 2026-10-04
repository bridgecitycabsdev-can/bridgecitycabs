import { Type } from 'class-transformer';
import {
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';

export class RecordInvoicePaymentDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  amountCents!: number;

  @IsString()
  @MinLength(1)
  @MaxLength(80)
  method!: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  reference?: string;
}
