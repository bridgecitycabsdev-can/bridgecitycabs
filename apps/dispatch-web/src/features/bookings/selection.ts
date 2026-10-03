import { create } from 'zustand'
import { useFleet } from '@/features/fleet/store'

export type LiveOffer = {
  offerId: string
  driverId: string
  driverName: string
  unit: string
  expiresAt: string
}

export type MapAssignPrompt = {
  bookingId: string
  driverId: string
  unit: string
  name: string
  distanceM: number
}

type BookingUi = {
  selectedId: string | null
  modalOpen: boolean
  modalTab: 'job' | 'search' | 'assign'
  toast: string | null
  liveOffers: Record<string, LiveOffer>
  mapPrompt: MapAssignPrompt | null
  openJob: (id: string, tab?: BookingUi['modalTab']) => void
  openSearch: () => void
  closeModal: () => void
  setSelected: (id: string | null) => void
  setTab: (tab: BookingUi['modalTab']) => void
  setToast: (message: string | null) => void
  setMapPrompt: (prompt: MapAssignPrompt | null) => void
  offerCreated: (payload: {
    bookingId: string
    offerId: string
    driverId: string
    driverName: string
    expiresAt: string
  }) => void
  offerResolved: (payload: { bookingId: string; offerId: string }) => void
}

export const useBookingUi = create<BookingUi>((set, get) => ({
  selectedId: null,
  modalOpen: false,
  modalTab: 'job',
  toast: null,
  liveOffers: {},
  mapPrompt: null,
  openJob: (id, tab = 'job') =>
    set({ selectedId: id, modalOpen: true, modalTab: tab, mapPrompt: null }),
  openSearch: () => set({ modalOpen: true, modalTab: 'search' }),
  closeModal: () => set({ modalOpen: false, modalTab: 'job' }),
  setSelected: (id) => set({ selectedId: id, mapPrompt: null }),
  setTab: (tab) => set({ modalTab: tab }),
  setToast: (toast) => set({ toast }),
  setMapPrompt: (mapPrompt) => set({ mapPrompt }),
  offerCreated: (payload) => {
    const unit = useFleet.getState().drivers[payload.driverId]?.unit ?? ''
    set({
      liveOffers: {
        ...get().liveOffers,
        [payload.bookingId]: {
          offerId: payload.offerId,
          driverId: payload.driverId,
          driverName: payload.driverName,
          unit,
          expiresAt: payload.expiresAt,
        },
      },
    })
  },
  offerResolved: (payload) => {
    const current = get().liveOffers[payload.bookingId]
    if (!current || current.offerId !== payload.offerId) return
    const next = { ...get().liveOffers }
    delete next[payload.bookingId]
    set({ liveOffers: next })
  },
}))
