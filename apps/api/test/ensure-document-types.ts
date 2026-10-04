import { PrismaClient } from '@prisma/client';

const REQUIRED = [
  {
    code: 'AB_DRIVERS_LICENCE',
    name: "Alberta driver's licence",
    owner: 'DRIVER' as const,
  },
  {
    code: 'POLICE_CHECK_VSC',
    name: 'Police information check',
    owner: 'DRIVER' as const,
  },
  {
    code: 'WORK_ELIGIBILITY',
    name: 'Proof of eligibility to work',
    owner: 'DRIVER' as const,
  },
  {
    code: 'VEHICLE_REGISTRATION',
    name: 'Vehicle registration',
    owner: 'VEHICLE' as const,
  },
  {
    code: 'VEHICLE_INSURANCE',
    name: 'Vehicle insurance',
    owner: 'VEHICLE' as const,
  },
  {
    code: 'TAXI_INSPECTION',
    name: 'Taxi vehicle inspection',
    owner: 'VEHICLE' as const,
  },
] as const;

/** Idempotent seed of Day 3 required document types — e2e must not rely on suite order. */
export async function ensureRequiredDocumentTypes(prisma: PrismaClient) {
  for (const row of REQUIRED) {
    await prisma.documentType.upsert({
      where: { code: row.code },
      update: {
        name: row.name,
        owner: row.owner,
        required: true,
        hasExpiry: true,
      },
      create: {
        code: row.code,
        name: row.name,
        owner: row.owner,
        required: true,
        hasExpiry: true,
      },
    });
  }
}
