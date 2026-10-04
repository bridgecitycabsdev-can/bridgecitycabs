import { Type } from 'class-transformer';
import { IsInt, Min } from 'class-validator';

export class PromoPreviewQuery {
  @Type(() => Number)
  @IsInt()
  @Min(0)
  subtotalCents!: number;
}
