import { IsString, MinLength } from 'class-validator';

export class LookupBookingQuery {
  @IsString()
  @MinLength(1)
  trackingId: string;
}
