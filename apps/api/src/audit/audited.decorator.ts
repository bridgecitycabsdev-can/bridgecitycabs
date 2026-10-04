import { SetMetadata } from '@nestjs/common';

export const AUDIT_KEY = 'audit';

export type AuditMeta = {
  entity: string;
  action: string;
};

export const Audited = (entity: string, action: string) =>
  SetMetadata(AUDIT_KEY, { entity, action } satisfies AuditMeta);
