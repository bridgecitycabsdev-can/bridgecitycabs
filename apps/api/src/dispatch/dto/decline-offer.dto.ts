import { IsOptional, IsString, MaxLength } from 'class-validator';

export class DeclineOfferDto {
  @IsOptional()
  @IsString()
  @MaxLength(500)
  reason?: string;
}
