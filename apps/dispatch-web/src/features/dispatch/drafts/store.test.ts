import { beforeEach, describe, expect, it } from 'vitest'
import { blankForm } from './schema'
import { useDrafts } from './store'

describe('draft store', () => {
  beforeEach(() => {
    const draft = {
      id: 'draft-1',
      form: { ...blankForm(), name: 'Amira', phone: '403-555-0100' },
      quote: null,
      dirty: true,
      idem: { key: 'idem-1', hash: 'abc' },
      errors: {},
      activeJob: null,
      autoName: null,
    }
    useDrafts.setState({
      drafts: [draft],
      activeId: draft.id,
      panel: 'draft',
      selectedBookingId: null,
    })
    localStorage.clear()
    sessionStorage.clear()
  })

  it('keeps draft fields when switching tabs and never writes storage', () => {
    useDrafts.getState().addDraft()
    const secondId = useDrafts.getState().activeId
    expect(secondId).not.toBe('draft-1')
    useDrafts.getState().patch(secondId, { name: 'Sam' })

    useDrafts.getState().setActive('draft-1')
    expect(useDrafts.getState().activeId).toBe('draft-1')
    expect(useDrafts.getState().drafts.find((row) => row.id === 'draft-1')?.form.name).toBe(
      'Amira',
    )
    expect(useDrafts.getState().drafts.find((row) => row.id === 'draft-1')?.idem?.key).toBe(
      'idem-1',
    )

    useDrafts.getState().setActive(secondId)
    expect(useDrafts.getState().drafts.find((row) => row.id === secondId)?.form.name).toBe('Sam')
    expect(localStorage.length).toBe(0)
    expect(sessionStorage.length).toBe(0)
  })

  it('stores an Idempotency-Key that reset clears', () => {
    useDrafts.getState().rememberIdem('draft-1', { key: 'idem-keep', hash: 'hash-1' })
    expect(useDrafts.getState().drafts[0]?.idem).toEqual({ key: 'idem-keep', hash: 'hash-1' })
    useDrafts.getState().rememberIdem('draft-1', { key: 'idem-keep', hash: 'hash-1' })
    expect(useDrafts.getState().drafts[0]?.idem?.key).toBe('idem-keep')
    useDrafts.getState().reset('draft-1')
    expect(useDrafts.getState().drafts[0]?.idem).toBeNull()
  })
})
