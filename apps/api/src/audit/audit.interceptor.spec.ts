import { CallHandler, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { of, lastValueFrom } from 'rxjs';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { AuditInterceptor } from './audit.interceptor.js';
import { AUDIT_KEY } from './audited.decorator.js';

describe('AuditInterceptor', () => {
  const prisma = {
    auditLog: { create: vi.fn(async () => ({})) },
  };
  const reflector = {
    get: vi.fn(),
  };
  let interceptor: AuditInterceptor;

  beforeEach(() => {
    vi.clearAllMocks();
    interceptor = new AuditInterceptor(
      reflector as unknown as Reflector,
      prisma as never,
    );
  });

  it('is a no-op when handler has no @Audited metadata', async () => {
    reflector.get.mockReturnValue(undefined);
    const next: CallHandler = { handle: () => of({ ok: true }) };
    const ctx = {
      getHandler: () => ({}),
      switchToHttp: () => ({ getRequest: () => ({}) }),
    } as unknown as ExecutionContext;

    await lastValueFrom(interceptor.intercept(ctx, next));
    expect(prisma.auditLog.create).not.toHaveBeenCalled();
    expect(reflector.get).toHaveBeenCalledWith(AUDIT_KEY, expect.anything());
  });

  it('writes AuditLog after a successful handler result', async () => {
    reflector.get.mockReturnValue({ entity: 'promo_code', action: 'created' });
    const next: CallHandler = {
      handle: () => of({ id: 'promo-1', code: 'SAVE10' }),
    };
    const ctx = {
      getHandler: () => ({}),
      switchToHttp: () => ({
        getRequest: () => ({
          user: { userId: 'staff-1', role: 'super_admin', branchId: null },
          params: {},
        }),
      }),
    } as unknown as ExecutionContext;

    await lastValueFrom(interceptor.intercept(ctx, next));
    // tap schedules the write asynchronously
    await vi.waitFor(() => expect(prisma.auditLog.create).toHaveBeenCalled());

    expect(prisma.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({
        actorUserId: 'staff-1',
        actorType: 'STAFF',
        entity: 'promo_code',
        action: 'created',
        entityId: 'promo-1',
        after: { id: 'promo-1', code: 'SAVE10' },
      }),
    });
  });

  it('uses reportId when response has no id', async () => {
    reflector.get.mockReturnValue({
      entity: 'generated_report',
      action: 'generated',
    });
    const next: CallHandler = {
      handle: () => of({ async: true, reportId: 'rep-9', rowCount: 12 }),
    };
    const ctx = {
      getHandler: () => ({}),
      switchToHttp: () => ({
        getRequest: () => ({
          user: { userId: 'staff-1', role: 'super_admin', branchId: null },
          params: {},
        }),
      }),
    } as unknown as ExecutionContext;

    await lastValueFrom(interceptor.intercept(ctx, next));
    await vi.waitFor(() => expect(prisma.auditLog.create).toHaveBeenCalled());
    expect(prisma.auditLog.create).toHaveBeenCalledWith({
      data: expect.objectContaining({ entityId: 'rep-9' }),
    });
  });
});
