import {
  BookingSource,
  BookingStatus,
  PaymentMethod,
  PaymentStatus,
} from '@prisma/client';
import { Transform } from 'class-transformer';
import {
  IsDateString,
  IsEnum,
  IsIn,
  IsOptional,
  IsUUID,
} from 'class-validator';

function asStringArray(value: unknown): string[] | undefined {
  if (value == null || value === '') return undefined;
  if (Array.isArray(value)) {
    return value.map(String).flatMap((v) => v.split(',')).map((v) => v.trim()).filter(Boolean);
  }
  if (typeof value === 'string') {
    return value.split(',').map((v) => v.trim()).filter(Boolean);
  }
  return undefined;
}

/** Superset of Day 4/8 booking list filters — export-oriented. */
export class ReportFilterDto {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsDateString()
  from!: string;

  @IsDateString()
  to!: string;

  @IsOptional()
  @Transform(({ value }) => asStringArray(value))
  @IsEnum(BookingStatus, { each: true })
  status?: BookingStatus[];

  @IsOptional()
  @Transform(({ value }) => asStringArray(value))
  @IsEnum(BookingSource, { each: true })
  source?: BookingSource[];

  @IsOptional()
  @Transform(({ value }) => asStringArray(value))
  @IsEnum(PaymentMethod, { each: true })
  paymentMethod?: PaymentMethod[];

  @IsOptional()
  @Transform(({ value }) => asStringArray(value))
  @IsEnum(PaymentStatus, { each: true })
  paymentStatus?: PaymentStatus[];

  @IsOptional()
  @IsUUID()
  driverId?: string;

  @IsOptional()
  @IsUUID()
  corporateAccountId?: string;

  @IsOptional()
  @IsUUID()
  vehicleTypeId?: string;

  @IsOptional()
  @IsIn(['csv', 'pdf', 'json'])
  format: 'csv' | 'pdf' | 'json' = 'json';
}
