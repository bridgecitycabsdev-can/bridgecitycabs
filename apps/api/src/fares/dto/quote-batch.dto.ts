import { FareZone } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
  ValidateNested,
} from 'class-validator';
import { QuoteStopDto } from './quote-fare.dto.js';

export class QuoteBatchDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  /** Staff may override the derived zone. Passengers cannot. */
  @IsOptional()
  @IsEnum(FareZone)
  zone?: FareZone;

  /** Passenger-app promo code. Ignored on staff /fares/quotes. */
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(40)
  promoCode?: string;

  @ArrayMinSize(2)
  @ArrayMaxSize(10)
  @ValidateNested({ each: true })
  @Type(() => QuoteStopDto)
  stops: QuoteStopDto[];
}
