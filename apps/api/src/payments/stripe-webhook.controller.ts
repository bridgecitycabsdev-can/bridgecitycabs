import {
  BadRequestException,
  Controller,
  Headers,
  HttpCode,
  HttpStatus,
  Post,
  Req,
} from '@nestjs/common';
import { SkipThrottle } from '@nestjs/throttler';
import type { Request } from 'express';
import { Public } from '../common/public.decorator.js';
import { StripeWebhookService } from './stripe-webhook.service.js';

@Controller('webhooks')
export class StripeWebhookController {
  constructor(private readonly webhooks: StripeWebhookService) {}

  @Post('stripe')
  @Public()
  @SkipThrottle()
  @HttpCode(HttpStatus.OK)
  handle(
    @Req() req: Request,
    @Headers('stripe-signature') signature: string | undefined,
  ) {
    if (!Buffer.isBuffer(req.body)) {
      throw new BadRequestException('Invalid signature');
    }
    return this.webhooks.handle(req.body, signature);
  }
}
