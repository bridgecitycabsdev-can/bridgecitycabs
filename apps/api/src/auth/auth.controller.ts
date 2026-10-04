import {
  Body,
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Post,
  Req,
  Res,
  UnauthorizedException,
} from '@nestjs/common';
import { Throttle } from '@nestjs/throttler';
import type { Request, Response } from 'express';
import { AuthService } from './auth.service.js';
import type { AuthUser } from '../common/auth-user.js';
import { CurrentUser } from '../common/current-user.decorator.js';
import { Public } from '../common/public.decorator.js';
import { LoginDto } from './dto/login.dto.js';
import { RequestOtpDto } from './dto/request-otp.dto.js';
import { RefreshTokenDto } from './dto/refresh-token.dto.js';
import { VerifyOtpDto } from './dto/verify-otp.dto.js';
import {
  clearRefreshCookie,
  isWebClient,
  presentSession,
  refreshTokenFrom,
} from './web-refresh-cookie.js';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @Post('login')
  @HttpCode(HttpStatus.OK)
  // Relies on APP_GUARD ThrottlerGuard — do not also @UseGuards(ThrottlerGuard) (double-count).
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  async login(
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
    @Body() body: LoginDto,
  ) {
    return presentSession(req, res, await this.authService.login(body.email, body.password));
  }

  @Public()
  @Post('otp/request')
  @HttpCode(HttpStatus.ACCEPTED)
  requestOtp(@Body() body: RequestOtpDto, @Req() req: Request) {
    return this.authService.requestOtp(body.phone, req.ip || req.socket.remoteAddress || 'unknown');
  }

  @Public()
  @Post('otp/verify')
  @HttpCode(HttpStatus.OK)
  async verifyOtp(
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
    @Body() body: VerifyOtpDto,
  ) {
    return presentSession(req, res, await this.authService.verifyOtp(body.phone, body.code));
  }

  @Public()
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  async refresh(
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
    @Body() body: RefreshTokenDto,
  ) {
    try {
      const tokens = await this.authService.refresh(refreshTokenFrom(req, body));
      return presentSession(req, res, tokens);
    } catch (error) {
      if (isWebClient(req) && error instanceof UnauthorizedException) {
        clearRefreshCookie(res);
      }
      throw error;
    }
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  async logout(
    @CurrentUser() user: AuthUser,
    @Req() req: Request,
    @Res({ passthrough: true }) res: Response,
    @Body() body: RefreshTokenDto,
  ) {
    const result = await this.authService.logout(user.userId, refreshTokenFrom(req, body));
    if (isWebClient(req)) clearRefreshCookie(res);
    return result;
  }

  @Get('me')
  me(@CurrentUser() user: AuthUser) {
    return this.authService.me(user.userId);
  }
}
