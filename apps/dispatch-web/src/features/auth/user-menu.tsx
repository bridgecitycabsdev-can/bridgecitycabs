import { ChevronDown, LogOut, Shield } from 'lucide-react'
import { useEffect, useId, useRef, useState } from 'react'
import { useSession } from '@/app/session'
import { logout } from '@/features/auth/session'

export function UserMenu() {
  const profile = useSession((state) => state.profile)
  const [open, setOpen] = useState(false)
  const rootRef = useRef<HTMLDivElement>(null)
  const menuId = useId()

  const displayName = profile?.email
    ? profile.email.split('@')[0].replace('.', ' ')
    : 'Adam D.'
  const initials = displayName
    .split(' ')
    .map((s) => s[0]?.toUpperCase() ?? '')
    .slice(0, 2)
    .join('') || 'AD'

  const roleText = profile?.role.name
    ? roleLabel(profile.role.name)
    : 'Head Dispatcher'

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
        className="flex items-center gap-2.5 rounded-lg border border-neutral-200/90 bg-white px-2.5 py-1 text-left text-xs font-medium text-neutral-800 shadow-xs hover:bg-neutral-50 transition cursor-pointer"
        aria-haspopup="menu"
        aria-expanded={open}
        aria-controls={menuId}
        onClick={() => setOpen((current) => !current)}
      >
        <div className="flex size-7 shrink-0 items-center justify-center rounded-full bg-neutral-900 font-bold text-white text-[11px]">
          {initials}
        </div>
        <div className="hidden sm:block text-left leading-tight">
          <div className="font-semibold text-neutral-900">{displayName}</div>
          <div className="text-[10px] text-neutral-500">{roleText}</div>
        </div>
        <ChevronDown className="size-3.5 text-neutral-400" />
      </button>

      {open ? (
        <div
          id={menuId}
          role="menu"
          className="absolute right-0 z-30 mt-1.5 w-56 rounded-xl border border-neutral-200 bg-white p-1.5 shadow-lg shadow-neutral-200/70"
        >
          <div className="px-2.5 py-2 border-b border-neutral-100 mb-1">
            <div className="font-semibold text-xs text-neutral-900">{profile?.email ?? 'dispatcher@bridgecabs.ca'}</div>
            <div className="flex items-center gap-1 text-[11px] text-neutral-500 mt-0.5">
              <Shield className="size-3 text-emerald-600" />
              <span>{roleText}</span>
            </div>
          </div>
          <button
            type="button"
            role="menuitem"
            className="flex w-full items-center gap-2 rounded-lg px-2.5 py-2 text-left text-xs font-medium text-red-600 hover:bg-red-50 transition cursor-pointer"
            onClick={() => void logout()}
          >
            <LogOut className="size-3.5" />
            <span>Sign out</span>
          </button>
        </div>
      ) : null}
    </div>
  )
}

function roleLabel(role: string | undefined) {
  if (!role) return 'Dispatcher'
  if (role === 'super_admin') return 'Super Admin'
  return role
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ')
}
