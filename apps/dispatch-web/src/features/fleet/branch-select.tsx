import { useQuery } from '@tanstack/react-query'
import { useEffect } from 'react'
import { z } from 'zod'
import { useSession } from '@/app/session'
import { api, jsonBody } from '@/lib/api'

const branchesSchema = z.array(
  z.object({
    id: z.string(),
    name: z.string(),
    city: z.string(),
    active: z.boolean(),
  }),
)

export function BranchSelect() {
  const role = useSession((state) => state.profile?.role.name)
  const branchId = useSession((state) => state.branchId)
  const setBranchId = useSession((state) => state.setBranchId)
  const query = useQuery({
    queryKey: ['branches'],
    enabled: role === 'super_admin',
    queryFn: async () => {
      const result = await api.GET('/api/v1/branches')
      if (!result.response.ok) throw new Error('Could not load branches')
      return branchesSchema.parse(await jsonBody(result))
    },
  })

  const branches = (query.data ?? []).filter((branch) => branch.active)

  useEffect(() => {
    if (role !== 'super_admin' || branchId) return
    const first = query.data?.find((branch) => branch.active)
    if (first) setBranchId(first.id)
  }, [branchId, query.data, role, setBranchId])

  if (role !== 'super_admin') return null

  return (
    <label className="flex items-center gap-2 text-sm">
      <span className="text-muted-foreground">Branch</span>
      <select
        className="border-input bg-background h-9 rounded-md border px-2"
        value={branchId ?? ''}
        onChange={(event) => setBranchId(event.target.value)}
      >
        {branches.map((branch) => (
          <option key={branch.id} value={branch.id}>
            {branch.name}
          </option>
        ))}
      </select>
      {query.isError ? <span className="text-destructive text-xs">Could not load branches.</span> : null}
    </label>
  )
}
