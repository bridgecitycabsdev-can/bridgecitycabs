import { zodResolver } from '@hookform/resolvers/zod'
import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { Navigate } from 'react-router-dom'
import { z } from 'zod'
import { useSession } from '@/app/session'
import { Button } from '@/components/ui/button'
import { login } from '@/features/auth/session'

const INVALID_CREDENTIALS = 'Invalid credentials'

const loginSchema = z.object({
  email: z.email(),
  password: z.string().min(1),
})

type LoginValues = z.infer<typeof loginSchema>

export function LoginPage() {
  const accessToken = useSession((state) => state.accessToken)
  const [error, setError] = useState<string | null>(null)
  const form = useForm<LoginValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: '', password: '' },
  })

  if (accessToken) return <Navigate to="/dispatch" replace />

  return (
    <main className="grid h-full place-items-center px-4">
      <form
        className="bg-card w-full max-w-sm space-y-4 rounded-lg border p-6 shadow-sm"
        onSubmit={form.handleSubmit(
          async (values) => {
            setError(null)
            const ok = await login(values.email, values.password)
            if (!ok) setError(INVALID_CREDENTIALS)
          },
          () => setError(INVALID_CREDENTIALS),
        )}
      >
        <div>
          <h1 className="text-xl font-semibold">Dispatch</h1>
          <p className="text-muted-foreground text-sm">Sign in to the live board.</p>
        </div>
        <label className="block space-y-1 text-sm">
          <span>Email</span>
          <input
            className="border-input bg-background h-9 w-full rounded-md border px-3"
            type="email"
            autoComplete="username"
            {...form.register('email')}
          />
        </label>
        <label className="block space-y-1 text-sm">
          <span>Password</span>
          <input
            className="border-input bg-background h-9 w-full rounded-md border px-3"
            type="password"
            autoComplete="current-password"
            {...form.register('password')}
          />
        </label>
        {error ? <p className="text-destructive text-sm">{error}</p> : null}
        <Button type="submit" disabled={form.formState.isSubmitting} className="w-full">
          Sign in
        </Button>
      </form>
    </main>
  )
}
