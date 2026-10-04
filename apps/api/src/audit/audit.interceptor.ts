import {
  CallHandler,
  ExecutionContext,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { tap } from 'rxjs';
import type { AuthUser } from '../common/auth-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { AUDIT_KEY, type AuditMeta } from './audited.decorator.js';
import { safeJson } from './safe-json.js';

type HttpRequest = {
  user?: AuthUser;
  params?: Record<string, string | undefined>;
};

@Injectable()
export class AuditInterceptor implements NestInterceptor {
  private readonly logger = new Logger(AuditInterceptor.name);

  constructor(
    private readonly reflector: Reflector,
    private readonly prisma: PrismaService,
  ) {}

  intercept(ctx: ExecutionContext, next: CallHandler) {
    const meta = this.reflector.get<AuditMeta | undefined>(
      AUDIT_KEY,
      ctx.getHandler(),
    );
    if (!meta) return next.handle();

    const req = ctx.switchToHttp().getRequest<HttpRequest>();
    const user = req.user;

    return next.handle().pipe(
      tap((result) => {
        void this.write(meta, req, result).catch((err: unknown) => {
          this.logger.warn(
            `AuditLog write failed for ${meta.entity}.${meta.action}: ${
              err instanceof Error ? err.message : String(err)
            }`,
          );
        });
      }),
    );
  }

  private async write(meta: AuditMeta, req: HttpRequest, result: unknown) {
    const user = req.user;
    await this.prisma.auditLog.create({
      data: {
        actorUserId: user?.userId,
        actorType: user ? 'STAFF' : 'SYSTEM',
        entity: meta.entity,
        action: meta.action,
        entityId: entityIdOf(result, req.params?.id),
        after: safeJson(result),
      },
    });
  }
}

function entityIdOf(result: unknown, paramId: string | undefined): string {
  if (result && typeof result === 'object') {
    const row = result as Record<string, unknown>;
    if (typeof row.id === 'string' && row.id.length > 0) return row.id;
    if (typeof row.reportId === 'string' && row.reportId.length > 0) {
      return row.reportId;
    }
    if (typeof row.invoiceId === 'string' && row.invoiceId.length > 0) {
      return row.invoiceId;
    }
  }
  if (typeof paramId === 'string' && paramId.length > 0) return paramId;
  return 'unknown';
}
