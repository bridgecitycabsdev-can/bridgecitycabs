import { useEffect } from 'react'
import { z } from 'zod'
import { useSession } from '@/app/session'
import { env } from '@/lib/env'
import { api, jsonBody } from '@/lib/api'
import { CLOSED_STATUSES, phoneToE164 } from './schema'
import { useDrafts, type Draft } from './store'

const fieldClass =
  'border-input bg-background h-8 w-full rounded-md border px-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring'

const passengerPage = z.object({
  data: z.array(
    z.object({
      firstName: z.string(),
      lastName: z.string().nullable().optional(),
      phone: z.string(),
    }),
  ),
})

const bookingPage = z.object({
  data: z.array(
    z.object({
      trackingId: z.string(),
      status: z.string(),
    }),
  ),
})

export function PassengerFields({ draft }: { draft: Draft }) {
  const patch = useDrafts((state) => state.patch)
  const setActiveJob = useDrafts((state) => state.setActiveJob)
  const setAutoName = useDrafts((state) => state.setAutoName)
  const branchId = useBranchId()

  useEffect(() => {
    const phone = phoneToE164(draft.form.phone)
    if (!phone) {
      setActiveJob(draft.id, null)
      return
    }
    const timer = setTimeout(() => {
      void lookup(draft.id, phone, branchId)
    }, 400)
    return () => clearTimeout(timer)
  }, [branchId, draft.form.phone, draft.id, setActiveJob])

  return (
    <fieldset className="space-y-2">
      <legend className="text-xs font-medium">Passenger</legend>
      <label className="block text-xs">
        <span className="text-muted-foreground">Phone</span>
        <input
          className={fieldClass}
          aria-label="Phone"
          inputMode="tel"
          value={draft.form.phone}
          aria-invalid={draft.errors.phone ? true : undefined}
          onChange={(event) => patch(draft.id, { phone: event.target.value })}
        />
        {draft.errors.phone ? <span className="text-destructive">{draft.errors.phone}</span> : null}
        {draft.activeJob ? (
          <span className="text-amber-700">
            This phone already has job {draft.activeJob.trackingId}
          </span>
        ) : null}
      </label>
      <label className="block text-xs">
        <span className="text-muted-foreground">Name</span>
        <input
          className={fieldClass}
          aria-label="Name"
          value={draft.form.name}
          aria-invalid={draft.errors.name ? true : undefined}
          onChange={(event) => {
            setAutoName(draft.id, null)
            patch(draft.id, { name: event.target.value })
          }}
        />
        {draft.errors.name ? <span className="text-destructive">{draft.errors.name}</span> : null}
      </label>
      <label className="block text-xs">
        <span className="text-muted-foreground">Notes</span>
        <textarea
          className="border-input bg-background min-h-16 w-full rounded-md border px-2 py-1 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring"
          aria-label="Notes"
          maxLength={500}
          value={draft.form.notes}
          onChange={(event) => patch(draft.id, { notes: event.target.value })}
        />
        {draft.errors.notes ? <span className="text-destructive">{draft.errors.notes}</span> : null}
      </label>
    </fieldset>
  )
}

function useBranchId() {
  const role = useSession((state) => state.profile?.role.name)
  const selected = useSession((state) => state.branchId)
  const own = useSession((state) => state.profile?.branch?.id)
  return role === 'super_admin' ? selected : (own ?? null)
}

async function lookup(draftId: string, phone: string, branchId: string | null) {
  const state = useDrafts.getState()
  const draft = state.drafts.find((item) => item.id === draftId)
  if (!draft || phoneToE164(draft.form.phone) !== phone) return
  const passengers = await fetch(passengerSearchUrl(phone), {
    headers: authHeaders(),
    credentials: 'include',
  })
  const latest = useDrafts.getState().drafts.find((item) => item.id === draftId)
  if (!latest || phoneToE164(latest.form.phone) !== phone) return
  if (passengers.ok) {
    const page = passengerPage.safeParse(await passengers.json())
    const match = page.success ? page.data.data[0] : undefined
    if (match) {
      const filled = [match.firstName, match.lastName].filter(Boolean).join(' ')
      const name = latest.form.name
      if (filled && (!name.trim() || name === latest.autoName) && filled !== name) {
        useDrafts.getState().setAutoName(draftId, filled)
        useDrafts.getState().patch(draftId, { name: filled })
      }
    }
  }
  const bookings = await api.GET('/api/v1/bookings', {
    params: { query: { phone, ...(branchId ? { branchId } : {}) } },
  })
  if (!bookings.response.ok) return
  const jobs = bookingPage.safeParse(await jsonBody(bookings))
  const open = jobs.success
    ? jobs.data.data.find((job) => !CLOSED_STATUSES.has(job.status))
    : undefined
  useDrafts.getState().setActiveJob(draftId, open ? { trackingId: open.trackingId } : null)
}

function passengerSearchUrl(phone: string) {
  const url = new URL('/api/v1/passengers', env.apiOrigin)
  url.searchParams.set('search', phone)
  url.searchParams.set('pageSize', '5')
  return url.toString()
}

function authHeaders() {
  const token = useSession.getState().accessToken
  const headers = new Headers({ Accept: 'application/json', 'X-Client': 'web' })
  if (token) headers.set('Authorization', `Bearer ${token}`)
  return headers
}
