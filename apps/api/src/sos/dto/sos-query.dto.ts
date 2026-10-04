import { SosStatus } from '@prisma/client';
import { IsEnum, IsOptional, IsUUID } from 'class-validator';
import { PageQuery } from '../../common/pagination.js';

export class SosQuery extends PageQuery {
  @IsOptional()
  @IsEnum(SosStatus)
  status?: SosStatus;

  @IsOptional()
  @IsUUID()
  branchId?: string;
}
