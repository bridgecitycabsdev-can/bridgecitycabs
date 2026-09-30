import { UnprocessableEntityException } from '@nestjs/common';
import { Prisma, type PrismaClient } from '@prisma/client';

type Db = Prisma.TransactionClient | PrismaClient;

export function codesMissingFrom(
  required: { id: string; code: string }[],
  approvedTypeIds: ReadonlySet<string>,
) {
  return required
    .filter((documentType) => !approvedTypeIds.has(documentType.id))
    .map((documentType) => documentType.code)
    .sort();
}

export function assertDocumentsPresent(missing: string[]) {
  if (missing.length) {
    throw new UnprocessableEntityException({
      message: 'Missing documents',
      missing,
    });
  }
}

/** Approved, unexpired required documents. Vehicle codes are included when a vehicle is given. */
export async function missingRequiredDocumentCodes(
  db: Db,
  input: { driverId: string; vehicleId?: string | null },
) {
  const now = new Date();
  const unexpired = [{ expiresAt: null }, { expiresAt: { gt: now } }];
  const [driverTypes, vehicleTypes, driverDocs, vehicleDocs] = await Promise.all([
    db.documentType.findMany({
      where: { owner: 'DRIVER', required: true },
      select: { id: true, code: true },
    }),
    input.vehicleId
      ? db.documentType.findMany({
          where: { owner: 'VEHICLE', required: true },
          select: { id: true, code: true },
        })
      : Promise.resolve([]),
    db.document.findMany({
      where: {
        driverId: input.driverId,
        status: 'APPROVED',
        OR: unexpired,
      },
      select: { documentTypeId: true },
    }),
    input.vehicleId
      ? db.document.findMany({
          where: {
            vehicleId: input.vehicleId,
            status: 'APPROVED',
            OR: unexpired,
          },
          select: { documentTypeId: true },
        })
      : Promise.resolve([]),
  ]);

  return [
    ...codesMissingFrom(
      driverTypes,
      new Set(driverDocs.map((document) => document.documentTypeId)),
    ),
    ...codesMissingFrom(
      vehicleTypes,
      new Set(vehicleDocs.map((document) => document.documentTypeId)),
    ),
  ].sort();
}
