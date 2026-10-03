import { z } from 'zod'

const errorBodySchema = z.object({
  code: z.string().optional(),
  message: z.string().optional(),
  fields: z.record(z.string(), z.string()).optional(),
})

/** openapi-fetch puts non-2xx JSON on `error`; some call sites only type `data`. */
export function apiErrorBody(result: { data?: unknown; response: Response }) {
  const withError = result as { data?: unknown; error?: unknown; response: Response }
  const raw = withError.error ?? withError.data
  return errorBodySchema.safeParse(raw)
}
