import { RefreshCw } from 'lucide-react'
import { Button } from '@/components/ui/button'
import type { FareQuote, FareZone } from './schema'

const money = new Intl.NumberFormat('en-CA', { style: 'currency', currency: 'CAD' })

export function QuoteCard({
  quote,
  vehicleTypeId,
  busy,
  onZone,
  onRecalculate,
}: {
  quote: FareQuote | null
  vehicleTypeId: string
  busy: boolean
  onZone: (zone: FareZone) => void
  onRecalculate: () => void
}) {
  const option = quote?.options.find((row) => row.vehicleTypeId === vehicleTypeId) ?? null
  return (
    <section className="bg-muted/40 space-y-2 rounded-md border p-2" aria-label="Quote">
      <div className="flex items-center justify-between gap-2">
        <div className="flex gap-1" role="group" aria-label="Zone">
          <ZoneButton
            current={quote?.zone ?? null}
            zone="INSIDE_TOWN"
            label="Inside town"
            onZone={onZone}
          />
          <ZoneButton
            current={quote?.zone ?? null}
            zone="OUT_OF_TOWN"
            label="Out of town"
            onZone={onZone}
          />
        </div>
        <Button type="button" variant="outline" size="sm" onClick={onRecalculate} disabled={busy}>
          <RefreshCw />
          Recalculate
        </Button>
      </div>
      {!quote ? (
        <p className="text-muted-foreground text-sm">
          Choose a pickup, drop-off, and vehicle to price the trip.
        </p>
      ) : null}
      {quote && !option ? (
        <p className="text-destructive text-sm">No fare for this vehicle in this zone.</p>
      ) : null}
      {quote && option ? (
        <div className="space-y-1 text-sm">
          <p className="flex items-center gap-2">
            <span>
              {(quote.distanceM / 1000).toFixed(1)} km · {Math.round(quote.durationS / 60)} min
            </span>
            {quote.source === 'ESTIMATE' ? (
              <span className="bg-amber-100 text-amber-900 rounded px-1.5 py-0.5 text-xs font-medium">
                Estimated
              </span>
            ) : null}
          </p>
          <p className="text-muted-foreground">Subtotal {money.format(option.subtotalCents / 100)}</p>
          <p className="text-muted-foreground">GST {money.format(option.taxCents / 100)}</p>
          <p className={quote.priceChanged ? 'bg-amber-100 rounded px-1 font-semibold' : 'font-semibold'}>
            Total {money.format(option.totalCents / 100)}
          </p>
          {quote.priceChanged ? (
            <p className="text-amber-800 text-xs">The price changed. Review it, then book again.</p>
          ) : null}
        </div>
      ) : null}
    </section>
  )
}

function ZoneButton({
  current,
  zone,
  label,
  onZone,
}: {
  current: FareZone | null
  zone: FareZone
  label: string
  onZone: (zone: FareZone) => void
}) {
  return (
    <button
      type="button"
      className="rounded-md px-2 py-1 text-xs data-[on=true]:bg-primary data-[on=true]:text-primary-foreground"
      data-on={current === zone}
      aria-pressed={current === zone}
      onClick={() => onZone(zone)}
    >
      {label}
    </button>
  )
}
