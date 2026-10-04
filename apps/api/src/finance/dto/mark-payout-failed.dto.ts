import { IsString, MaxLength, MinLength } from 'class-validator';

export class MarkPayoutFailedDto {
  @IsString()
  @MinLength(1)
  @MaxLength(500)
  note!: string;
}
