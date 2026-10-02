/** Browser allow-list. A client that sends no Origin header is not checked against it. */
export function allowedWsOrigins(raw: string | undefined) {
  return (raw ?? '')
    .split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);
}
