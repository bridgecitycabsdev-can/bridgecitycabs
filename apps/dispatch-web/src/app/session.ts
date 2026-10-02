import { create } from 'zustand'
import { z } from 'zod'
import { getAccessToken, setAccessToken as setModuleAccessToken } from '@/app/access-token'
import { stopFleet, useFleet } from '@/features/fleet/store'

export { getAccessToken }

export const profileSchema = z.object({
  id: z.string(),
  email: z.string().nullable(),
  role: z.object({
    id: z.string(),
    name: z.string(),
  }),
  branch: z
    .object({
      id: z.string(),
      name: z.string(),
      city: z.string(),
    })
    .nullable(),
})

export type Profile = z.infer<typeof profileSchema>

type SessionState = {
  accessToken: string | null
  profile: Profile | null
  /** Branch a super admin is watching. Other roles use profile.branch. */
  branchId: string | null
  setAccessToken: (accessToken: string | null) => void
  setProfile: (profile: Profile | null) => void
  setBranchId: (branchId: string) => void
  clear: () => void
}

export const useSession = create<SessionState>((set, get) => ({
  accessToken: null,
  profile: null,
  branchId: null,
  setAccessToken: (accessToken) => {
    setModuleAccessToken(accessToken)
    set({ accessToken })
  },
  setProfile: (profile) => set({ profile }),
  setBranchId: (branchId) => {
    if (get().branchId === branchId) return
    useFleet.getState().replace([])
    set({ branchId })
  },
  clear: () => {
    setModuleAccessToken(null)
    stopFleet()
    set({ accessToken: null, profile: null, branchId: null })
  },
}))
