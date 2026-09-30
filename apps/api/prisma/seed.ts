import { PrismaClient } from '@prisma/client';
import argon2 from 'argon2';

const prisma = new PrismaClient();

const ROLES = [
  'super_admin',
  'branch_admin',
  'dispatcher',
  'customer_care',
  'hr_admin',
  'accounts_admin',
  'driver',
  'passenger',
] as const;

const PERMISSIONS = [
  'branches.read',
  'branches.write',
  'users.read',
  'users.write',
  'drivers.read',
  'drivers.write',
  'drivers.approve',
  'vehicles.read',
  'vehicles.write',
  'passengers.read',
  'passengers.write',
] as const;

const ROLE_PERMISSIONS: Record<string, readonly string[]> = {
  super_admin: PERMISSIONS,
  branch_admin: ['branches.read', 'users.read'],
};

const VEHICLE_TYPES = ['Sedan', 'SUV', 'Minivan', 'Luxury'] as const;

const MAKES = [
  {
    name: 'Toyota',
    models: [
      { name: 'Camry', type: 'Sedan', bodyType: 'sedan' },
      { name: 'Corolla', type: 'Sedan', bodyType: 'sedan' },
      { name: 'Sienna', type: 'Minivan', bodyType: 'minivan' },
    ],
  },
  {
    name: 'Honda',
    models: [
      { name: 'Accord', type: 'Sedan', bodyType: 'sedan' },
      { name: 'Odyssey', type: 'Minivan', bodyType: 'minivan' },
    ],
  },
] as const;

const DOCUMENT_TYPES = [
  {
    code: 'AB_DRIVERS_LICENCE',
    name: "Alberta driver's licence (Class 1, 2 or 4)",
    owner: 'DRIVER',
    required: true,
    hasExpiry: true,
  },
  {
    code: 'POLICE_CHECK_VSC',
    name: 'Police information check with vulnerable sector check',
    owner: 'DRIVER',
    required: true,
    hasExpiry: true,
  },
  {
    code: 'WORK_ELIGIBILITY',
    name: 'Proof of eligibility to work in Canada',
    owner: 'DRIVER',
    required: true,
    hasExpiry: true,
  },
  {
    code: 'VEHICLE_REGISTRATION',
    name: 'Vehicle registration',
    owner: 'VEHICLE',
    required: true,
    hasExpiry: true,
  },
  {
    code: 'VEHICLE_INSURANCE',
    name: 'Vehicle insurance',
    owner: 'VEHICLE',
    required: true,
    hasExpiry: true,
  },
  {
    code: 'TAXI_INSPECTION',
    name: 'Taxi vehicle inspection',
    owner: 'VEHICLE',
    required: true,
    hasExpiry: true,
  },
] as const;

async function main() {
  const email = process.env.SEED_ADMIN_EMAIL;
  const password = process.env.SEED_ADMIN_PASSWORD;
  if (!email || !password) {
    throw new Error('SEED_ADMIN_EMAIL and SEED_ADMIN_PASSWORD must be set');
  }

  const roles = new Map<string, string>();
  for (const name of ROLES) {
    const role = await prisma.role.upsert({
      where: { name },
      update: {},
      create: { name },
    });
    roles.set(name, role.id);
  }

  const permissions = new Map<string, string>();
  for (const code of PERMISSIONS) {
    const permission = await prisma.permission.upsert({
      where: { code },
      update: {},
      create: { code },
    });
    permissions.set(code, permission.id);
  }

  for (const [roleName, codes] of Object.entries(ROLE_PERMISSIONS)) {
    const roleId = roles.get(roleName);
    if (!roleId) {
      throw new Error(`Missing role ${roleName}`);
    }
    for (const code of codes) {
      const permissionId = permissions.get(code);
      if (!permissionId) {
        throw new Error(`Missing permission ${code}`);
      }
      await prisma.rolePermission.upsert({
        where: { roleId_permissionId: { roleId, permissionId } },
        update: {},
        create: { roleId, permissionId },
      });
    }
  }

  const existingBranch = await prisma.branch.findFirst({
    where: { name: 'Lethbridge' },
  });
  const branch = existingBranch
    ? await prisma.branch.update({
        where: { id: existingBranch.id },
        data: { city: 'Lethbridge', active: true },
      })
    : await prisma.branch.create({
        data: { name: 'Lethbridge', city: 'Lethbridge', active: true },
      });

  const superAdminRoleId = roles.get('super_admin');
  if (!superAdminRoleId) {
    throw new Error('Missing role super_admin');
  }

  const passwordHash = await argon2.hash(password);
  const admin = await prisma.user.upsert({
    where: { email },
    update: {
      passwordHash,
      roleId: superAdminRoleId,
      branchId: branch.id,
      isActive: true,
    },
    create: {
      email,
      passwordHash,
      roleId: superAdminRoleId,
      branchId: branch.id,
      isActive: true,
    },
  });

  const vehicleTypes = new Map<string, string>();
  for (const name of VEHICLE_TYPES) {
    const vehicleType = await prisma.vehicleType.upsert({
      where: { name },
      update: { active: true },
      create: { name, active: true },
    });
    vehicleTypes.set(name, vehicleType.id);
  }

  const models = new Map<string, { id: string; vehicleTypeId: string }>();
  for (const makeDef of MAKES) {
    const make = await prisma.vehicleMake.upsert({
      where: { name: makeDef.name },
      update: {},
      create: { name: makeDef.name },
    });
    for (const modelDef of makeDef.models) {
      const vehicleTypeId = vehicleTypes.get(modelDef.type);
      if (!vehicleTypeId) {
        throw new Error(`Missing vehicle type ${modelDef.type}`);
      }
      const model = await prisma.vehicleModel.upsert({
        where: { makeId_name: { makeId: make.id, name: modelDef.name } },
        update: { vehicleTypeId, bodyType: modelDef.bodyType },
        create: {
          makeId: make.id,
          name: modelDef.name,
          vehicleTypeId,
          bodyType: modelDef.bodyType,
        },
      });
      models.set(`${makeDef.name} ${modelDef.name}`, {
        id: model.id,
        vehicleTypeId,
      });
    }
  }

  for (const documentType of DOCUMENT_TYPES) {
    await prisma.documentType.upsert({
      where: { code: documentType.code },
      update: {
        name: documentType.name,
        owner: documentType.owner,
        required: documentType.required,
        hasExpiry: documentType.hasExpiry,
      },
      create: documentType,
    });
  }

  if (process.env.NODE_ENV !== 'production') {
    const driverRoleId = roles.get('driver');
    const passengerRoleId = roles.get('passenger');
    if (!driverRoleId || !passengerRoleId) {
      throw new Error('Missing driver or passenger role');
    }
    await seedDemo(branch.id, admin.id, driverRoleId, passengerRoleId, models);
  }
}

