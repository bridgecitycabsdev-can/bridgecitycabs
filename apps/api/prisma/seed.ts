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
] as const;

const ROLE_PERMISSIONS: Record<string, readonly string[]> = {
  super_admin: PERMISSIONS,
  branch_admin: ['branches.read', 'users.read'],
};

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
  await prisma.user.upsert({
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
