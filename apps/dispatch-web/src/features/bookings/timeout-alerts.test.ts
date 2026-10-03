import { beforeEach, describe, expect, it, vi } from 'vitest'
import { useTimeoutAlerts } from './timeout-alerts'

describe('timeout sound alerts', () => {
  beforeEach(() => {
    localStorage.clear()
    useTimeoutAlerts.setState({ badge: 0, soundEnabled: false, primed: false })
  })

  it('does not create an AudioContext before the toggle is clicked', () => {
    const AudioCtx = vi.fn(function FakeAudioContext(this: {
      state: string
      currentTime: number
      resume: () => Promise<void>
      createOscillator: () => {
        connect: () => void
        start: () => void
        stop: () => void
        frequency: { value: number }
        type: string
      }
      createGain: () => {
        connect: () => void
        gain: { value: number; exponentialRampToValueAtTime: () => void }
      }
      destination: unknown
    }) {
      this.state = 'running'
      this.currentTime = 0
      this.resume = async () => undefined
      this.createOscillator = () => ({
        connect: () => undefined,
        start: () => undefined,
        stop: () => undefined,
        frequency: { value: 0 },
        type: 'sine',
      })
      this.createGain = () => ({
        connect: () => undefined,
        gain: { value: 0, exponentialRampToValueAtTime: () => undefined },
      })
      this.destination = {}
    })
    vi.stubGlobal('AudioContext', AudioCtx)

    useTimeoutAlerts.getState().markTimeout()
    useTimeoutAlerts.getState().playBeep()
    expect(AudioCtx).not.toHaveBeenCalled()

    useTimeoutAlerts.getState().setSoundEnabled(true)
    useTimeoutAlerts.getState().primeAudio()
    expect(AudioCtx).toHaveBeenCalled()
    expect(localStorage.getItem('bridgecabs.dispatch.soundAlerts')).toBe('1')
    vi.unstubAllGlobals()
  })
})
