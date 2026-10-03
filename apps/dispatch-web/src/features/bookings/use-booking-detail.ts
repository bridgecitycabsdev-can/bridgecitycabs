import { useQuery } from '@tanstack/react-query'
import { bookingDetailSchema } from '@/features/bookings/booking-detail'
import { api, jsonBody } from '@/lib/api'

export function useBookingDetail(id: string | null) {
  return useQuery({
    queryKey: ['booking', id],
    enabled: Boolean(id),
    queryFn: async () => {
      const result = await api.GET('/api/v1/bookings/{id}', {
        params: { path: { id: id! } },
      })
      if (!result.response.ok) throw new Error('Could not load booking')
      return bookingDetailSchema.parse(await jsonBody(result))
    },
  })
}