async function seedDemo(
  branchId: string,
  approvedById: string,
  driverRoleId: string,
  passengerRoleId: string,
  models: Map<string, { id: string; vehicleTypeId: string }>,
) {
  const camry = models.get('Toyota Camry');
  const sienna = models.get('Toyota Sienna');
  if (!camry || !sienna) {
    throw new Error('Missing demo vehicle models');
  }

  await upsertVehicle(branchId, {
    plateNumber: 'LTH111',
    unitNumber: '111',
    year: 2022,
    color: 'Silver',
    seats: 4,
    modelId: camry.id,
    vehicleTypeId: camry.vehicleTypeId,
  });
  await upsertVehicle(branchId, {
    plateNumber: 'LTH123',
    unitNumber: '123',
    year: 2021,
    color: 'Black',
    seats: 7,
    modelId: sienna.id,
    vehicleTypeId: sienna.vehicleTypeId,
  });

  await upsertDriver(branchId, driverRoleId, approvedById, {
    email: 'seed.driver.priya@bridgecabs.local',
    phone: '+14035551001',
    firstName: 'Priya',
    lastName: 'Shah',
  });
  await upsertDriver(branchId, driverRoleId, approvedById, {
    email: 'seed.driver.noah@bridgecabs.local',
    phone: '+14035551002',
    firstName: 'Noah',
    lastName: 'Tremblay',
  });

  await upsertPassenger(passengerRoleId, {
    email: 'seed.passenger.amira@bridgecabs.local',
    phone: '+14035551003',
    firstName: 'Amira',
    lastName: 'Haddad',
  });
}

async function upsertVehicle(
  branchId: string,
  vehicle: {
    plateNumber: string;
    unitNumber: string;
    year: number;
    color: string;
    seats: number;
    modelId: string;
    vehicleTypeId: string;
  },
) {
  await prisma.vehicle.upsert({
    where: {
      branchId_plateNumber: {
        branchId,
        plateNumber: vehicle.plateNumber,
      },
    },
    update: {
      unitNumber: vehicle.unitNumber,
      year: vehicle.year,
      color: vehicle.color,
      seats: vehicle.seats,
      modelId: vehicle.modelId,
      vehicleTypeId: vehicle.vehicleTypeId,
      active: true,
    },
    create: {
      branchId,
      ...vehicle,
      active: true,
    },
  });
}

async function upsertDriver(
  branchId: string,
  roleId: string,
  approvedById: string,
  person: {
    email: string;
    phone: string;
    firstName: string;
    lastName: string;
  },
) {
  const account = await prisma.user.upsert({
    where: { email: person.email },
    update: {
      phone: person.phone,
      roleId,
      branchId,
      isActive: true,
      passwordHash: null,
    },
    create: {
      email: person.email,
      phone: person.phone,
      roleId,
      branchId,
      isActive: true,
    },
  });
  await prisma.driver.upsert({
    where: { userId: account.id },
    update: {
      branchId,
      firstName: person.firstName,
      lastName: person.lastName,
      phone: person.phone,
      status: 'APPROVED',
      approvedAt: new Date(),
      approvedById,
      suspensionReason: null,
    },
    create: {
      userId: account.id,
      branchId,
      firstName: person.firstName,
      lastName: person.lastName,
      phone: person.phone,
      status: 'APPROVED',
      approvedAt: new Date(),
      approvedById,
    },
  });
}

async function upsertPassenger(
  roleId: string,
  person: {
    email: string;
    phone: string;
    firstName: string;
    lastName: string;
  },
) {
  const account = await prisma.user.upsert({
    where: { email: person.email },
    update: {
      phone: person.phone,
      roleId,
      branchId: null,
      isActive: true,
      passwordHash: null,
    },
    create: {
      email: person.email,
      phone: person.phone,
      roleId,
      isActive: true,
    },
  });
  await prisma.passenger.upsert({
    where: { userId: account.id },
    update: {
      firstName: person.firstName,
      lastName: person.lastName,
      phone: person.phone,
      email: person.email,
      blocked: false,
      blockReason: null,
      blockedAt: null,
      unblockReason: null,
    },
    create: {
      userId: account.id,
      firstName: person.firstName,
      lastName: person.lastName,
      phone: person.phone,
      email: person.email,
    },
  });
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error: unknown) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
