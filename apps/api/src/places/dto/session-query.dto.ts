import { IsString, Matches } from 'class-validator';
import { SESSION_TOKEN_PATTERN } from '../place-id.js';

export class SessionQuery {
  @IsString()
  @Matches(SESSION_TOKEN_PATTERN)
  session: string;
}
