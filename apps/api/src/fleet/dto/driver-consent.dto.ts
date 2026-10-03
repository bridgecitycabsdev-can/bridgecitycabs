import { IsIn, IsOptional, IsString, MinLength } from 'class-validator';

export const LOCATION_TRACKING_CONSENT = 'LOCATION_TRACKING' as const;

export class DriverConsentDto {
  @IsIn([LOCATION_TRACKING_CONSENT])
  type!: typeof LOCATION_TRACKING_CONSENT;

  @IsString()
  @MinLength(1)
  version!: string;

  @IsOptional()
  @IsString()
  appVersion?: string;
}
