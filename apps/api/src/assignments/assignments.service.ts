import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { AssignVehicleDto } from './dto/assign-vehicle.dto.js';

const assignmentInclude = {
  driver: {
    select: {
      id: true,
      firstName: true,
      lastName: true,
      status: true,
      branchId: true,
    },
  },
  vehicle: {
    select: {
      id: true,
      plateNumber: true,
      unitNumber: true,
      branchId: true,
      active: true,
    },
  },
} satisfies Prisma.DriverVehicleAssignmentInclude;

@Injectable()
export class AssignmentsService {
  constructor(private readonly prisma: PrismaService) {}

  async assign(driverId: string, dto: AssignVehicleDto, user: AuthUser) {
    try {
      return await this.prisma.$transaction((tx) =>
        this.assignInTransaction(tx, driverId, dto, user),
      );
    } catch (error) {
      if (
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        throw new ConflictException(
          'Driver or vehicle already has an open assignment',
        );
      }
      throw error;
    }
  }

  async unassign(driverId: string, user: AuthUser) {
    return this.prisma.$transaction(async (tx) => {
      const driver = await this.requireDriver(tx, driverId, user);
      const open = await tx.driverVehicleAssignment.findFirst({
        where: { driverId: driver.id, endedAt: null },
        include: assignmentInclude,
      });
      if (!open) {
        throw new NotFoundException();
      }
      return tx.driverVehicleAssignment.update({
        where: { id: open.id },
        data: { endedAt: new Date() },
        include: assignmentInclude,
      });
    });
  }

  private async assignInTransaction(
    tx: Prisma.TransactionClient,
    driverId: string,
    dto: AssignVehicleDto,
    user: AuthUser,
  ) {
    const driver = await this.requireDriver(tx, driverId, user);
    if (driver.status !== 'APPROVED') {
      throw new UnprocessableEntityException(
        'Only approved drivers can be assigned',
      );
    }

    const vehicle = await this.requireVehicle(tx, dto.vehicleId, user);
    if (vehicle.branchId !== driver.branchId) {
      throw new BadRequestException(
        'Driver and vehicle must belong to the same branch',
      );
    }
    if (!vehicle.active) {
      throw new BadRequestException('Vehicle is not active');
    }

    const [driverOpen, vehicleOpen] = await Promise.all([
      tx.driverVehicleAssignment.findFirst({
        where: { driverId: driver.id, endedAt: null },
      }),
      tx.driverVehicleAssignment.findFirst({
        where: { vehicleId: vehicle.id, endedAt: null },
      }),
    ]);

    if (driverOpen && driverOpen.vehicleId === vehicle.id) {
      return tx.driverVehicleAssignment.findFirstOrThrow({
        where: { id: driverOpen.id },
        include: assignmentInclude,
      });
    }

    if (vehicleOpen && vehicleOpen.driverId !== driver.id && !dto.reassign) {
      throw new ConflictException(
        'Vehicle is already assigned to another driver',
      );
    }

    const endedAt = new Date();
    if (vehicleOpen && vehicleOpen.driverId !== driver.id) {
      await tx.driverVehicleAssignment.updateMany({
        where: { id: vehicleOpen.id, endedAt: null },
        data: { endedAt },
      });
    }
    if (driverOpen) {
      await tx.driverVehicleAssignment.updateMany({
        where: { id: driverOpen.id, endedAt: null },
        data: { endedAt },
      });
    }

    return tx.driverVehicleAssignment.create({
      data: { driverId: driver.id, vehicleId: vehicle.id },
      include: assignmentInclude,
    });
  }

  private scope(user: AuthUser): { branchId?: string } | null {
    if (user.role !== 'super_admin' && !user.branchId) {
      return null;
    }
    return branchWhere(user);
  }

  private async requireDriver(
    tx: Prisma.TransactionClient,
    id: string,
    user: AuthUser,
  ) {
    const scope = this.scope(user);
    if (!scope) {
      throw new NotFoundException();
    }
    const driver = await tx.driver.findFirst({ where: { id, ...scope } });
    if (!driver) {
      throw new NotFoundException();
    }
    return driver;
  }

  private async requireVehicle(
    tx: Prisma.TransactionClient,
    id: string,
    user: AuthUser,
  ) {
    const scope = this.scope(user);
    if (!scope) {
      throw new NotFoundException();
    }
    const vehicle = await tx.vehicle.findFirst({ where: { id, ...scope } });
    if (!vehicle) {
      throw new NotFoundException();
    }
    return vehicle;
  }
}
