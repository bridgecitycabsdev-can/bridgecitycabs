import {
  BadRequestException,
  ForbiddenException,
  Inject,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import type { FareZone, PromoCode } from '@prisma/client';
import { ApiCode } from '../common/api-code.js';
import type { AuthUser } from '../common/auth-user.js';
import { applyPromo } from '../promos/apply-promo.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { calcFare } from './calc-fare.js';
import {
  DISTANCE_SERVICE,
  type DistanceService,
  type DistanceSource,
} from './distance.service.js';
import type { QuoteBatchDto } from './dto/quote-batch.dto.js';
import type { QuoteFareDto } from './dto/quote-fare.dto.js';
import { GoogleRoutesDistanceService } from './google-routes.distance.js';
import {
  signQuote,
  stopsHash,
  verifyQuote,
  type QuotePayload,
  type QuoteZone,
} from './quote-token.js';
import { deriveZone } from './town-zone.js';

const DEFAULT_QUOTE_TTL_SECONDS = 600;

export type FareQuoteOption = {
  vehicleTypeId: string;
  name: string;
  subtotalCents: number;
  taxCents: number;
  totalCents: number;
  discountCents: number;
  promoCodeId: string | null;
  etaMinutes: null;
  quoteToken: string;
  expiresAt: string;
};

export type FareQuoteBatch = {
  distanceM: number;
  durationS: number;
  source: DistanceSource;
  zone: QuoteZone;
  options: FareQuoteOption[];
};

@Injectable()
export class FaresService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(DISTANCE_SERVICE) private readonly distance: DistanceService,
    private readonly routes: GoogleRoutesDistanceService,
    private readonly config: ConfigService,
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

  /**
   * One routed measurement, then a signed price for every active fare rule.
   * Staff may pass zone to override the radius. Passengers cannot.
   */
  async quotes(dto: QuoteBatchDto, user: AuthUser): Promise<FareQuoteBatch> {
    const branch = await this.resolveBranch(user, dto.branchId);
    const centre =
      branch.centerLat == null || branch.centerLng == null
        ? null
        : { lat: branch.centerLat, lng: branch.centerLng };
    const derived = deriveZone(centre, branch.townRadiusKm, dto.stops);
    const zone = user.role === 'passenger' ? derived : (dto.zone ?? derived);
    if (!zone) throw new BadRequestException('Branch centre is not set');

    const [pickup, ...rest] = dto.stops;
    const dropoff = rest.at(-1);
    const via = rest.slice(0, -1);
    if (!pickup || !dropoff) {
      throw new BadRequestException('At least two stops are required');
    }
    const trip = await this.routes.estimate(pickup, dropoff, via);
    const source: DistanceSource = trip.source ?? 'ESTIMATE';
    const hash = stopsHash(dto.stops);
    const exp = Math.floor(Date.now() / 1000) + this.ttlSeconds();
    const secret = this.secret();

    const rules = await this.prisma.fareRule.findMany({
      where: {
        branchId: branch.id,
        zone,
        active: true,
        vehicleType: { active: true },
      },
      include: { vehicleType: true },
      orderBy: { vehicleType: { name: 'asc' } },
    });

    // Promo codes are a passenger-app feature; staff /fares/quotes ignores them.
    const promo =
      user.role === 'passenger' && dto.promoCode?.trim()
        ? await this.requireEligiblePromo(
            dto.promoCode.trim().toUpperCase(),
            branch.id,
            // Eligibility vs minSubtotal is checked per option below.
            null,
          )
        : null;

    const options = rules.map((rule) => {
      const fare = calcFare(rule, trip.meters, trip.seconds, branch.gstRateBps);
      let subtotalCents = fare.subtotalCents;
      let taxCents = fare.taxCents;
      let totalCents = fare.totalCents;
      let discountCents = 0;
      let promoCodeId: string | null = null;

      if (promo && fare.subtotalCents >= promo.minSubtotalCents) {
        const applied = applyPromo(fare.subtotalCents, promo);
        discountCents = applied.discountCents;
        subtotalCents = applied.netSubtotalCents;
        taxCents = Math.round((subtotalCents * branch.gstRateBps) / 10000);
        totalCents = subtotalCents + taxCents;
        promoCodeId = promo.id;
      }

      const payload: QuotePayload = {
        branchId: branch.id,
        vehicleTypeId: rule.vehicleTypeId,
        zone,
        stopsHash: hash,
        distanceM: trip.meters,
        durationS: trip.seconds,
        subtotalCents,
        taxCents,
        totalCents,
        source,
        exp,
        discountCents,
        promoCodeId,
      };
      return {
        vehicleTypeId: rule.vehicleTypeId,
        name: rule.vehicleType.name,
        subtotalCents,
        taxCents,
        totalCents,
        discountCents,
        promoCodeId,
        etaMinutes: null,
        quoteToken: signQuote(payload, secret),
        expiresAt: new Date(exp * 1000).toISOString(),
      };
    });

    return {
      distanceM: trip.meters,
      durationS: trip.seconds,
      source,
      zone,
      options,
    };
  }

  /**
   * Validates a promo for quote-time eligibility (active, branch, window, total
   * cap). Pass `minSubtotalCents` to also enforce the minimum fare floor, or
   * null to defer that check to the caller per option.
   */
  async requireEligiblePromo(
    code: string,
    branchId: string,
    minSubtotalCents: number | null,
    now = new Date(),
  ): Promise<PromoCode> {
    const promo = await this.prisma.promoCode.findUnique({
      where: { code },
    });
    const eligible =
      promo &&
      promo.active &&
      (!promo.branchId || promo.branchId === branchId) &&
      (!promo.startAt || promo.startAt <= now) &&
      (!promo.endAt || promo.endAt >= now) &&
      (minSubtotalCents == null || minSubtotalCents >= promo.minSubtotalCents) &&
      (promo.usageLimitTotal == null ||
        promo.redeemedCount < promo.usageLimitTotal);
    if (!eligible || !promo) {
      throw new UnprocessableEntityException({
        code: ApiCode.PROMO_NOT_ELIGIBLE,
      });
    }
    return promo;
  }

  acceptQuote(
    token: string,
    expected: {
      branchId: string;
      vehicleTypeId: string;
      zone: FareZone;
      stops: { lat: number; lng: number }[];
    },
  ): QuotePayload | null {
    const secret = this.config.get<string>('QUOTE_SECRET')?.trim();
    if (!secret) return null;
    return verifyQuote(token, secret, {
      branchId: expected.branchId,
      vehicleTypeId: expected.vehicleTypeId,
      zone: expected.zone,
      stopsHash: stopsHash(expected.stops),
    });
  }

  private async resolveBranch(user: AuthUser, requested?: string) {
    if (user.role === 'passenger') {
      if (user.branchId) return this.requireBranch(user.branchId);
      if (!requested) throw new BadRequestException('branchId is required');
      return this.requireBranch(requested);
    }
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

  private secret() {
    const secret = this.config.get<string>('QUOTE_SECRET')?.trim();
    if (!secret)
      throw new InternalServerErrorException('Quotes are not configured');
    return secret;
  }

  private ttlSeconds() {
    const raw = this.config.get<string | number>('QUOTE_TTL_SECONDS');
    if (raw === undefined || raw === '') return DEFAULT_QUOTE_TTL_SECONDS;
    const value = typeof raw === 'number' ? raw : Number(raw);
    if (!Number.isFinite(value) || value <= 0) return DEFAULT_QUOTE_TTL_SECONDS;
    return Math.floor(value);
  }
}
