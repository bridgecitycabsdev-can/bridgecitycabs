import { IsDateString } from 'class-validator';

export class DriverEarningsQuery {
  @IsDateString()
  from!: string;

  @IsDateString()
  to!: string;
}
