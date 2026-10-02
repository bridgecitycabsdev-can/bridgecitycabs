import { cleanup } from '@testing-library/react'
import { afterAll, afterEach } from 'vitest'
import { server } from '@/test/server'

server.listen()

afterEach(() => {
  cleanup()
  server.resetHandlers()
})
afterAll(() => server.close())
