import { Transform } from 'class-transformer';
import { IsString, Matches, MaxLength, MinLength } from 'class-validator';
import { SESSION_TOKEN_PATTERN } from '../place-id.js';

export class AutocompleteQuery {
  @Transform(({ value }) => (typeof value === 'string' ? value.trim() : value))
  @IsString()
  @MinLength(3)
  @MaxLength(100)
  q: string;

  @IsString()
  @Matches(SESSION_TOKEN_PATTERN)
  session: string;
}
