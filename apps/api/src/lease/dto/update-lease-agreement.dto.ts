import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsDate,
  IsInt,
  IsOptional,
  Min,
  ValidateIf,
} from 'class-validator';

export class UpdateLeaseAgreementDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  weeklyAmountCents?: number;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  startDate?: Date;

  @IsOptional()
  @ValidateIf((_, value) => value !== null)
  @Type(() => Date)
  @IsDate()
  endDate?: Date | null;

  @IsOptional()
  @IsBoolean()
  active?: boolean;
}
