import { toast } from '@/components/ui/toast'

export interface ExportCsvColumn<T = any> {
  header: string
  accessor: keyof T | ((row: T) => string | number | boolean | null | undefined)
}

export interface ExportCsvOptions<T = any> {
  filename: string
  data: T[]
  columns?: ExportCsvColumn<T>[]
  headers?: string[]
}

export function exportToCsv(
  optionsOrFilenameOrData: ExportCsvOptions | string | Record<string, any>[],
  headersOrFilename?: string[] | string,
  rowsInput?: (string | number | boolean | null | undefined)[][],
) {
  try {
    let filename = 'export'
    let headers: string[] = []
    let rows: (string | number | boolean | null | undefined)[][] = []

    if (Array.isArray(optionsOrFilenameOrData)) {
      filename = typeof headersOrFilename === 'string' ? headersOrFilename : 'export'
      if (optionsOrFilenameOrData.length > 0) {
        headers = Object.keys(optionsOrFilenameOrData[0])
        rows = optionsOrFilenameOrData.map((item) =>
          headers.map((key) => item[key]),
        )
      }
    } else if (typeof optionsOrFilenameOrData === 'object' && optionsOrFilenameOrData !== null) {
      const opts = optionsOrFilenameOrData as ExportCsvOptions
      filename = opts.filename || 'export'
      if (opts.columns && opts.columns.length > 0) {
        headers = opts.columns.map((c) => c.header)
        rows = (opts.data || []).map((item) =>
          opts.columns!.map((c) =>
            typeof c.accessor === 'function' ? c.accessor(item) : (item as any)[c.accessor],
          ),
        )
      } else if (opts.headers && opts.headers.length > 0) {
        headers = opts.headers
        rows = (opts.data || []).map((item) =>
          headers.map((h) => (item as any)[h]),
        )
      } else if (opts.data && opts.data.length > 0) {
        headers = Object.keys(opts.data[0])
        rows = opts.data.map((item) => headers.map((h) => (item as any)[h]))
      }
    } else {
      filename = optionsOrFilenameOrData
      headers = Array.isArray(headersOrFilename) ? headersOrFilename : []
      rows = rowsInput || []
    }

    const formatCell = (val: string | number | boolean | null | undefined) => {
      if (val === null || val === undefined) return '""'
      const str = String(val).replace(/"/g, '""')
      return `"${str}"`
    }

    const headerLine = headers.map(formatCell).join(',')
    const dataLines = rows.map((r) => r.map(formatCell).join(','))
    const csvContent = '\uFEFF' + [headerLine, ...dataLines].join('\r\n')

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.setAttribute('download', filename.endsWith('.csv') ? filename : `${filename}.csv`)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    URL.revokeObjectURL(url)

    toast.success('Export Successful', `Downloaded ${filename} (${rows.length} rows)`)
  } catch (err) {
    toast.error('Export Failed', 'An error occurred while generating the CSV file.')
    console.error('CSV Export Error:', err)
  }
}
