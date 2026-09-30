import { IsString, MinLength } from 'class-validator';

export class LocationConsentDto {
  @IsString()
  @MinLength(1)
  version!: string;
}
