import { CheckCircle2, AlertTriangle, Info, X } from 'lucide-react'
import { create } from 'zustand'

export type ToastType = 'success' | 'error' | 'info'

export interface ToastMessage {
  id: string
  type: ToastType
  message: string
  description?: string
}

interface ToastStore {
  toasts: ToastMessage[]
  addToast: (toast: Omit<ToastMessage, 'id'>) => void
  removeToast: (id: string) => void
}

export const useToastStore = create<ToastStore>((set) => ({
  toasts: [],
  addToast: (toast) => {
    const id = Math.random().toString(36).slice(2, 9)
    set((state) => ({ toasts: [...state.toasts, { ...toast, id }] }))
    setTimeout(() => {
      set((state) => ({ toasts: state.toasts.filter((t) => t.id !== id) }))
    }, 4000)
  },
  removeToast: (id) =>
    set((state) => ({ toasts: state.toasts.filter((t) => t.id !== id) })),
}))

export const toast = {
  success: (message: string, description?: string) =>
    useToastStore.getState().addToast({ type: 'success', message, description }),
  error: (message: string, description?: string) =>
    useToastStore.getState().addToast({ type: 'error', message, description }),
  info: (message: string, description?: string) =>
    useToastStore.getState().addToast({ type: 'info', message, description }),
}

export function ToastContainer() {
  const { toasts, removeToast } = useToastStore()

  if (toasts.length === 0) return null

  return (
    <div className="fixed top-4 right-4 z-50 flex flex-col gap-2 max-w-sm w-full pointer-events-none select-none">
      {toasts.map((t) => (
        <div
          key={t.id}
          className={`pointer-events-auto flex items-start gap-3 rounded-xl border p-3.5 shadow-lg backdrop-blur-md transition-all animate-in fade-in slide-in-from-top-2 duration-200 ${
            t.type === 'success'
              ? 'border-emerald-200 bg-white/95 text-neutral-900 shadow-emerald-500/10'
              : t.type === 'error'
              ? 'border-rose-200 bg-white/95 text-neutral-900 shadow-rose-500/10'
              : 'border-blue-200 bg-white/95 text-neutral-900 shadow-blue-500/10'
          }`}
        >
          {t.type === 'success' && <CheckCircle2 className="size-5 shrink-0 text-emerald-600 mt-0.5" />}
          {t.type === 'error' && <AlertTriangle className="size-5 shrink-0 text-rose-600 mt-0.5" />}
          {t.type === 'info' && <Info className="size-5 shrink-0 text-blue-600 mt-0.5" />}
          <div className="flex-1 text-xs">
            <div className="font-bold text-neutral-900 leading-tight">{t.message}</div>
            {t.description && <div className="text-neutral-500 mt-0.5">{t.description}</div>}
          </div>
          <button
            type="button"
            onClick={() => removeToast(t.id)}
            className="text-neutral-400 hover:text-neutral-700 transition cursor-pointer p-0.5"
          >
            <X className="size-3.5" />
          </button>
        </div>
      ))}
    </div>
  )
}
