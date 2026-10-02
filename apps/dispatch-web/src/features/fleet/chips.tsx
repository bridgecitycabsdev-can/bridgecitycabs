import { FLEET_CHIPS, type FleetChip } from '@bridgecabs/api-client'
import { CHIP_COLOR, chipCounts, useFleet } from '@/features/fleet/store'

export function FleetChips() {
  const drivers = useFleet((state) => state.drivers)
  const selected = useFleet((state) => state.chip)
  const setChip = useFleet((state) => state.setChip)
  const counts = chipCounts(Object.values(drivers))

  return (
    <div className="bg-card/95 flex flex-wrap gap-1.5 rounded-lg border p-1.5 shadow-sm backdrop-blur-sm">
      {FLEET_CHIPS.map((chip) => (
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
  const color = chip === 'ALL' ? 'var(--color-text)' : CHIP_COLOR[chip]
  return (
    <button
      type="button"
      aria-pressed={pressed}
      aria-label={`${chip} ${count}`}
      className="inline-flex items-center gap-1.5 rounded-full border px-2.5 py-1 text-xs font-semibold"
      style={
        pressed
          ? { background: color, borderColor: color, color: '#fff' }
          : { background: 'transparent', borderColor: 'var(--border)', color: 'var(--color-text)' }
      }
      onClick={() => onSelect(chip)}
    >
      {chip === 'ALL' ? null : (
        <span className="size-2 rounded-full" style={{ background: pressed ? '#fff' : color }} />
      )}
      {chip}
      <span className={pressed ? 'opacity-90' : 'text-muted-foreground'}>{count}</span>
    </button>
  )
}
