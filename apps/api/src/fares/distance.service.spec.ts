import { describe, expect, it } from 'vitest';
import { HaversineDistanceService } from './distance.service.js';

describe('HaversineDistanceService', () => {
  const distance = new HaversineDistanceService();
  const origin = { lat: 0, lng: 0 };
  const oneKmNorth = {
    lat: (1000 / 6_371_000) * (180 / Math.PI),
    lng: 0,
  };

  it('returns zero for a point that does not move', async () => {
    await expect(distance.estimate(origin, origin)).resolves.toEqual({
      meters: 0,
      seconds: 0,
    });
  });

  it('inflates the straight line by the road factor and estimates time at 40 km/h', async () => {
    await expect(distance.estimate(origin, oneKmNorth)).resolves.toEqual({
      meters: 1300,
      seconds: 117,
    });
  });

  it('sums each leg, including via points, before applying the road factor', async () => {
    await expect(
      distance.estimate(origin, origin, [oneKmNorth]),
    ).resolves.toEqual({
      meters: 2600,
      seconds: 234,
    });
  });
});
