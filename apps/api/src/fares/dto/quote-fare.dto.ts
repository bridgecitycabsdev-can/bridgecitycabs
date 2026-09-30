import { FareZone } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsEnum,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsUUID,
  ValidateNested,
} from 'class-validator';

export class QuoteStopDto {
  @Type(() => Number)
  @IsLatitude()
  lat: number;

  @Type(() => Number)
  @IsLongitude()
  lng: number;
}

export class QuoteFareDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsUUID()
  vehicleTypeId: string;

  @IsEnum(FareZone)
  zone: FareZone;

  @ArrayMinSize(2)
  @ArrayMaxSize(10)
  @ValidateNested({ each: true })
  @Type(() => QuoteStopDto)
  stops: QuoteStopDto[];
}
