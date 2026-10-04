import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class MarkPayoutSentDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  reference?: string;
}
