import { AlertTriangle } from 'lucide-react'
import { useEffect } from 'react'
import { z } from 'zod'
import { useSession } from '@/app/session'
import { env } from '@/lib/env'
import { api, jsonBody } from '@/lib/api'
import { CLOSED_STATUSES, phoneToE164 } from './schema'
import { useDrafts, type Draft } from './store'

const fieldClass =
  'w-full rounded-lg border border-neutral-200 bg-neutral-50/80 px-2.5 py-1.5 text-xs text-neutral-900 outline-none transition placeholder:text-neutral-400 focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C]'

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
    <div className="space-y-3">
      {/* 2 Columns: Phone and Name */}
      <fieldset className="rounded-xl border border-neutral-200/90 bg-white p-3 shadow-xs space-y-2">
        <legend className="text-[11px] font-bold tracking-wider text-neutral-600 uppercase">
          PASSENGER DETAILS
        </legend>

        <div className="grid grid-cols-2 gap-2">
          <label className="block text-xs">
            <span className="block text-[11px] font-semibold text-neutral-600 mb-1">PHONE NUMBER</span>
            <input
              className={fieldClass}
              aria-label="Phone"
              placeholder="+1 (403) 555-0184"
              inputMode="tel"
              value={draft.form.phone}
              aria-invalid={draft.errors.phone ? true : undefined}
              onChange={(event) => patch(draft.id, { phone: event.target.value })}
            />
            {draft.errors.phone ? (
              <span className="text-destructive text-[11px] mt-0.5 block">{draft.errors.phone}</span>
            ) : null}
          </label>

          <label className="block text-xs">
            <span className="block text-[11px] font-semibold text-neutral-600 mb-1">PASSENGER NAME</span>
            <input
              className={fieldClass}
              aria-label="Name"
              placeholder="Elena Rostova"
              value={draft.form.name}
              aria-invalid={draft.errors.name ? true : undefined}
              onChange={(event) => {
                setAutoName(draft.id, null)
                patch(draft.id, { name: event.target.value })
              }}
            />
            {draft.errors.name ? (
              <span className="text-destructive text-[11px] mt-0.5 block">{draft.errors.name}</span>
            ) : null}
          </label>
        </div>

        {/* Existing Open Booking Warning */}
        {draft.activeJob ? (
          <div className="rounded-lg border border-amber-300 bg-amber-50/90 p-2.5 text-xs text-amber-900 mt-2">
            <div className="flex items-center justify-between">
              <span className="flex items-center gap-1.5 font-bold text-amber-900 text-xs">
                <AlertTriangle className="size-3.5 text-amber-600" />
                <span>Existing Open Booking</span>
              </span>
              <button type="button" className="font-semibold text-amber-800 underline text-[11px] cursor-pointer">
                View job
              </button>
            </div>
            <p className="text-amber-800 text-[11px] mt-0.5">
              This phone already has an open job: {draft.activeJob.trackingId}.
            </p>
          </div>
        ) : null}
      </fieldset>

      {/* Dispatcher Notes */}
      <div className="rounded-xl border border-neutral-200/90 bg-white p-3 shadow-xs space-y-1">
        <label className="block text-xs">
          <span className="block text-[11px] font-bold tracking-wider text-neutral-600 uppercase mb-1">
            DISPATCHER NOTES
          </span>
          <textarea
            className="w-full rounded-lg border border-neutral-200 bg-neutral-50/80 px-2.5 py-1.5 text-xs text-neutral-900 outline-none transition placeholder:text-neutral-400 focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C] min-h-14"
            aria-label="Notes"
            placeholder="Wait near North luggage revolving door"
            maxLength={500}
            value={draft.form.notes}
            onChange={(event) => patch(draft.id, { notes: event.target.value })}
          />
          {draft.errors.notes ? (
            <span className="text-destructive text-[11px] mt-0.5 block">{draft.errors.notes}</span>
          ) : null}
        </label>
      </div>
    </div>
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
  try {
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
  } catch {
    // Passenger lookup is best-effort.
  }

  try {
    const bookings = await api.GET('/api/v1/bookings', {
      params: { query: { phone, ...(branchId ? { branchId } : {}) } },
    })
    if (!bookings.response.ok) return
    const jobs = bookingPage.safeParse(await jsonBody(bookings))
    const open = jobs.success
      ? jobs.data.data.find((job) => !CLOSED_STATUSES.has(job.status))
      : undefined
    useDrafts.getState().setActiveJob(draftId, open ? { trackingId: open.trackingId } : null)
  } catch {
    // Booking lookup is best-effort.
  }
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
