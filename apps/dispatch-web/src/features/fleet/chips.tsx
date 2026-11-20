import { FLEET_CHIPS, type FleetChip } from '@bridgecabs/api-client'
import { CHIP_COLOR, chipCounts, useFleet } from '@/features/fleet/store'

export function FleetChips() {
  const drivers = useFleet((state) => state.drivers)
  const selected = useFleet((state) => state.chip)
  const setChip = useFleet((state) => state.setChip)
  const counts = chipCounts(Object.values(drivers))

  // Filter out AWAY if 0 or keep core chips matching Image 2
  const visibleChips = FLEET_CHIPS.filter((chip) => chip !== 'AWAY' || counts[chip] > 0)

  return (
    <div className="flex flex-wrap items-center gap-1.5 rounded-xl border border-neutral-200/90 bg-white/95 p-1.5 shadow-md shadow-neutral-200/50 backdrop-blur-md">
      {visibleChips.map((chip) => (
        <ChipButton
          key={chip}
          chip={chip}
          count={counts[chip]}
          pressed={selected === chip}
          onSelect={setChip}
        />
      ))}
    </div>
  )
}

function ChipButton({
  chip,
  count,
  pressed,
  onSelect,
}: {
  chip: FleetChip
  count: number
  pressed: boolean
  onSelect: (chip: FleetChip) => void
}) {
  const color = chip === 'ALL' ? '#C4161C' : CHIP_COLOR[chip]

  return (
    <button
      type="button"
      aria-pressed={pressed}
      aria-label={`${chip} ${count}`}
      className={`inline-flex items-center gap-1.5 rounded-full px-3 py-1 text-xs font-bold transition-all cursor-pointer ${
        pressed
          ? 'bg-[#C4161C] text-white shadow-xs'
          : 'bg-neutral-100/80 text-neutral-700 hover:bg-neutral-200/80'
      }`}
      onClick={() => onSelect(chip)}
    >
      {chip !== 'ALL' && (
        <span
          className="size-2 rounded-full"
          style={{ background: pressed ? '#ffffff' : color }}
        />
      )}
      <span>{chip}</span>
      <span
        className={`font-mono text-[11px] ${
          pressed ? 'text-white/90' : 'text-neutral-500'
        }`}
      >
        {count}
      </span>
    </button>
  )
}
