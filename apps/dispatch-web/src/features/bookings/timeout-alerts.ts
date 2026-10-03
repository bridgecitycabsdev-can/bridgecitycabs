import { create } from 'zustand'

const STORAGE_KEY = 'bridgecabs.dispatch.soundAlerts'

function readSoundPref() {
  try {
    return localStorage.getItem(STORAGE_KEY) === '1'
  } catch {
    return false
  }
}

type TimeoutAlerts = {
  /** Unseen NO_DRIVER_FOUND events since the timeout panel was last opened. */
  badge: number
  soundEnabled: boolean
  primed: boolean
  markTimeout: () => void
  clearBadge: () => void
  setSoundEnabled: (enabled: boolean) => void
  primeAudio: () => void
  playBeep: () => void
}

let audioCtx: AudioContext | null = null

function context() {
  if (typeof window === 'undefined') return null
  const Ctor = window.AudioContext || (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext
  if (!Ctor) return null
  if (!audioCtx) audioCtx = new Ctor()
  return audioCtx
}

export const useTimeoutAlerts = create<TimeoutAlerts>((set, get) => ({
  badge: 0,
  soundEnabled: readSoundPref(),
  primed: false,
  markTimeout: () => set({ badge: get().badge + 1 }),
  clearBadge: () => set({ badge: 0 }),
  setSoundEnabled: (enabled) => {
    try {
      localStorage.setItem(STORAGE_KEY, enabled ? '1' : '0')
    } catch {
      /* ignore quota / private mode */
    }
    set({ soundEnabled: enabled })
  },
  primeAudio: () => {
    const ctx = context()
    if (!ctx) return
    void ctx.resume().then(() => set({ primed: true }))
  },
  playBeep: () => {
    if (!get().soundEnabled) return
    const ctx = context()
    if (!ctx) return
    void ctx.resume().then(() => {
      const osc = ctx.createOscillator()
      const gain = ctx.createGain()
      osc.type = 'sine'
      osc.frequency.value = 880
      gain.gain.value = 0.08
      osc.connect(gain)
      gain.connect(ctx.destination)
      const now = ctx.currentTime
      osc.start(now)
      gain.gain.exponentialRampToValueAtTime(0.0001, now + 0.18)
      osc.stop(now + 0.2)
      set({ primed: true })
    })
  },
}))
