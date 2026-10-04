import { describe, expect, it } from 'vitest';
import { allowedWsOrigins } from './allowed-origins.js';

describe('websocket origins', () => {
  it('splits the allow-list and drops blanks', () => {
    expect(allowedWsOrigins('http://localhost:5173, https://dispatch.example')).toEqual([
      'http://localhost:5173',
      'https://dispatch.example',
    ]);
    expect(allowedWsOrigins(undefined)).toEqual([]);
  });

  it('rejects bare and embedded wildcards', () => {
    expect(() => allowedWsOrigins('*')).toThrow(/wildcards/);
    expect(() => allowedWsOrigins('https://*.bridgecitycabs.com')).toThrow(
      /wildcards/,
    );
    expect(() =>
      allowedWsOrigins('http://localhost:5173, *'),
    ).toThrow(/wildcards/);
  });
});
