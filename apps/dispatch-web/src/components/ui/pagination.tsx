export interface TablePaginationProps {
  currentPage: number
  totalPages: number
  onPageChange: (page: number) => void
  showingStart?: number
  showingEnd?: number
  totalCount?: number
  totalItems?: number
  pageSize?: number
  entityName?: string
  ledgerCode?: string
  className?: string
}

export function TablePagination({
  currentPage,
  totalPages,
  onPageChange,
  showingStart,
  showingEnd,
  totalCount,
  totalItems,
  pageSize = 10,
  entityName = 'entries',
  ledgerCode,
  className = '',
}: TablePaginationProps) {
  const actualTotal = totalCount ?? totalItems ?? 0
  if (actualTotal === 0) return null

  const safeCurrentPage = Math.min(Math.max(1, currentPage), Math.max(1, totalPages))
  const pageNumbers: number[] = []

  const actualStart = showingStart ?? (actualTotal > 0 ? (safeCurrentPage - 1) * pageSize + 1 : 0)
  const actualEnd = showingEnd ?? Math.min(safeCurrentPage * pageSize, actualTotal)

  // Generate sensible window of page numbers
  const maxButtons = 5
  let startPage = Math.max(1, safeCurrentPage - Math.floor(maxButtons / 2))
  let endPage = startPage + maxButtons - 1
  if (endPage > totalPages) {
    endPage = totalPages
    startPage = Math.max(1, endPage - maxButtons + 1)
  }

  for (let p = startPage; p <= endPage; p++) {
    pageNumbers.push(p)
  }

  return (
    <div className={`flex flex-wrap items-center justify-between border-t border-neutral-200 bg-[#F9FAFB] px-4 py-3 text-xs text-neutral-500 ${className}`}>
      <div className="flex items-center gap-2">
        <span>
          Showing {actualStart}–{actualEnd} of {actualTotal} {entityName}
        </span>
        {ledgerCode && (
          <>
            <span>•</span>
            <span className="font-mono text-[10px] text-neutral-400">{ledgerCode}</span>
          </>
        )}
      </div>

      <div className="flex items-center gap-1">
        <button
          type="button"
          disabled={safeCurrentPage <= 1}
          onClick={() => onPageChange(safeCurrentPage - 1)}
          className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-100 disabled:opacity-40 disabled:cursor-not-allowed text-xs cursor-pointer"
          title="Previous page"
        >
          &lt;
        </button>

        {startPage > 1 && (
          <>
            <button
              type="button"
              onClick={() => onPageChange(1)}
              className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100 text-xs cursor-pointer"
            >
              1
            </button>
            {startPage > 2 && <span className="px-1 text-neutral-400">…</span>}
          </>
        )}

        {pageNumbers.map((p) => (
          <button
            key={p}
            type="button"
            onClick={() => onPageChange(p)}
            className={`flex size-7 items-center justify-center rounded text-xs cursor-pointer ${
              p === safeCurrentPage
                ? 'bg-[#C4161C] text-white font-bold shadow-2xs'
                : 'border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100'
            }`}
          >
            {p}
          </button>
        ))}

        {endPage < totalPages && (
          <>
            {endPage < totalPages - 1 && <span className="px-1 text-neutral-400">…</span>}
            <button
              type="button"
              onClick={() => onPageChange(totalPages)}
              className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100 text-xs cursor-pointer"
            >
              {totalPages}
            </button>
          </>
        )}

        <button
          type="button"
          disabled={safeCurrentPage >= totalPages}
          onClick={() => onPageChange(safeCurrentPage + 1)}
          className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-100 disabled:opacity-40 disabled:cursor-not-allowed text-xs cursor-pointer"
          title="Next page"
        >
          &gt;
        </button>
      </div>
    </div>
  )
}
