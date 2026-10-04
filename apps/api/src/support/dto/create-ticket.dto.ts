import { TicketCategory, TicketPriority, TicketSenderType } from '@prisma/client';
import {
  IsEnum,
  IsOptional,
  IsString,
  IsUUID,
  MaxLength,
  MinLength,
} from 'class-validator';

export class CreateTicketDto {
  @IsString()
  @MinLength(1)
  @MaxLength(200)
  subject!: string;

  @IsEnum(TicketCategory)
  category!: TicketCategory;

  @IsString()
  @MinLength(1)
  @MaxLength(5000)
  body!: string;

  @IsOptional()
  @IsUUID()
  bookingId?: string;

  @IsOptional()
  @IsEnum(TicketPriority)
  priority?: TicketPriority;

  /** Staff creating on behalf of a passenger/driver. */
  @IsOptional()
  @IsUUID()
  raisedByUserId?: string;

  @IsOptional()
  @IsEnum(TicketSenderType)
  raisedByType?: TicketSenderType;

  @IsOptional()
  @IsUUID()
  branchId?: string;
}
