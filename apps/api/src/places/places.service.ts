import { HttpStatus, Inject, Injectable } from '@nestjs/common';
import { ApiCode } from '../common/api-code.js';
import { ApiException } from '../common/api-exception.js';
import type { AuthUser } from '../common/auth-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import { isPlaceId, SESSION_TOKEN_PATTERN } from './place-id.js';
import {
  PLACES_PROVIDER,
  type PlaceBias,
  type PlacesProvider,
} from './places.provider.js';

@Injectable()
export class PlacesService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(PLACES_PROVIDER) private readonly places: PlacesProvider,
  ) {}

  async autocomplete(user: AuthUser, q: string, session: string) {
    const query = q.trim();
    if (query.length < 3 || query.length > 100) {
      throw new ApiException(
        HttpStatus.BAD_REQUEST,
        ApiCode.VALIDATION,
        'Validation failed',
        {
          q: 'q must be 3 to 100 characters',
        },
      );
    }
    assertSession(session);
    return this.places.autocomplete({
      q: query,
      session,
      bias: await this.biasFor(user),
    });
  }

  async details(placeId: string, session: string) {
    if (!isPlaceId(placeId)) {
      throw new ApiException(
        HttpStatus.BAD_REQUEST,
        ApiCode.VALIDATION,
        'Validation failed',
        {
          placeId: 'placeId is invalid',
        },
      );
    }
    assertSession(session);
    return this.places.details({ placeId, session });
  }

  reverse(lat: number, lng: number) {
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
      throw new ApiException(
        HttpStatus.BAD_REQUEST,
        ApiCode.VALIDATION,
        'Validation failed',
        {
          lat: 'lat and lng must be coordinates',
        },
      );
    }
    return this.places.reverse({ lat, lng });
  }

  private async biasFor(user: AuthUser): Promise<PlaceBias | undefined> {
    if (!user.branchId) return undefined;
    const branch = await this.prisma.branch.findUnique({
      where: { id: user.branchId },
      select: { centerLat: true, centerLng: true },
    });
    if (branch?.centerLat == null || branch.centerLng == null) return undefined;
    return { lat: branch.centerLat, lng: branch.centerLng };
  }
}

function assertSession(session: string) {
  if (!SESSION_TOKEN_PATTERN.test(session)) {
    throw new ApiException(
      HttpStatus.BAD_REQUEST,
      ApiCode.VALIDATION,
      'Validation failed',
      {
        session: 'session must be a URL-safe token of at most 36 characters',
      },
    );
  }
}
