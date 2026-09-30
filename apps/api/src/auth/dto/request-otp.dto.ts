import { IsString, MinLength } from 'class-validator';

export class RequestOtpDto {
  @IsString()
  @MinLength(1)
  phone: string;
}
