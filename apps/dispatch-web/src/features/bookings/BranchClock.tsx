import { Clock } from 'lucide-react'
import { DateTime } from 'luxon'
import { useEffect, useState } from 'react'

export function BranchClock({ timezone }: { timezone: string }) {
  const [now, setNow] = useState(() => DateTime.now().setZone(timezone))

  useEffect(() => {
    setNow(DateTime.now().setZone(timezone))
    const timer = window.setInterval(() => {
      setNow(DateTime.now().setZone(timezone))
    }, 1000)
    return () => window.clearInterval(timer)
  }, [timezone])

  if (!now.isValid) return null

  return (
    <div className="flex items-center gap-1.5 font-medium tabular-nums text-xs text-neutral-700">
      <Clock className="size-3.5 text-neutral-400" />
      <time dateTime={now.toISO() ?? undefined} title={timezone}>
        {now.toFormat('ccc dd LLL • HH:mm:ss ZZZZ')}
      </time>
    </div>
  )
}
