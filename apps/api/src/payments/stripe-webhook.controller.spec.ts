import { BadRequestException } from '@nestjs/common';
import { describe, expect, it, vi } from 'vitest';
import { StripeWebhookController } from './stripe-webhook.controller.js';

describe('StripeWebhookController', () => {
  it('rejects a non-raw body with 400 and never calls the service', async () => {
    const webhooks = { handle: vi.fn() };
    const controller = new StripeWebhookController(webhooks as never);
    expect(() =>
      controller.handle({ body: { tampered: true } } as never, 'sig'),
    ).toThrow(BadRequestException);
    expect(webhooks.handle).not.toHaveBeenCalled();
  });

  it('forwards a Buffer body to the service', async () => {
    const webhooks = {
      handle: vi.fn(async () => ({ received: true })),
    };
    const controller = new StripeWebhookController(webhooks as never);
    const body = Buffer.from('{"ok":true}');
    await expect(
      controller.handle({ body } as never, 'sig_test'),
    ).resolves.toEqual({ received: true });
    expect(webhooks.handle).toHaveBeenCalledWith(body, 'sig_test');
  });
});
