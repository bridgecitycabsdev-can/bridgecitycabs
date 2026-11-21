import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, fireEvent } from '@testing-library/react'
import { MemoryRouter } from 'react-router-dom'
import { LedgerPage } from './ledger-page'
import * as exportCsvModule from '@/lib/export-csv'
import { toast } from '@/components/ui/toast'

describe('LedgerPage', () => {
  beforeEach(() => {
    vi.restoreAllMocks()
  })

  it('renders transactions table and pagination', () => {
    render(
      <MemoryRouter>
        <LedgerPage />
      </MemoryRouter>
    )

    expect(screen.getByText('General Ledger')).toBeTruthy()
    expect(screen.getByText('DOUBLE-ENTRY V3.4')).toBeTruthy()
    expect(screen.getByText('TXN-2026-98124')).toBeTruthy()
    expect(screen.getByText(/Showing 1/i)).toBeTruthy()
  })

  it('filters entries when search query is entered', () => {
    render(
      <MemoryRouter>
        <LedgerPage />
      </MemoryRouter>
    )

    const searchInput = screen.getByPlaceholderText(/Search transaction ID/i)
    fireEvent.change(searchInput, { target: { value: 'LSE-01' } })

    expect(screen.getByText('TXN-2026-98041')).toBeTruthy()
    expect(screen.queryByText('TXN-2026-98124')).toBeNull()
  })

  it('calls exportToCsv when Export CSV is clicked', () => {
    const exportSpy = vi.spyOn(exportCsvModule, 'exportToCsv').mockImplementation(() => {})

    render(
      <MemoryRouter>
        <LedgerPage />
      </MemoryRouter>
    )

    const exportBtn = screen.getByRole('button', { name: /Export CSV/i })
    fireEvent.click(exportBtn)

    expect(exportSpy).toHaveBeenCalledTimes(1)
    expect(exportSpy.mock.calls[0][1]).toBe('ledger-transactions-driver')
  })

  it('executes a reversal workflow in Frame 3 with toast notification', () => {
    const toastSpy = vi.spyOn(toast, 'success')

    render(
      <MemoryRouter>
        <LedgerPage />
      </MemoryRouter>
    )

    // Switch to Frame 3
    const frame3Btn = screen.getByRole('button', { name: /Frame 3: Reverse Transaction/i })
    fireEvent.click(frame3Btn)

    expect(screen.getByText(/Reverse this transaction\?/i)).toBeTruthy()

    // Click reverse transaction button using exact name
    const reverseBtn = screen.getByRole('button', { name: /^Reverse transaction$/i })
    fireEvent.click(reverseBtn)

    expect(toastSpy).toHaveBeenCalledWith(expect.stringContaining('reversed via TXN-2026-'))
  })
})
