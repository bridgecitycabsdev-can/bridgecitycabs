import { create } from 'zustand'

type OpsPanels = {
  timeoutOpen: boolean
  closedOpen: boolean
  openTimeout: () => void
  openClosed: () => void
  closeTimeout: () => void
  closeClosed: () => void
}

export const useOpsPanels = create<OpsPanels>((set) => ({
  timeoutOpen: false,
  closedOpen: false,
  openTimeout: () => set({ timeoutOpen: true }),
  openClosed: () => set({ closedOpen: true }),
  closeTimeout: () => set({ timeoutOpen: false }),
  closeClosed: () => set({ closedOpen: false }),
}))
