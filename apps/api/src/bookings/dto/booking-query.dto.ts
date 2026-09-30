import {
  BookingSource,
  BookingStatus,
  PaymentMethod,
  PaymentStatus,
} from '@prisma/client';
import { IsDateString, IsEnum, IsIn, IsOptional, IsUUID } from 'class-validator';
import { PageQuery } from '../../common/pagination.js';
import { BOOKING_TABS, type BookingTab } from '../booking-tabs.js';

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
  @IsDateString()
  from?: string;

  @IsOptional()
  @IsDateString()
  to?: string;

  @IsOptional()
  @IsIn(Object.keys(BOOKING_TABS))
  tab?: BookingTab;
}
