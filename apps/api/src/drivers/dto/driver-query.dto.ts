import { DriverStatus } from '@prisma/client';
import { IsEnum, IsOptional, IsUUID } from 'class-validator';
import { PageQuery } from '../../common/pagination.js';

export class DriverQuery extends PageQuery {
  @IsOptional()
  @IsUUID()
  branchId?: string;

  @IsOptional()
  @IsEnum(DriverStatus)
  status?: DriverStatus;
}
