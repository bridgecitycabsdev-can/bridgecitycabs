import { ArrowLeftRight, ArrowUpDown, Plus, Sparkles } from 'lucide-react'
import { usePlaceSearch, type PlaceDetails } from '@/features/dispatch/places/usePlaceSearch'
import { MAX_STOPS_BETWEEN, type PlaceValue } from './schema'

const fieldClass =
  'w-full rounded-lg border border-neutral-200 bg-neutral-50/80 px-2.5 py-1.5 text-xs text-neutral-900 outline-none transition placeholder:text-neutral-400 focus:border-[#C4161C] focus:bg-white focus:ring-1 focus:ring-[#C4161C]'

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
    <fieldset className="rounded-xl border border-neutral-200/90 bg-white p-3 shadow-xs space-y-2.5">
      <div className="flex items-center justify-between pb-1 border-b border-neutral-100">
        <legend className="text-[11px] font-bold tracking-wider text-neutral-600 uppercase">
          ITINERARY ROUTE
        </legend>
        <span className="flex items-center gap-1 rounded-full bg-emerald-50 px-2 py-0.5 font-mono text-[9px] font-semibold text-emerald-700 border border-emerald-200/60">
          <Sparkles className="size-2.5 text-emerald-600" />
          <span>GPS Auto-Geocode</span>
        </span>
      </div>

      {/* Pickup */}
      <div className="space-y-1">
        <div className="flex items-center justify-between text-[11px]">
          <span className="flex items-center gap-1.5 font-semibold text-neutral-700">
            <span className="size-2 rounded-full bg-emerald-500" />
            <span>PICKUP LOCATION</span>
          </span>
          <span className="font-mono text-[10px] text-neutral-400">#102</span>
        </div>
        <PlaceField
          key={`pickup-${props.pickup?.placeId ?? 'empty'}`}
          label="Pickup"
          placeholder="Park Place Mall (Main Entrance)"
          value={props.pickup}
          error={props.errors.pickup}
          onChange={props.onPickup}
        />
      </div>

      {/* Vias */}
      {props.vias.map((via, index) => (
        <div key={`${index}-${via.placeId || 'empty'}`} className="space-y-1">
          <div className="flex items-center justify-between text-[11px]">
            <span className="flex items-center gap-1 text-neutral-600 font-medium">
              <ArrowUpDown className="size-3 text-neutral-400" />
              <span>VIA {index + 1} (OPTIONAL)</span>
            </span>
            <button
              type="button"
              className="text-red-600 hover:text-red-800 text-[11px] font-semibold cursor-pointer"
              aria-label={`Remove stop ${index + 1}`}
              onClick={() => props.onRemoveVia(index)}
            >
              Remove
            </button>
          </div>
          <PlaceField
            key={`via-${index}-${via.placeId || 'empty'}`}
            label={`Stop ${index + 1}`}
            placeholder="440 University Dr W (Quick Stop)"
            value={via.placeId ? via : null}
            error={props.errors[`via.${index}`]}
            onChange={(place) => props.onVia(index, place)}
          />
        </div>
      ))}

      {/* Dropoff */}
      <div className="space-y-1">
        <div className="flex items-center justify-between text-[11px]">
          <span className="flex items-center gap-1.5 font-semibold text-neutral-700">
            <span className="size-2 rounded-xs bg-[#C4161C]" />
            <span>DROPOFF DESTINATION</span>
          </span>
        </div>
        <PlaceField
          key={`dropoff-${props.dropoff?.placeId ?? 'empty'}`}
          label="Drop-off"
          placeholder="Enmax Centre, 2510 Scenic Dr S"
          value={props.dropoff}
          error={props.errors.dropoff}
          onChange={props.onDropoff}
        />
      </div>

      {/* Add via & Swap buttons */}
      <div className="flex items-center justify-between pt-1 text-xs">
        <button
          type="button"
          disabled={props.vias.length >= MAX_STOPS_BETWEEN}
          onClick={props.onAddVia}
          className="inline-flex items-center gap-1 font-semibold text-[#C4161C] hover:text-[#9E1017] disabled:opacity-40 cursor-pointer"
        >
          <Plus className="size-3.5" />
          <span>Add via stop (max 3)</span>
        </button>
        <div className="flex items-center gap-2">
          <span className="font-mono text-[10px] text-neutral-400">
            {props.vias.length}/3 used
          </span>
          <button
            type="button"
            aria-label="Swap pickup and drop-off"
            onClick={props.onSwap}
            className="rounded p-1 text-neutral-400 hover:bg-neutral-100 hover:text-neutral-700 cursor-pointer"
          >
            <ArrowLeftRight className="size-3.5" />
          </button>
        </div>
      </div>
    </fieldset>
  )
}

function PlaceField({
  label,
  placeholder,
  value,
  error,
  onChange,
}: {
  label: string
  placeholder?: string
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
    <div className="relative">
      <input
        className={fieldClass}
        value={display}
        placeholder={placeholder}
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
      {error ? <span className="text-destructive text-[11px] block mt-0.5">{error}</span> : null}
      {search.open && search.suggestions.length > 0 ? (
        <div className="absolute left-0 right-0 z-30 mt-1">
          <ul className="bg-white max-h-48 w-full overflow-auto rounded-lg border border-neutral-200 p-1 shadow-lg">
            {search.suggestions.map((item) => (
              <li key={item.placeId}>
                <button
                  type="button"
                  className="hover:bg-neutral-50 block w-full rounded-md px-2.5 py-1.5 text-left text-xs"
                  onClick={() => void choose(item.placeId)}
                >
                  <span className="block font-medium text-neutral-800">{item.primaryText}</span>
                  <span className="text-neutral-400 block text-[10px]">{item.secondaryText}</span>
                </button>
              </li>
            ))}
          </ul>
          <p className="text-neutral-400 pt-1 text-[9px] text-right">Powered by Google</p>
        </div>
      ) : null}
    </div>
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
