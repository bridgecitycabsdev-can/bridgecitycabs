import { useEffect, useRef, useState } from 'react'
import { z } from 'zod'
import { api, jsonBody } from '@/lib/api'

const suggestionSchema = z.object({
  placeId: z.string(),
  primaryText: z.string(),
  secondaryText: z.string(),
})

const detailsSchema = z.object({
  placeId: z.string(),
  address: z.string(),
  lat: z.number(),
  lng: z.number(),
})

export type PlaceSuggestion = z.infer<typeof suggestionSchema>
export type PlaceDetails = z.infer<typeof detailsSchema>

const DEBOUNCE_MS = 250

function newSession() {
  return crypto.randomUUID()
}

export function usePlaceSearch() {
  const [text, setText] = useState('')
  const [suggestions, setSuggestions] = useState<PlaceSuggestion[]>([])
  const [open, setOpen] = useState(false)
  const session = useRef(newSession())
  const abort = useRef<AbortController | null>(null)

  useEffect(() => {
    const query = text.trim()
    if (query.length < 3) {
      abort.current?.abort()
      return
    }
    const timer = setTimeout(() => {
      abort.current?.abort()
      const controller = new AbortController()
      abort.current = controller
      void api
        .GET('/api/v1/places/autocomplete', {
          params: { query: { q: query, session: session.current } },
          signal: controller.signal,
        })
        .then(async (result: any) => {
          if (controller.signal.aborted || !result.response.ok) return
          const parsed = z.array(suggestionSchema).safeParse(await jsonBody(result))
          if (parsed.success) {
            setSuggestions(parsed.data)
            setOpen(true)
          }
        })
        .catch(() => undefined)
    }, DEBOUNCE_MS)
    return () => clearTimeout(timer)
  }, [text])

  async function select(placeId: string) {
    const token = session.current
    const result = await api.GET('/api/v1/places/{placeId}', {
      params: { path: { placeId }, query: { session: token } },
    })
    session.current = newSession()
    setOpen(false)
    setSuggestions([])
    if (!result.response.ok) throw new Error('Could not load that place')
    const details = detailsSchema.parse(await jsonBody(result))
    setText(details.address)
    return details
  }

  function edit(value: string) {
    setText(value)
    setOpen(true)
    if (value.trim().length < 3) setSuggestions([])
  }

  return { text, edit, suggestions, open, setOpen, select }
}
