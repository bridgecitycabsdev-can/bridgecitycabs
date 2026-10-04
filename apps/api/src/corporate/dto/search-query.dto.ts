import { IsOptional, IsString, MaxLength, MinLength } from 'class-validator';

export class SearchQuery {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  q?: string;
}
