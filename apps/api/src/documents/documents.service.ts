import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { DocumentOwner, Prisma } from '@prisma/client';
import type { AuthUser } from '../common/auth-user.js';
import { branchWhere } from '../common/branch-scope.js';
import { normalizePage, paginate } from '../common/pagination.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type { CreateDocumentDto } from './dto/create-document.dto.js';
import type { ExpiringDocumentsQuery } from './dto/expiring-documents-query.dto.js';
import type { ReviewDocumentDto } from './dto/review-document.dto.js';

const APPROVER_ROLES = ['super_admin', 'branch_admin', 'hr_admin'] as const;

const documentInclude = {
  documentType: {
    select: {
      id: true,
      code: true,
      name: true,
      owner: true,
      required: true,
      hasExpiry: true,
    },
  },
  driver: {
    select: { id: true, firstName: true, lastName: true, branchId: true },
  },
  vehicle: {
    select: { id: true, plateNumber: true, unitNumber: true, branchId: true },
  },
} satisfies Prisma.DocumentInclude;

@Injectable()
export class DocumentsService {
  constructor(private readonly prisma: PrismaService) {}

  createForDriver(driverId: string, dto: CreateDocumentDto, user: AuthUser) {
    return this.create(dto, user, { owner: 'DRIVER', driverId });
  }

  createForVehicle(vehicleId: string, dto: CreateDocumentDto, user: AuthUser) {
    return this.create(dto, user, { owner: 'VEHICLE', vehicleId });
  }

  async review(id: string, dto: ReviewDocumentDto, user: AuthUser) {
    this.assertApprover(user);
    const existing = await this.findScoped(id, user);
    return this.prisma.document.update({
      where: { id: existing.id },
      data: {
        status: dto.status,
        reviewedById: user.userId,
        reviewedAt: new Date(),
        rejectionNote: dto.status === 'REJECTED' ? dto.note : null,
      },
      include: documentInclude,
    });
  }

  async expiring(user: AuthUser, query: ExpiringDocumentsQuery) {
    const { page, pageSize, skip, take } = normalizePage(query);
    const scope = this.scope(user);
    if (!scope) {
      return paginate([], 0, { page, pageSize });
    }

    const days = query.days ?? 30;
    const now = new Date();
    const until = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);
    const where: Prisma.DocumentWhereInput = {
      status: { in: ['PENDING', 'APPROVED'] },
      expiresAt: { gt: now, lte: until },
    };
    if (scope.branchId) {
      where.OR = [
        { driver: { branchId: scope.branchId } },
        { vehicle: { branchId: scope.branchId } },
      ];
    }
    const term = query.search?.trim();
    if (term) {
      const search: Prisma.DocumentWhereInput = {
        OR: [
          { documentType: { code: { contains: term, mode: 'insensitive' } } },
          { documentType: { name: { contains: term, mode: 'insensitive' } } },
          { driver: { firstName: { contains: term, mode: 'insensitive' } } },
          { driver: { lastName: { contains: term, mode: 'insensitive' } } },
          { vehicle: { plateNumber: { contains: term, mode: 'insensitive' } } },
          { storageKey: { contains: term, mode: 'insensitive' } },
        ],
      };
      where.AND = [search];
    }

    const [total, data] = await this.prisma.$transaction([
      this.prisma.document.count({ where }),
      this.prisma.document.findMany({
        where,
        skip,
        take,
        orderBy: { expiresAt: 'asc' },
        include: documentInclude,
      }),
    ]);
    return paginate(data, total, { page, pageSize });
  }

  private async create(
    dto: CreateDocumentDto,
    user: AuthUser,
    target: { owner: 'DRIVER'; driverId: string } | { owner: 'VEHICLE'; vehicleId: string },
  ) {
    const storageKey = this.objectKey(dto.storageKey);
    if (target.owner === 'DRIVER') {
      await this.requireDriver(target.driverId, user);
    } else {
      await this.requireVehicle(target.vehicleId, user);
    }
    const documentType = await this.requireType(dto.documentTypeId, target.owner);
    this.assertExpiry(documentType.hasExpiry, dto.expiresAt);

    return this.prisma.document.create({
      data: {
        documentTypeId: documentType.id,
        driverId: target.owner === 'DRIVER' ? target.driverId : null,
        vehicleId: target.owner === 'VEHICLE' ? target.vehicleId : null,
        storageKey,
        expiresAt: dto.expiresAt ?? null,
        status: 'PENDING',
      },
      include: documentInclude,
    });
  }

  private async findScoped(id: string, user: AuthUser) {
    const scope = this.scope(user);
    if (!scope) {
      throw new NotFoundException();
    }
    const where: Prisma.DocumentWhereInput = { id };
    if (scope.branchId) {
      where.OR = [
        { driver: { branchId: scope.branchId } },
        { vehicle: { branchId: scope.branchId } },
      ];
    }
    const document = await this.prisma.document.findFirst({ where });
    if (!document) {
      throw new NotFoundException();
    }
    return document;
  }

  private async requireDriver(id: string, user: AuthUser) {
    const scope = this.scope(user);
    if (!scope) {
      throw new NotFoundException();
    }
    const driver = await this.prisma.driver.findFirst({
      where: { id, ...scope },
    });
    if (!driver) {
      throw new NotFoundException();
    }
    return driver;
  }

  private async requireVehicle(id: string, user: AuthUser) {
    const scope = this.scope(user);
    if (!scope) {
      throw new NotFoundException();
    }
    const vehicle = await this.prisma.vehicle.findFirst({
      where: { id, ...scope },
    });
    if (!vehicle) {
      throw new NotFoundException();
    }
    return vehicle;
  }

  private async requireType(id: string, owner: DocumentOwner) {
    const documentType = await this.prisma.documentType.findUnique({
      where: { id },
    });
    if (!documentType) {
      throw new NotFoundException();
    }
    if (documentType.owner !== owner) {
      throw new BadRequestException(
        owner === 'DRIVER'
          ? 'Document type does not belong to a driver'
          : 'Document type does not belong to a vehicle',
      );
    }
    return documentType;
  }

  private assertExpiry(hasExpiry: boolean, expiresAt?: Date) {
    if (hasExpiry && !expiresAt) {
      throw new BadRequestException('expiresAt is required for this document type');
    }
    if (!hasExpiry && expiresAt) {
      throw new BadRequestException('expiresAt is not used for this document type');
    }
  }

  private objectKey(value: string) {
    if (value.includes('://')) {
      throw new BadRequestException('storageKey must be an object key, not a URL');
    }
    if (value.includes('..') || /\s/.test(value)) {
      throw new BadRequestException('storageKey is invalid');
    }
    return value;
  }

  private assertApprover(user: AuthUser) {
    if (!APPROVER_ROLES.includes(user.role as (typeof APPROVER_ROLES)[number])) {
      throw new ForbiddenException();
    }
  }

  private scope(user: AuthUser): { branchId?: string } | null {
    if (user.role !== 'super_admin' && !user.branchId) {
      return null;
    }
    return branchWhere(user);
  }
}
