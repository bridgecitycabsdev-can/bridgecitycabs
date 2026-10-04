import { IsOptional, IsUUID, Matches } from 'class-validator';

const YMD = /^\d{4}-\d{2}-\d{2}$/;

export class DashboardBranchQuery {
  @IsOptional()
  @IsUUID()
  branchId?: string;
}

export class DashboardDateQuery extends DashboardBranchQuery {
  /** Branch-local calendar date `YYYY-MM-DD`. Defaults to today in the branch TZ. */
  @IsOptional()
  @Matches(YMD)
  date?: string;
}

export class DashboardChartQuery extends DashboardBranchQuery {
  @Matches(YMD)
  from!: string;

  @Matches(YMD)
  to!: string;
}
