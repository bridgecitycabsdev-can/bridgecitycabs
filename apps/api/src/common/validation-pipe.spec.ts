import { describe, expect, it } from 'vitest';
import { ApiCode } from './api-code.js';
import { validationExceptionFactory } from './validation-pipe.js';

describe('validationExceptionFactory', () => {
  it('maps each property to one message', () => {
    const exception = validationExceptionFactory([
      {
        property: 'q',
        constraints: {
          minLength: 'q must be longer than or equal to 3 characters',
        },
        children: [],
      },
      {
        property: 'stops',
        children: [
          {
            property: '0',
            children: [
              {
                property: 'lat',
                constraints: { isLatitude: 'lat must be a latitude' },
                children: [],
              },
            ],
          },
        ],
      },
    ]);

    expect(exception.getResponse()).toEqual({
      code: ApiCode.VALIDATION,
      message: 'Validation failed',
      fields: {
        q: 'q must be longer than or equal to 3 characters',
        'stops.0.lat': 'lat must be a latitude',
      },
    });
  });
});
