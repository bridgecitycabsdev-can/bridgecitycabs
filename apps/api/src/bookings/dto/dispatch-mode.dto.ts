import { AssignMode } from '@prisma/client';
import { IsEnum } from 'class-validator';

export class DispatchModeDto {
  @IsEnum(AssignMode)
  mode!: AssignMode;
}
