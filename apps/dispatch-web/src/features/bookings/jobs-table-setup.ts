import {
  createColumnHelper,
  rowPaginationFeature,
  tableFeatures,
} from '@tanstack/react-table'
import type { JobRow } from '@/features/bookings/jobs-table'

/** Shared features for server-paginated booking tables. */
export const jobsTableFeatures = tableFeatures({
  rowPaginationFeature,
})

export const jobsColumnHelper = createColumnHelper<typeof jobsTableFeatures, JobRow>()
