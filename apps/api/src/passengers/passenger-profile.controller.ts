import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Patch,
  Post,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Roles } from '../common/roles.decorator.js';
import { DeletePassengerAccountDto } from './dto/delete-passenger-account.dto.js';
import { UpdatePassengerProfileDto } from './dto/update-passenger-profile.dto.js';
import { PassengerProfileService } from './passenger-profile.service.js';

@Controller('passenger/profile')
@Roles('passenger')
export class PassengerProfileController {
  constructor(private readonly profile: PassengerProfileService) {}

  @Get()
  get(@CurrentUser() user: AuthUser) {
    return this.profile.get(user);
  }

  @Patch()
  update(
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdatePassengerProfileDto,
  ) {
    return this.profile.update(user, dto);
  }

  @Post('delete/otp')
  @HttpCode(HttpStatus.ACCEPTED)
  requestDeletionCode(@CurrentUser() user: AuthUser) {
    return this.profile.requestDeletionCode(user);
  }

  @Post('delete')
  @HttpCode(HttpStatus.OK)
  delete(
    @CurrentUser() user: AuthUser,
    @Body() dto: DeletePassengerAccountDto,
  ) {
    return this.profile.delete(user, dto);
  }
}
