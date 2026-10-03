import { useQuery, useQueryClient } from '@tanstack/react-query'
import { useState } from 'react'
import { z } from 'zod'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import { apiErrorBody } from '@/features/bookings/api-error'
import { candidateSchema, formatDistance, reasonLabel } from '@/features/bookings/booking-detail'
import { useBookingUi } from '@/features/bookings/selection'
import { api, jsonBody } from '@/lib/api'

export function AssignPanel({ bookingId }: { bookingId: string }) {
  const role = useSession((state) => state.profile?.role.name)
  const setToast = useBookingUi((state) => state.setToast)
  const setTab = useBookingUi((state) => state.setTab)
  const queryClient = useQueryClient()
  const [pendingId, setPendingId] = useState<string | null>(null)
  const canAct = role === 'dispatcher' || role === 'branch_admin' || role === 'super_admin'

  const candidates = useQuery({
    queryKey: ['booking-candidates', bookingId],
    enabled: canAct,
    queryFn: async () => {
      const result = await api.GET('/api/v1/bookings/{id}/candidates', {
        params: { path: { id: bookingId } },
      })
      if (!result.response.ok) throw new Error('Could not load candidates')
      return z.array(candidateSchema).parse(await jsonBody(result))
    },
  })

  async function assign(driverId: string) {
    if (pendingId) return
    setPendingId(driverId)
    try {
      const result = await api.POST('/api/v1/bookings/{id}/assign', {
        params: { path: { id: bookingId } },
        body: { driverId },
      })
      if (result.response.status === 409) {
        const body = apiErrorBody(result)
        const code = body.success ? body.data.code : undefined
        setToast(
          code === 'DRIVER_NOT_AVAILABLE'
            ? 'Driver is no longer available'
            : body.success
              ? (body.data.message ?? 'Could not assign')
              : 'Could not assign',
        )
        void candidates.refetch()
        return
      }
      if (!result.response.ok) {
        setToast('Could not assign that driver')
        return
      }
      void queryClient.invalidateQueries({ queryKey: ['bookings'] })
      void queryClient.invalidateQueries({ queryKey: ['booking', bookingId] })
      setTab('job')
      setToast('Driver assigned')
    } finally {
      setPendingId(null)
    }
  }

  if (!canAct) {
    return <p className="text-muted-foreground text-sm">You cannot assign drivers.</p>
  }

  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between gap-2">
        <h3 className="text-sm font-semibold">Nearby drivers</h3>
        <Button type="button" size="xs" variant="outline" onClick={() => setTab('job')}>
          Back
        </Button>
      </div>
      {candidates.isPending ? (
        <p className="text-muted-foreground text-sm">Loading candidates…</p>
      ) : null}
      {candidates.isError ? (
        <p className="text-destructive text-sm">Could not load candidates.</p>
      ) : null}
      <ul className="space-y-1.5">
        {candidates.data?.map((row) => (
          <li
            key={row.driverId}
            className={`rounded-md border px-2.5 py-2 text-sm ${row.eligible ? '' : 'opacity-50'}`}
          >
            <div className="flex items-center justify-between gap-2">
              <div>
                <p className="font-medium">
                  Unit {row.unit || '—'} · {row.name || 'Driver'}
                </p>
                <p className="text-muted-foreground text-xs">
                  {formatDistance(row.distanceM)}
                  {!row.eligible
                    ? ` · ${row.reasons.map(reasonLabel).join(', ')}`
                    : ''}
                </p>
              </div>
              <Button
                type="button"
                size="sm"
                disabled={!row.eligible || pendingId != null}
                aria-label={
                  pendingId === row.driverId
                    ? `Assigning Unit ${row.unit}`
                    : `Assign Unit ${row.unit}`
                }
                onClick={() => void assign(row.driverId)}
              >
                {pendingId === row.driverId ? 'Assigning…' : 'Assign'}
              </Button>
            </div>
          </li>
        ))}
      </ul>
      {candidates.data?.length === 0 ? (
        <p className="text-muted-foreground text-sm">No available drivers nearby.</p>
      ) : null}
    </div>
  )
}
