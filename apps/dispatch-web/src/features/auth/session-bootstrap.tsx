import { useEffect, useState, type ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { getAccessToken } from '@/app/session'
import { refreshSession } from '@/features/auth/session'

export function SessionBootstrap({ children }: { children: ReactNode }) {
  const [ready, setReady] = useState(false)
  const navigate = useNavigate()

  useEffect(() => {
    let cancelled = false
    void (async () => {
      try {
        if (getAccessToken()) return
        const ok = await refreshSession()
        if (!cancelled && !ok) navigate('/login', { replace: true })
      } finally {
        if (!cancelled) setReady(true)
      }
    })()
    return () => {
      cancelled = true
    }
  }, [navigate])

  if (!ready) {
    return (
      <p className="text-muted-foreground grid h-full place-items-center text-sm">Checking session…</p>
    )
  }

  return children
}
