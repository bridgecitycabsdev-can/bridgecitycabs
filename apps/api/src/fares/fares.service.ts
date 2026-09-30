import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { AuthUser } from '../common/auth-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { calcFare } from './calc-fare.js';
import { DISTANCE_SERVICE, type DistanceService } from './distance.service.js';
import type { QuoteFareDto } from './dto/quote-fare.dto.js';

@Injectable()
export class FaresService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(DISTANCE_SERVICE) private readonly distance: DistanceService,
  ) {}

  async quote(dto: QuoteFareDto, user: AuthUser) {
    const branch = await this.resolveBranch(user, dto.branchId);
    const vehicleType = await this.prisma.vehicleType.findUnique({
      where: { id: dto.vehicleTypeId },
    });
    if (!vehicleType) throw new NotFoundException();

    // Zone is supplied by the client. Deriving it from a city-boundary
    // polygon is a later PostGIS task.
    const rule = await this.prisma.fareRule.findUnique({
      where: {
        branchId_vehicleTypeId_zone: {
          branchId: branch.id,
          vehicleTypeId: dto.vehicleTypeId,
          zone: dto.zone,
        },
      },
    });
    if (!rule?.active) {
      throw new NotFoundException(
        'No active fare rule for this vehicle type and zone',
      );
    }

    const [pickup, ...rest] = dto.stops;
    const dropoff = rest.pop();
    if (!pickup || !dropoff) {
      throw new BadRequestException('At least two stops are required');
    }
    const { meters, seconds } = await this.distance.estimate(
      pickup,
      dropoff,
      rest,
    );
    const fare = calcFare(rule, meters, seconds, branch.gstRateBps);

    // Not persisted. Booking creation copies these amounts onto the booking,
    // so a later fare-rule edit cannot change that booking's price.
    return {
      distanceMeters: meters,
      durationSeconds: seconds,
      subtotalCents: fare.subtotalCents,
      taxCents: fare.taxCents,
      totalCents: fare.totalCents,
    };
  }

  private async resolveBranch(user: AuthUser, requested?: string) {
    if (user.role === 'super_admin') {
      if (!requested) throw new BadRequestException('branchId is required');
      return this.requireBranch(requested);
    }
    if (!user.branchId) throw new ForbiddenException();
    return this.requireBranch(user.branchId);
  }

  private async requireBranch(id: string) {
    const branch = await this.prisma.branch.findUnique({ where: { id } });
    if (!branch) throw new NotFoundException();
    return branch;
  }
}
