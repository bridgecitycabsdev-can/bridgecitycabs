import { PartialType } from '@nestjs/mapped-types';
import { CreatePassengerDto } from './create-passenger.dto.js';

export class UpdatePassengerDto extends PartialType(CreatePassengerDto) {}
