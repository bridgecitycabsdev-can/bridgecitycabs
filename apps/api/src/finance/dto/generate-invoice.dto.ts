import { Type } from 'class-transformer';
import {
  IsDate,
  IsOptional,
  IsUUID,
  ValidateIf,
} from 'class-validator';

export class GenerateInvoiceDto {
  @ValidateIf((o: GenerateInvoiceDto) => !o.groupId)
  @IsUUID()
  corporateAccountId?: string;

  @ValidateIf((o: GenerateInvoiceDto) => !o.corporateAccountId)
  @IsUUID()
  groupId?: string;

  @Type(() => Date)
  @IsDate()
  periodStart!: Date;

  @Type(() => Date)
  @IsDate()
  periodEnd!: Date;
}
