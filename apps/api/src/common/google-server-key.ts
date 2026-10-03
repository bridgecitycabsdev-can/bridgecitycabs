import type { ConfigService } from '@nestjs/config';

/** A dedicated key wins. Otherwise the one server key, never a browser or mobile key. */
export function googleServerKey(config: ConfigService, specific: string) {
  const named = config.get<string>(specific)?.trim();
  if (named) return named;
  return config.get<string>('GOOGLE_SERVER_API_KEY')?.trim() || '';
}
