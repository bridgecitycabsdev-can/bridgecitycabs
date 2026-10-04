import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service.js';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async updateRole(userId: string, roleId: string) {
    const [user, role] = await Promise.all([
      this.prisma.user.findUnique({
        where: { id: userId },
        select: {
          id: true,
          roleId: true,
          email: true,
          phone: true,
          displayName: true,
          branchId: true,
          isActive: true,
          role: { select: { id: true, name: true } },
        },
      }),
      this.prisma.role.findUnique({
        where: { id: roleId },
        select: { id: true, name: true },
      }),
    ]);
    if (!user) throw new NotFoundException();
    if (!role) throw new BadRequestException('Unknown roleId');

    const updated = await this.prisma.user.update({
      where: { id: user.id },
      data: { roleId: role.id },
      select: {
        id: true,
        roleId: true,
        email: true,
        phone: true,
        displayName: true,
        branchId: true,
        isActive: true,
        role: { select: { id: true, name: true } },
      },
    });

    return {
      id: updated.id,
      roleId: updated.roleId,
      role: updated.role,
      email: updated.email,
      phone: updated.phone,
      displayName: updated.displayName,
      branchId: updated.branchId,
      isActive: updated.isActive,
      previousRoleId: user.roleId,
      previousRole: user.role,
    };
  }
}
