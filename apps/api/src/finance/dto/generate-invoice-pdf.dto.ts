import { Transform } from 'class-transformer';
import { IsBoolean, IsOptional } from 'class-validator';

function queryBoolean(value: unknown) {
  if (value === true || value === 'true' || value === '1') return true;
  if (value === false || value === 'false' || value === '0') return false;
  return value;
}

export class GenerateInvoicePdfDto {
  /**
   * Required when Invoice.status is past DRAFT — regenerating overwrites the
   * PDF the client may already have.
   */
  @IsOptional()
  @Transform(({ value }) => queryBoolean(value))
  @IsBoolean()
  confirm?: boolean;
}
