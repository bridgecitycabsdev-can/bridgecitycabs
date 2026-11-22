/** Browser allow-list. A client that sends no Origin header is not checked against it. */
export function allowedWsOrigins(raw: string | undefined) {
  const origins = (raw ?? '')
    .split(',')
    .map((origin) => origin.trim().replace(/\/+$/, ''))
    .filter((origin) => origin.length > 0);

  for (const origin of origins) {
    if (origin === '*' || origin.includes('*')) {
      throw new Error(
        `WS_ALLOWED_ORIGINS must not contain wildcards (got ${JSON.stringify(origin)})`,
      );
    }
  }
  return origins;
}
