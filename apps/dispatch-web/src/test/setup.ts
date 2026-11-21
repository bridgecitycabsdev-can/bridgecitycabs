import { cleanup } from '@testing-library/react'
import { afterAll, afterEach } from 'vitest'
import { server } from '@/test/server'

if (typeof window !== 'undefined') {
  if (!window.URL.createObjectURL) {
    window.URL.createObjectURL = () => 'blob:mock-url'
  } else {
    const originalCreate = window.URL.createObjectURL
    window.URL.createObjectURL = (blob: any) => {
      try {
        return originalCreate(blob)
      } catch {
        return 'blob:mock-url'
      }
    }
  }
  if (!window.URL.revokeObjectURL) {
    window.URL.revokeObjectURL = () => {}
  }
}

server.listen()

afterEach(() => {
  cleanup()
  server.resetHandlers()
})
afterAll(() => server.close())
