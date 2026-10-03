import { getAccessToken } from '@/app/session'
import { env } from '@/lib/env'

function authHeaders() {
  const token = getAccessToken()
  const headers = new Headers({
    Accept: 'application/json',
    'Content-Type': 'application/json',
    'X-Client': 'web',
  })
  if (token) headers.set('Authorization', `Bearer ${token}`)
  return headers
}

/** Staff cash confirmation — not yet in the generated OpenAPI client. */
export async function confirmCashPayment(bookingId: string) {
  const response = await fetch(
    `${env.apiOrigin}/api/v1/bookings/${bookingId}/payment/cash`,
    { method: 'POST', credentials: 'include', headers: authHeaders(), body: '{}' },
  )
  return response.ok
}

/** Staff fare adjustment while still PAYMENT_PENDING. */
export async function adjustBookingFare(
  bookingId: string,
  body: { subtotalCents: number; reason: string },
) {
  const response = await fetch(
    `${env.apiOrigin}/api/v1/bookings/${bookingId}/adjust-fare`,
    {
      method: 'POST',
      credentials: 'include',
      headers: authHeaders(),
      body: JSON.stringify(body),
    },
  )
  return response.ok
}

export function paymentStatusLabel(status: string | undefined) {
  switch (status) {
    case 'PAID':
      return 'Paid'
    case 'UNPAID':
      return 'Unpaid'
    case 'PARTIALLY_REFUNDED':
      return 'Partially refunded'
    case 'REFUNDED':
      return 'Refunded'
    default:
      return status || '—'
  }
}
