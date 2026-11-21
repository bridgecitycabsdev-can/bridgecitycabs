import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { useState, type ReactNode } from 'react'
import { ToastContainer } from '@/components/ui/toast'
import { SessionBootstrap } from '@/features/auth/session-bootstrap'

export function AppProviders({ children }: { children: ReactNode }) {
  const [client] = useState(
    () =>
      new QueryClient({
        defaultOptions: {
          queries: { retry: false, refetchOnWindowFocus: false },
        },
      }),
  )

  return (
    <QueryClientProvider client={client}>
      <SessionBootstrap>
        {children}
        <ToastContainer />
      </SessionBootstrap>
    </QueryClientProvider>
  )
}
