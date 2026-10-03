import { describe, expect, it, vi } from 'vitest';
import type { AuthUser } from '../common/auth-user.js';
import { PrismaService } from '../prisma/prisma.service.js';
import type {
  PlaceDetails,
  PlaceSuggestion,
  PlacesProvider,
} from './places.provider.js';
import { PlacesService } from './places.service.js';

const SESSION = '3519edfe-0f75-4a30-bfe4-7cbd89340b2c';

function service(
  branch: { centerLat: number | null; centerLng: number | null } | null,
) {
  const autocomplete = vi.fn(async () => [] as PlaceSuggestion[]);
  const details = vi.fn(async (): Promise<PlaceDetails> => ({
    placeId: 'ChIJj61dQgK6j4AR4GeTYWZsKWw',
    address: '910 4 Ave S',
    lat: 1,
    lng: 2,
  }));
  const reverse = vi.fn(async () => ({ address: '910 4 Ave S' }));
  const places: PlacesProvider = { autocomplete, details, reverse };
  const prisma = {
    branch: {
      findUnique: vi.fn(async () => branch),
    },
  } as unknown as PrismaService;
  return {
    autocomplete,
    details,
    svc: new PlacesService(prisma, places),
  };
}

const dispatcher: AuthUser = {
  userId: 'user-1',
  role: 'dispatcher',
  branchId: 'branch-1',
};

describe('PlacesService', () => {
  it('biases autocomplete to the branch centre', async () => {
    const { svc, autocomplete } = service({
      centerLat: 49.6935,
      centerLng: -112.8418,
    });
    await svc.autocomplete(dispatcher, '  city hall  ', SESSION);
    expect(autocomplete).toHaveBeenCalledWith({
      q: 'city hall',
      session: SESSION,
      bias: { lat: 49.6935, lng: -112.8418 },
    });
  });

  it('searches Canada-wide when the user has no branch centre', async () => {
    const passenger: AuthUser = {
      userId: 'user-2',
      role: 'passenger',
      branchId: null,
    };
    const { svc, autocomplete } = service(null);
    await svc.autocomplete(passenger, 'city hall', SESSION);
    expect(autocomplete).toHaveBeenCalledWith({
      q: 'city hall',
      session: SESSION,
      bias: undefined,
    });
  });

  it('skips the bias when the branch centre is not set', async () => {
    const { svc, autocomplete } = service({
      centerLat: null,
      centerLng: null,
    });
    await svc.autocomplete(dispatcher, 'city hall', SESSION);
    expect(autocomplete).toHaveBeenCalledWith({
      q: 'city hall',
      session: SESSION,
      bias: undefined,
    });
  });

  it('rejects a short query and a place id that is not opaque', async () => {
    const { svc, autocomplete, details } = service({
      centerLat: null,
      centerLng: null,
    });
    await expect(
      svc.autocomplete(dispatcher, 'ab', SESSION),
    ).rejects.toMatchObject({
      response: {
        code: 'VALIDATION',
        fields: { q: 'q must be 3 to 100 characters' },
      },
    });
    await expect(svc.details('not a place', SESSION)).rejects.toMatchObject({
      response: { fields: { placeId: 'placeId is invalid' } },
    });
    expect(autocomplete).not.toHaveBeenCalled();
    expect(details).not.toHaveBeenCalled();
  });
});
