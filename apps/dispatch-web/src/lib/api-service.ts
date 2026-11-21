import { getAccessToken } from '@/app/session'
import { env } from '@/lib/env'

async function request<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
  const token = getAccessToken()
  const headers = new Headers(options.headers || {})
  headers.set('X-Client', 'web')
  if (token) headers.set('Authorization', `Bearer ${token}`)
  if (options.body && !(options.body instanceof FormData) && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json')
  }

  const url = `${env.apiOrigin}/api/v1${endpoint.startsWith('/') ? endpoint : `/${endpoint}`}`
  const res = await fetch(url, {
    credentials: 'include',
    ...options,
    headers,
  })

  if (!res.ok) {
    const errorBody = await res.json().catch(() => null)
    throw new Error(errorBody?.message || `Request to ${endpoint} failed with status ${res.status}`)
  }

  return res.json() as Promise<T>
}

export const apiService = {
  // Corporate Accounts
  corporate: {
    list: (query?: Record<string, string>) => {
      const q = query ? '?' + new URLSearchParams(query).toString() : ''
      return request<any[]>(`/corporate-accounts${q}`)
    },
    create: (data: Record<string, any>) =>
      request<any>('/corporate-accounts', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    update: (id: string, data: Record<string, any>) =>
      request<any>(`/corporate-accounts/${id}`, {
        method: 'PATCH',
        body: JSON.stringify(data),
      }),
  },

  // Municipal Branches
  branches: {
    list: () => request<any[]>('/branches'),
    create: (data: Record<string, any>) =>
      request<any>('/branches', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    update: (id: string, data: Record<string, any>) =>
      request<any>(`/branches/${id}`, {
        method: 'PATCH',
        body: JSON.stringify(data),
      }),
    deactivate: (id: string) =>
      request<any>(`/branches/${id}/deactivate`, {
        method: 'PATCH',
      }),
  },

  // Drivers
  drivers: {
    list: (query?: Record<string, string>) => {
      const q = query ? '?' + new URLSearchParams(query).toString() : ''
      return request<any[]>(`/drivers${q}`)
    },
    updateProfile: (id: string, data: Record<string, any>) =>
      request<any>(`/drivers/${id}`, {
        method: 'PATCH',
        body: JSON.stringify(data),
      }),
  },

  // Passengers
  passengers: {
    list: (query?: Record<string, string>) => {
      const q = query ? '?' + new URLSearchParams(query).toString() : ''
      return request<any[]>(`/passengers${q}`)
    },
    block: (id: string) =>
      request<any>(`/passengers/${id}/block`, {
        method: 'POST',
      }),
    update: (id: string, data: Record<string, any>) =>
      request<any>(`/passengers/${id}`, {
        method: 'PATCH',
        body: JSON.stringify(data),
      }),
  },

  // Vehicles
  vehicles: {
    list: (query?: Record<string, string>) => {
      const q = query ? '?' + new URLSearchParams(query).toString() : ''
      return request<any[]>(`/vehicles${q}`)
    },
    create: (data: Record<string, any>) =>
      request<any>('/vehicles', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    deactivate: (id: string) =>
      request<any>(`/vehicles/${id}/deactivate`, {
        method: 'POST',
      }),
  },

  // Vehicle Leases
  leases: {
    list: () => request<any[]>('/lease-agreements'),
    create: (data: Record<string, any>) =>
      request<any>('/lease-agreements', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
  },

  // Payouts
  payouts: {
    list: () => request<any[]>('/finance/payouts'),
    run: (data?: Record<string, any>) =>
      request<any>('/finance/payouts/run', {
        method: 'POST',
        body: JSON.stringify(data || {}),
      }),
    markSent: (id: string) =>
      request<any>(`/finance/payouts/${id}/mark-sent`, {
        method: 'POST',
      }),
    markFailed: (id: string, reason?: string) =>
      request<any>(`/finance/payouts/${id}/mark-failed`, {
        method: 'POST',
        body: JSON.stringify({ reason: reason || 'Bank Gateway Rejection' }),
      }),
  },

  // Reports
  reports: {
    generate: (params: Record<string, string>) => {
      const q = '?' + new URLSearchParams(params).toString()
      return request<any>(`/reports/booking-report${q}`)
    },
    files: () => request<any[]>('/reports/files'),
  },

  // Audit Logs
  audit: {
    list: (query?: Record<string, string>) => {
      const q = query ? '?' + new URLSearchParams(query).toString() : ''
      return request<any[]>(`/audit-logs${q}`)
    },
  },

  // Users & Staff
  users: {
    updateRole: (id: string, role: string) =>
      request<any>(`/users/${id}/role`, {
        method: 'PATCH',
        body: JSON.stringify({ role }),
      }),
  },

  // Support Tickets
  support: {
    list: () => request<any[]>('/support/tickets'),
    create: (data: Record<string, any>) =>
      request<any>('/support/tickets', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    reply: (id: string, body: string) =>
      request<any>(`/support/tickets/${id}/messages`, {
        method: 'POST',
        body: JSON.stringify({ body }),
      }),
  },

  // Fare Rules
  fareRules: {
    list: (query?: Record<string, string>) => {
      const q = query ? '?' + new URLSearchParams(query).toString() : ''
      return request<any[]>(`/fare-rules${q}`)
    },
    create: (data: Record<string, any>) =>
      request<any>('/fare-rules', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    update: (id: string, data: Record<string, any>) =>
      request<any>(`/fare-rules/${id}`, {
        method: 'PATCH',
        body: JSON.stringify(data),
      }),
    remove: (id: string) =>
      request<any>(`/fare-rules/${id}`, {
        method: 'DELETE',
      }),
  },

  // Promo Codes
  promos: {
    list: (query?: Record<string, string>) => {
      const q = query ? '?' + new URLSearchParams(query).toString() : ''
      return request<any[]>(`/promo-codes${q}`)
    },
    create: (data: Record<string, any>) =>
      request<any>('/promo-codes', {
        method: 'POST',
        body: JSON.stringify(data),
      }),
    update: (id: string, data: Record<string, any>) =>
      request<any>(`/promo-codes/${id}`, {
        method: 'PATCH',
        body: JSON.stringify(data),
      }),
  },
}
