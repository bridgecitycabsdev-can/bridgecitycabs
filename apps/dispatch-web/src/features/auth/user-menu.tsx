import { useEffect, useId, useRef, useState } from 'react'
import { useSession } from '@/app/session'
import { logout } from '@/features/auth/session'

export function UserMenu() {
  const profile = useSession((state) => state.profile)
  const [open, setOpen] = useState(false)
  const rootRef = useRef<HTMLDivElement>(null)
  const menuId = useId()
  const label = profile?.email ?? 'Account'

  useEffect(() => {
    if (!open) return
    const close = (event: MouseEvent) => {
      if (!rootRef.current?.contains(event.target as Node)) setOpen(false)
    }
    const onKey = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setOpen(false)
    }
    document.addEventListener('mousedown', close)
    document.addEventListener('keydown', onKey)
    return () => {
      document.removeEventListener('mousedown', close)
      document.removeEventListener('keydown', onKey)
    }
  }, [open])

  return (
    <div className="relative" ref={rootRef}>
      <button
        type="button"
        className="hover:bg-muted max-w-48 truncate rounded-md border px-2.5 py-1.5 text-sm"
        aria-haspopup="menu"
        aria-expanded={open}
        aria-controls={menuId}
        onClick={() => setOpen((current) => !current)}
      >
        {label}
      </button>
      {open ? (
        <div
          id={menuId}
          role="menu"
          className="bg-card absolute right-0 z-20 mt-1 w-52 rounded-md border p-1 shadow-md"
        >
          <p className="text-muted-foreground px-2 py-1.5 text-xs">{roleLabel(profile?.role.name)}</p>
          <button
            type="button"
            role="menuitem"
            className="hover:bg-muted w-full rounded-sm px-2 py-1.5 text-left text-sm"
            onClick={() => void logout()}
          >
            Sign out
          </button>
        </div>
      ) : null}
    </div>
  )
}

function roleLabel(role: string | undefined) {
  if (!role) return 'Signed in'
  return role
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ')
}
