import { FareZone } from '@prisma/client';
import { Transform } from 'class-transformer';
import { IsBoolean, IsEnum, IsOptional, IsUUID } from 'class-validator';
import { PageQuery } from '../../common/pagination.js';

function queryBoolean(value: unknown) {
  if (value === undefined || value === null || value === '') {
    return undefined;
  }
  if (value === true || value === 'true') {
    return true;
  }
  if (value === false || value === 'false') {
    return false;
  }
  return value;
}

export class FareRuleQuery extends PageQuery {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsOptional()
  @IsUUID()
  vehicleTypeId?: string;

  @IsOptional()
  @IsEnum(FareZone)
  zone?: FareZone;

  @IsOptional()
  @Transform(({ value }) => queryBoolean(value))
  @IsBoolean()
  active?: boolean;
}
