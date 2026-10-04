import { IsIn, IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class ResolveSosDto {
  @IsIn(['RESOLVED', 'FALSE_ALARM'])
  outcome!: 'RESOLVED' | 'FALSE_ALARM';

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  note?: string;
}
