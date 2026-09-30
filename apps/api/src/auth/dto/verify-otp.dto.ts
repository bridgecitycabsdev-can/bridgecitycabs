import { IsString, Matches, MinLength } from 'class-validator';

export class VerifyOtpDto {
  @IsString()
  @MinLength(1)
  phone: string;

  @IsString()
  @Matches(/^\d{6}$/)
  code: string;
}
