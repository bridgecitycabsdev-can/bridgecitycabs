import {
  useTable,
  type OnChangeFn,
  type PaginationState,
} from '@tanstack/react-table'
import { Button } from '@/components/ui/button'
import type { JobRow } from '@/features/bookings/jobs-table'
import { jobsColumnHelper, jobsTableFeatures } from '@/features/bookings/jobs-table-setup'

type JobsColumns = ReturnType<typeof jobsColumnHelper.columns>

type Props = {
  data: JobRow[]
  columns: JobsColumns
  pagination: PaginationState
  onPaginationChange: OnChangeFn<PaginationState>
  pageCount: number
  total: number
  isPending?: boolean
  isError?: boolean
  emptyMessage?: string
}

export function JobsTable({
  data,
  columns,
  pagination,
  onPaginationChange,
  pageCount,
  total,
  isPending,
  isError,
  emptyMessage = 'No jobs on this page.',
}: Props) {
  const table = useTable({
    features: jobsTableFeatures,
    data,
    columns,
    state: { pagination },
    onPaginationChange,
    manualPagination: true,
    pageCount,
  })

  return (
    <div className="flex min-h-0 flex-1 flex-col gap-2">
      <div className="min-h-0 flex-1 overflow-auto rounded-md border">
        <table className="w-full min-w-[56rem] border-collapse text-left text-xs">
          <thead className="bg-muted/50 sticky top-0 z-10">
            {table.getHeaderGroups().map((group) => (
              <tr key={group.id}>
                {group.headers.map((header) => (
                  <th key={header.id} className="border-b px-2 py-1.5 font-medium whitespace-nowrap">
                    {header.isPlaceholder ? null : <table.FlexRender header={header} />}
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody>
            {table.getRowModel().rows.map((row) => (
              <tr key={row.id} className="border-b last:border-0 hover:bg-muted/30">
                {row.getAllCells().map((cell) => (
                  <td key={cell.id} className="max-w-[14rem] truncate px-2 py-1.5 align-top">
                    <table.FlexRender cell={cell} />
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
        {isPending ? (
          <p className="text-muted-foreground px-2 py-3 text-sm">Loading jobs…</p>
        ) : null}
        {isError ? <p className="text-destructive px-2 py-3 text-sm">Could not load jobs.</p> : null}
        {!isPending && !isError && data.length === 0 ? (
          <p className="text-muted-foreground px-2 py-3 text-sm">{emptyMessage}</p>
        ) : null}
      </div>
      <div className="flex flex-wrap items-center justify-between gap-2 text-xs">
        <p className="text-muted-foreground">
          {total} job{total === 1 ? '' : 's'}
          {pageCount > 0 ? ` · page ${pagination.pageIndex + 1} of ${pageCount}` : ''}
        </p>
        <div className="flex items-center gap-1.5">
          <Button
            type="button"
            size="xs"
            variant="outline"
            disabled={!table.getCanPreviousPage()}
            onClick={() => table.previousPage()}
          >
            Prev
          </Button>
          <Button
            type="button"
            size="xs"
            variant="outline"
            disabled={!table.getCanNextPage()}
            onClick={() => table.nextPage()}
          >
            Next
          </Button>
        </div>
      </div>
    </div>
  )
}

/** Render user-supplied text safely (never HTML). */
export function PlainText({ value }: { value: string | null | undefined }) {
  return <span>{value?.trim() ? value : '—'}</span>
}
