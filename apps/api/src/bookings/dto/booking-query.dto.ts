import {
  BookingSource,
  BookingStatus,
  FareZone,
  PaymentMethod,
  PaymentStatus,
} from '@prisma/client';
import {
  IsDateString,
  IsEnum,
  IsIn,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';
import { PageQuery } from '../../common/pagination.js';
import { BOOKING_TABS, type BookingTab } from '../booking-tabs.js';

const TABS = [...Object.keys(BOOKING_TABS), 'timeout'] as const;

export class BookingQuery extends PageQuery {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsOptional()
  @IsEnum(BookingStatus)
  status?: BookingStatus;

  @IsOptional()
  @IsEnum(BookingSource)
  source?: BookingSource;

  @IsOptional()
  @IsEnum(PaymentStatus)
  paymentStatus?: PaymentStatus;

  @IsOptional()
  @IsEnum(PaymentMethod)
  paymentMethod?: PaymentMethod;

  @IsOptional()
  @IsUUID()
  driverId?: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(120)
  q?: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(32)
  phone?: string;

  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(32)
  trackingId?: string;

  @IsOptional()
  @IsEnum(FareZone)
  zone?: FareZone;

  /** ISO instant, or a calendar date which covers that whole UTC day. */
  @IsOptional()
  @IsDateString()
  from?: string;

  /** ISO instant, or a calendar date which covers that whole UTC day. */
  @IsOptional()
  @IsDateString()
  to?: string;

  @IsOptional()
  @IsIn(TABS)
  tab?: BookingTab | 'timeout';
}
