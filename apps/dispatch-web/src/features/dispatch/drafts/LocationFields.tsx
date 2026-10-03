import { ArrowLeftRight, Plus, X } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { usePlaceSearch, type PlaceDetails } from '@/features/dispatch/places/usePlaceSearch'
import { MAX_STOPS_BETWEEN, type PlaceValue } from './schema'

const fieldClass =
  'border-input bg-background h-8 w-full rounded-md border px-2 text-sm outline-none focus-visible:ring-2 focus-visible:ring-ring'

type Props = {
  pickup: PlaceValue | null
  dropoff: PlaceValue | null
  vias: PlaceValue[]
  errors: Record<string, string>
  onPickup: (place: PlaceValue | null) => void
  onDropoff: (place: PlaceValue | null) => void
  onVia: (index: number, place: PlaceValue | null) => void
  onAddVia: () => void
  onRemoveVia: (index: number) => void
  onSwap: () => void
}

export function LocationFields(props: Props) {
  return (
    <fieldset className="space-y-2">
      <legend className="text-xs font-medium">Trip</legend>
      <PlaceField
        key={`pickup-${props.pickup?.placeId ?? 'empty'}`}
        label="Pickup"
        value={props.pickup}
        error={props.errors.pickup}
        onChange={props.onPickup}
      />
      {props.vias.map((via, index) => (
        <div key={`${index}-${via.placeId || 'empty'}`} className="flex items-start gap-1">
          <div className="min-w-0 flex-1">
            <PlaceField
              key={`via-${index}-${via.placeId || 'empty'}`}
              label={`Stop ${index + 1}`}
              value={via.placeId ? via : null}
              error={props.errors[`via.${index}`]}
              onChange={(place) => props.onVia(index, place)}
            />
          </div>
          <Button
            type="button"
            variant="ghost"
            size="icon-sm"
            className="mt-5"
            aria-label={`Remove stop ${index + 1}`}
            onClick={() => props.onRemoveVia(index)}
          >
            <X />
          </Button>
        </div>
      ))}
      <div className="flex gap-1">
        <Button
          type="button"
          variant="outline"
          size="sm"
          disabled={props.vias.length >= MAX_STOPS_BETWEEN}
          onClick={props.onAddVia}
        >
          <Plus />
          Stop
        </Button>
        <Button type="button" variant="outline" size="sm" aria-label="Swap pickup and drop-off" onClick={props.onSwap}>
          <ArrowLeftRight />
          Swap
        </Button>
      </div>
      <PlaceField
        key={`dropoff-${props.dropoff?.placeId ?? 'empty'}`}
        label="Drop-off"
        value={props.dropoff}
        error={props.errors.dropoff}
        onChange={props.onDropoff}
      />
    </fieldset>
  )
}

function PlaceField({
  label,
  value,
  error,
  onChange,
}: {
  label: string
  value: PlaceValue | null
  error?: string
  onChange: (place: PlaceValue | null) => void
}) {
  const search = usePlaceSearch()
  const display = search.text.length > 0 || !value ? search.text : value.address

  async function choose(placeId: string) {
    const details = await search.select(placeId)
    onChange(toPlace(details))
  }

  return (
    <label className="block text-xs">
      <span className="text-muted-foreground">{label}</span>
      <input
        className={fieldClass}
        value={display}
        aria-label={label}
        aria-invalid={error ? true : undefined}
        autoComplete="off"
        onChange={(event) => {
          search.edit(event.target.value)
          if (value) onChange(null)
        }}
        onFocus={() => {
          if (!search.text && value) search.edit('')
        }}
      />
      {error ? <span className="text-destructive">{error}</span> : null}
      {search.open && search.suggestions.length > 0 ? (
        <div className="relative">
          <ul className="bg-popover absolute z-20 mt-1 max-h-48 w-full overflow-auto rounded-md border shadow-md">
            {search.suggestions.map((item) => (
              <li key={item.placeId}>
                <button
                  type="button"
                  className="hover:bg-muted block w-full px-2 py-1.5 text-left text-sm"
                  onClick={() => void choose(item.placeId)}
                >
                  <span className="block">{item.primaryText}</span>
                  <span className="text-muted-foreground block text-xs">{item.secondaryText}</span>
                </button>
              </li>
            ))}
          </ul>
          <p className="text-muted-foreground pt-1 text-[10px]">Powered by Google</p>
        </div>
      ) : null}
    </label>
  )
}

function toPlace(details: PlaceDetails): PlaceValue {
  return {
    address: details.address,
    placeId: details.placeId,
    lat: details.lat,
    lng: details.lng,
  }
}
