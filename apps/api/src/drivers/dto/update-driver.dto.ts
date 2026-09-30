import { PartialType } from '@nestjs/mapped-types';
import { IsBoolean, IsOptional } from 'class-validator';
import { CreateDriverDto } from './create-driver.dto.js';

export class UpdateDriverDto extends PartialType(CreateDriverDto) {
  @IsOptional()
  @IsBoolean()
  ladyDriverEligible?: boolean;
}
