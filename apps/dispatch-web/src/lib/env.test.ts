import { describe, expect, it } from 'vitest'
import { apiOriginFrom } from '@/lib/env'

describe('apiOriginFrom', () => {
  it('uses the API host so generated /api/v1 paths are not doubled', () => {
    expect(apiOriginFrom('http://localhost:3000/api/v1')).toBe('http://localhost:3000')
  })
})
