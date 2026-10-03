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
    <time
      className="text-muted-foreground tabular-nums text-sm"
      dateTime={now.toISO() ?? undefined}
      title={timezone}
    >
      {now.toFormat('ccc dd LLL yyyy · h:mm:ss a')}
    </time>
  )
}
