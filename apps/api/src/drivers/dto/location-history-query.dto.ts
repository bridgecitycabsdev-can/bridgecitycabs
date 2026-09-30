import { IsISO8601, IsOptional } from 'class-validator';
import { PageQuery } from '../../common/pagination.js';

export class LocationHistoryQuery extends PageQuery {
  @IsOptional()
  @IsISO8601()
  from?: string;

  @IsOptional()
  @IsISO8601()
  to?: string;
}
