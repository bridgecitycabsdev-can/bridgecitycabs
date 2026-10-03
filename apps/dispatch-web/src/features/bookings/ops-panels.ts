import { create } from 'zustand'

type OpsPanels = {
  timeoutOpen: boolean
  closedOpen: boolean
  paymentPendingOpen: boolean
  openTimeout: () => void
  openClosed: () => void
  openPaymentPending: () => void
  closeTimeout: () => void
  closeClosed: () => void
  closePaymentPending: () => void
}

export const useOpsPanels = create<OpsPanels>((set) => ({
  timeoutOpen: false,
  closedOpen: false,
  paymentPendingOpen: false,
  openTimeout: () => set({ timeoutOpen: true }),
  openClosed: () => set({ closedOpen: true }),
  openPaymentPending: () => set({ paymentPendingOpen: true }),
  closeTimeout: () => set({ timeoutOpen: false }),
  closeClosed: () => set({ closedOpen: false }),
  closePaymentPending: () => set({ paymentPendingOpen: false }),
}))
