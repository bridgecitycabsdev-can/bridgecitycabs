import { create } from 'zustand'
import { blankForm, type FareQuote, type JobForm } from './schema'

export const MAX_DRAFTS = 5

export type DraftIdem = { key: string; hash: string }

export type Draft = {
  id: string
  form: JobForm
  quote: FareQuote | null
  dirty: boolean
  idem: DraftIdem | null
  errors: Record<string, string>
  activeJob: { trackingId: string } | null
  autoName: string | null
}

type DraftState = {
  drafts: Draft[]
  activeId: string
  panel: 'draft' | 'edit'
  selectedBookingId: string | null
  addDraft: () => void
  setActive: (id: string) => void
  showEdit: () => void
  selectBooking: (id: string) => void
  patch: (id: string, form: Partial<JobForm>) => void
  setZone: (id: string, zone: JobForm['zone']) => void
  setQuote: (id: string, quote: FareQuote | null) => void
  setErrors: (id: string, errors: Record<string, string>) => void
  setActiveJob: (id: string, activeJob: Draft['activeJob']) => void
  setAutoName: (id: string, name: string | null) => void
  rememberIdem: (id: string, idem: DraftIdem) => void
  reset: (id: string) => void
}

function newDraft(): Draft {
  return {
    id: crypto.randomUUID(),
    form: blankForm(),
    quote: null,
    dirty: false,
    idem: null,
    errors: {},
    activeJob: null,
    autoName: null,
  }
}

const first = newDraft()

export const useDrafts = create<DraftState>((set, get) => ({
  drafts: [first],
  activeId: first.id,
  panel: 'draft',
  selectedBookingId: null,
  addDraft: () => {
    const drafts = get().drafts
    if (drafts.length >= MAX_DRAFTS) return
    const draft = newDraft()
    set({ drafts: [...drafts, draft], activeId: draft.id, panel: 'draft' })
  },
  setActive: (id) => set({ activeId: id, panel: 'draft' }),
  showEdit: () => set({ panel: 'edit' }),
  selectBooking: (id) => set({ selectedBookingId: id }),
  patch: (id, form) =>
    set({
      drafts: get().drafts.map((draft) =>
        draft.id === id
          ? { ...draft, dirty: true, errors: {}, form: { ...draft.form, ...form } }
          : draft,
      ),
    }),
  setZone: (id, zone) =>
    set({
      drafts: get().drafts.map((draft) =>
        draft.id === id ? { ...draft, dirty: true, form: { ...draft.form, zone } } : draft,
      ),
    }),
  setQuote: (id, quote) =>
    set({
      drafts: get().drafts.map((draft) => (draft.id === id ? { ...draft, quote } : draft)),
    }),
  setErrors: (id, errors) =>
    set({
      drafts: get().drafts.map((draft) => (draft.id === id ? { ...draft, errors } : draft)),
    }),
  setActiveJob: (id, activeJob) =>
    set({
      drafts: get().drafts.map((draft) => (draft.id === id ? { ...draft, activeJob } : draft)),
    }),
  setAutoName: (id, autoName) =>
    set({
      drafts: get().drafts.map((draft) => (draft.id === id ? { ...draft, autoName } : draft)),
    }),
  rememberIdem: (id, idem) =>
    set({
      drafts: get().drafts.map((draft) => (draft.id === id ? { ...draft, idem } : draft)),
    }),
  reset: (id) =>
    set({
      drafts: get().drafts.map((draft) => (draft.id === id ? { ...newDraft(), id: draft.id } : draft)),
    }),
}))

export function anyDraftDirty() {
  return useDrafts.getState().drafts.some((draft) => draft.dirty)
}
