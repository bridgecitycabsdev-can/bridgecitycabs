import { Button } from '@/components/ui/button'
import { logout } from '@/features/auth/session'

export function NoAccessPage() {
  return (
    <main className="grid h-full place-items-center px-4">
      <div className="bg-card w-full max-w-sm space-y-4 rounded-lg border p-6 shadow-sm">
        <div>
          <h1 className="text-xl font-semibold">No access</h1>
          <p className="text-muted-foreground text-sm">
            This account cannot open the dispatch board. Dispatch is limited to super admins, branch
            admins, dispatchers, and customer care.
          </p>
        </div>
        <Button variant="outline" className="w-full" onClick={() => void logout()}>
          Sign out
        </Button>
      </div>
    </main>
  )
}
