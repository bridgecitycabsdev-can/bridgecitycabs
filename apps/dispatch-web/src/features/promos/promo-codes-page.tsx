import {
  AlertCircle,
  ChevronDown,
  Download,
  MapPin,
  Pencil,
  Percent,
  Plus,
  RefreshCw,
  Search,
  Trash2,
  X,
} from 'lucide-react'
import { useState } from 'react'
import { AdminSidebar } from '@/components/AdminSidebar'
import { toast } from '@/components/ui/toast'

export interface PromoCode {
  id: string
  code: string
  description: string
  type: 'PERCENT' | 'FIXED'
  value: number // percent e.g. 15 or cents e.g. 500 ($5.00)
  maxDiscountCents?: number
  minSubtotalCents?: number
  usageCount: number
  usageLimitTotal?: number
  startAt: string
  endAt: string
  active: boolean
}

const DEFAULT_PROMO_CODES: PromoCode[] = [
  {
    id: 'pr-001',
    code: 'LETHBRIDGE15',
    description: '15% off first 3 rides across Lethbridge municipality',
    type: 'PERCENT',
    value: 15,
    maxDiscountCents: 1000,
    minSubtotalCents: 1200,
    usageCount: 428,
    usageLimitTotal: 1000,
    startAt: '01 Nov 2026',
    endAt: '31 Dec 2026',
    active: true,
  },
  {
    id: 'pr-002',
    code: 'CAMPUS5',
    description: '$5.00 flat discount for Univ of Lethbridge students',
    type: 'FIXED',
    value: 500,
    maxDiscountCents: 500,
    minSubtotalCents: 1500,
    usageCount: 892,
    usageLimitTotal: 2500,
    startAt: '01 Sep 2026',
    endAt: '30 Apr 2027',
    active: true,
  },
  {
    id: 'pr-003',
    code: 'AIRPORT10',
    description: '$10.00 off YQL Airport fixed corridor transfers',
    type: 'FIXED',
    value: 1000,
    maxDiscountCents: 1000,
    minSubtotalCents: 2500,
    usageCount: 164,
    usageLimitTotal: 500,
    startAt: '15 Oct 2026',
    endAt: '15 Jan 2027',
    active: true,
  },
  {
    id: 'pr-004',
    code: 'SENIORS20',
    description: '20% off all midday rides for registered seniors',
    type: 'PERCENT',
    value: 20,
    maxDiscountCents: 1500,
    minSubtotalCents: 800,
    usageCount: 312,
    usageLimitTotal: 1000,
    startAt: '01 Jan 2026',
    endAt: '31 Dec 2026',
    active: true,
  },
  {
    id: 'pr-005',
    code: 'HALLOWEEN26',
    description: '$6.00 off safe ride home during Halloween weekend',
    type: 'FIXED',
    value: 600,
    maxDiscountCents: 600,
    minSubtotalCents: 1000,
    usageCount: 500,
    usageLimitTotal: 500,
    startAt: '30 Oct 2026',
    endAt: '02 Nov 2026',
    active: false,
  },
  {
    id: 'pr-006',
    code: 'COULEE25',
    description: '25% off downtown to West Lethbridge cross-coulee trips',
    type: 'PERCENT',
    value: 25,
    maxDiscountCents: 1200,
    minSubtotalCents: 1500,
    usageCount: 94,
    usageLimitTotal: 400,
    startAt: '10 Nov 2026',
    endAt: '30 Nov 2026',
    active: true,
  },
  {
    id: 'pr-007',
    code: 'ROTARYFEST',
    description: '$4.00 off transit to Rotary Park community events',
    type: 'FIXED',
    value: 400,
    maxDiscountCents: 400,
    minSubtotalCents: 1000,
    usageCount: 180,
    usageLimitTotal: 200,
    startAt: '12 Oct 2026',
    endAt: '16 Oct 2026',
    active: false,
  },
]

export function PromoCodesPage() {
  const [promos, setPromos] = useState<PromoCode[]>(DEFAULT_PROMO_CODES)
  const [searchQuery, setSearchQuery] = useState('')
  const [typeFilter, setTypeFilter] = useState('ALL')
  const [statusFilter, setStatusFilter] = useState('ALL')
  const [currentPage, setCurrentPage] = useState(1)
  const pageSize = 5

  // Modal form state
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [editingPromoId, setEditingPromoId] = useState<string | null>(null)
  const [formData, setFormData] = useState({
    code: '',
    description: '',
    type: 'PERCENT' as PromoCode['type'],
    value: '15',
    maxDiscount: '10.00',
    minSubtotal: '12.00',
    usageLimit: '500',
    startAt: '2026-11-20',
    endAt: '2026-12-31',
    active: true,
  })

  // Filter calculation
  const filteredPromos = promos.filter((p) => {
    if (typeFilter !== 'ALL' && p.type !== typeFilter) return false
    if (statusFilter === 'ACTIVE' && !p.active) return false
    if (statusFilter === 'INACTIVE' && p.active) return false

    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      return (
        p.code.toLowerCase().includes(q) ||
        p.description.toLowerCase().includes(q)
      )
    }
    return true
  })

  const totalPages = Math.max(1, Math.ceil(filteredPromos.length / pageSize))
  const safeCurrentPage = Math.min(currentPage, totalPages)
  const pagedPromos = filteredPromos.slice(
    (safeCurrentPage - 1) * pageSize,
    safeCurrentPage * pageSize,
  )

  const activeCount = promos.filter((p) => p.active).length
  const totalRedemptions = promos.reduce((sum, p) => sum + p.usageCount, 0)

  // Handlers
  const handleOpenCreate = () => {
    setEditingPromoId(null)
    setFormData({
      code: '',
      description: '',
      type: 'PERCENT',
      value: '15',
      maxDiscount: '10.00',
      minSubtotal: '12.00',
      usageLimit: '500',
      startAt: new Date().toISOString().slice(0, 10),
      endAt: '2026-12-31',
      active: true,
    })
    setIsModalOpen(true)
  }

  const handleOpenEdit = (promo: PromoCode) => {
    setEditingPromoId(promo.id)
    setFormData({
      code: promo.code,
      description: promo.description,
      type: promo.type,
      value: promo.type === 'PERCENT' ? promo.value.toString() : (promo.value / 100).toFixed(2),
      maxDiscount: promo.maxDiscountCents ? (promo.maxDiscountCents / 100).toFixed(2) : '',
      minSubtotal: promo.minSubtotalCents ? (promo.minSubtotalCents / 100).toFixed(2) : '',
      usageLimit: promo.usageLimitTotal?.toString() || '',
      startAt: promo.startAt,
      endAt: promo.endAt,
      active: promo.active,
    })
    setIsModalOpen(true)
  }

  const handleSavePromo = (e: React.FormEvent) => {
    e.preventDefault()
    if (!formData.code.trim()) {
      toast.error('Validation Error', 'Please enter a promo code string.')
      return
    }

    const val =
      formData.type === 'PERCENT'
        ? parseInt(formData.value || '0', 10)
        : Math.round(parseFloat(formData.value || '0') * 100)

    const maxDisc = formData.maxDiscount
      ? Math.round(parseFloat(formData.maxDiscount) * 100)
      : undefined
    const minSub = formData.minSubtotal
      ? Math.round(parseFloat(formData.minSubtotal) * 100)
      : undefined
    const limit = formData.usageLimit ? parseInt(formData.usageLimit, 10) : undefined

    if (editingPromoId) {
      setPromos((prev) =>
        prev.map((p) =>
          p.id === editingPromoId
            ? {
                ...p,
                code: formData.code.toUpperCase().trim(),
                description: formData.description,
                type: formData.type,
                value: val,
                maxDiscountCents: maxDisc,
                minSubtotalCents: minSub,
                usageLimitTotal: limit,
                startAt: formData.startAt,
                endAt: formData.endAt,
                active: formData.active,
              }
            : p,
        ),
      )
      toast.success('Promo Code Updated', `Promo code "${formData.code}" was updated.`)
    } else {
      const newPromo: PromoCode = {
        id: `pr-${Date.now()}`,
        code: formData.code.toUpperCase().trim(),
        description: formData.description || 'Promotional rider discount voucher',
        type: formData.type,
        value: val,
        maxDiscountCents: maxDisc,
        minSubtotalCents: minSub,
        usageCount: 0,
        usageLimitTotal: limit,
        startAt: formData.startAt,
        endAt: formData.endAt,
        active: formData.active,
      }
      setPromos((prev) => [newPromo, ...prev])
      toast.success('Promo Code Created', `Promo "${newPromo.code}" is ready for redemption.`)
    }

    setIsModalOpen(false)
  }

  const handleToggleActive = (id: string, e: React.MouseEvent) => {
    e.stopPropagation()
    setPromos((prev) =>
      prev.map((p) => {
        if (p.id === id) {
          const nextState = !p.active
          toast.info(
            nextState ? 'Code Activated' : 'Code Deactivated',
            `Promo ${p.code} is now ${nextState ? 'active' : 'inactive'}.`,
          )
          return { ...p, active: nextState }
        }
        return p
      }),
    )
  }

  const handleDeletePromo = (id: string, code: string, e: React.MouseEvent) => {
    e.stopPropagation()
    if (confirm(`Are you sure you want to delete promo code "${code}"?`)) {
      setPromos((prev) => prev.filter((p) => p.id !== id))
      toast.error('Promo Deleted', `Promo code "${code}" was deleted.`)
    }
  }

  const handleExportCSV = () => {
    const headers = ['Code', 'Description', 'Type', 'Value', 'Usage Count', 'Usage Limit', 'Start Date', 'End Date', 'Status']
    const rows = filteredPromos.map((p) => [
      p.code,
      `"${p.description}"`,
      p.type,
      p.type === 'PERCENT' ? `${p.value}%` : `$${(p.value / 100).toFixed(2)}`,
      p.usageCount,
      p.usageLimitTotal || 'Unlimited',
      p.startAt,
      p.endAt,
      p.active ? 'ACTIVE' : 'INACTIVE',
    ])
    const csvContent = 'data:text/csv;charset=utf-8,' + [headers.join(','), ...rows.map((e) => e.join(','))].join('\n')
    const encodedUri = encodeURI(csvContent)
    const link = document.createElement('a')
    link.setAttribute('href', encodedUri)
    link.setAttribute('download', `promo-codes-${new Date().toISOString().slice(0, 10)}.csv`)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    toast.success('Export Complete', 'Promo codes exported to CSV.')
  }

  const handleResetFilters = () => {
    setSearchQuery('')
    setTypeFilter('ALL')
    setStatusFilter('ALL')
    setCurrentPage(1)
  }

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-[#F3F4F6] text-neutral-900 font-sans antialiased">
      <AdminSidebar activeSection="promo-codes" subtitle="Lethbridge Branch (YQL)" />

      <div className="flex flex-1 flex-col overflow-hidden">
        {/* Top Header Bar */}
        <header className="flex h-14 shrink-0 items-center justify-between border-b border-neutral-200/90 bg-white px-4 lg:px-6 shadow-xs z-20">
          <div className="flex items-center gap-2">
            <span className="text-xs text-neutral-400 font-medium">Pricing &gt;</span>
            <span className="text-xs font-bold text-neutral-800">Promo codes</span>
          </div>

          <div className="flex items-center gap-3">
            <div className="hidden sm:flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-neutral-50 px-3 py-1.5 text-xs font-medium text-neutral-700">
              <MapPin className="size-3.5 text-neutral-400" />
              <span>Lethbridge Branch (YQL)</span>
              <ChevronDown className="size-3 text-neutral-400 ml-1" />
            </div>

            <div className="flex items-center gap-1.5 rounded-full border border-emerald-200 bg-emerald-50 px-3 py-1 text-xs font-semibold text-emerald-800">
              <span className="size-2 rounded-full bg-emerald-500 animate-pulse" />
              <span>CAD SYNC LIVE</span>
            </div>
          </div>
        </header>

        {/* Content Body */}
        <main className="flex-1 overflow-y-auto p-4 lg:p-6 space-y-6">
          {/* Header Title & Actions */}
          <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
            <div>
              <div className="flex items-center gap-3">
                <h1 className="text-2xl font-black tracking-tight text-neutral-900">Promo codes</h1>
                <span className="rounded-full bg-neutral-200 px-2.5 py-0.5 text-xs font-bold text-neutral-700">
                  {promos.length} codes
                </span>
                <span className="rounded-full border border-emerald-200 bg-emerald-50 px-2.5 py-0.5 text-xs font-semibold text-emerald-700">
                  {activeCount} Active
                </span>
              </div>
              <p className="mt-1 text-xs text-neutral-500">
                Manage promotional rider campaigns, percentage vouchers, and municipal subsidy codes.
              </p>
            </div>

            <div className="flex items-center gap-2.5">
              <button
                type="button"
                onClick={handleExportCSV}
                className="flex items-center gap-1.5 rounded-lg border border-neutral-200 bg-white px-3.5 py-2 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 shadow-xs cursor-pointer"
              >
                <Download className="size-3.5" />
                <span>Export CSV</span>
              </button>

              <button
                type="button"
                onClick={handleOpenCreate}
                className="flex items-center gap-1.5 rounded-lg bg-[#C4161C] px-4 py-2 text-xs font-bold text-white hover:bg-[#9E1017] shadow-xs cursor-pointer"
              >
                <Plus className="size-4" />
                <span>+ New promo code</span>
              </button>
            </div>
          </div>

          {/* KPI Summary Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="rounded-xl border border-neutral-200/90 bg-white p-4 shadow-xs">
              <div className="flex items-center justify-between text-neutral-500 text-xs font-medium">
                <span>Active Campaign Codes</span>
                <Percent className="size-4 text-[#C4161C]" />
              </div>
              <div className="mt-2 text-2xl font-black text-neutral-900">{activeCount}</div>
              <div className="mt-1 text-[11px] text-neutral-400">Of {promos.length} total campaigns</div>
            </div>

            <div className="rounded-xl border border-neutral-200/90 bg-white p-4 shadow-xs">
              <div className="flex items-center justify-between text-neutral-500 text-xs font-medium">
                <span>Total Redemptions</span>
                <span className="text-xs font-bold text-emerald-600">All-time</span>
              </div>
              <div className="mt-2 text-2xl font-black text-neutral-900">{totalRedemptions.toLocaleString()}</div>
              <div className="mt-1 text-[11px] text-neutral-400">Rider trips with applied discount</div>
            </div>

            <div className="rounded-xl border border-neutral-200/90 bg-white p-4 shadow-xs">
              <div className="flex items-center justify-between text-neutral-500 text-xs font-medium">
                <span>Highest Used Voucher</span>
                <span className="text-xs font-bold text-blue-600">Student</span>
              </div>
              <div className="mt-2 text-lg font-black text-neutral-900">CAMPUS5</div>
              <div className="mt-1 text-[11px] text-neutral-400">892 successful passenger claims</div>
            </div>

            <div className="rounded-xl border border-neutral-200/90 bg-white p-4 shadow-xs">
              <div className="flex items-center justify-between text-neutral-500 text-xs font-medium">
                <span>Subsidy Liability</span>
                <span className="text-xs font-bold text-purple-600">Lethbridge</span>
              </div>
              <div className="mt-2 text-2xl font-black text-neutral-900">$8,420 <span className="text-xs font-semibold text-neutral-400">CAD</span></div>
              <div className="mt-1 text-[11px] text-neutral-400">Settled through municipal fund</div>
            </div>
          </div>

          {/* Search & Filter Bar */}
          <div className="flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between rounded-xl border border-neutral-200/90 bg-white p-3 shadow-xs">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-neutral-400" />
              <input
                type="text"
                placeholder="Search promo code or campaign description..."
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value)
                  setCurrentPage(1)
                }}
                className="w-full rounded-lg border border-neutral-200 bg-neutral-50/50 pl-9 pr-3 py-2 text-xs text-neutral-800 placeholder-neutral-400 focus:border-[#C4161C] focus:bg-white focus:outline-none"
              />
            </div>

            <div className="flex flex-wrap items-center gap-2 text-xs">
              {/* Type Filter */}
              <select
                aria-label="Filter by promo discount type"
                value={typeFilter}
                onChange={(e) => {
                  setTypeFilter(e.target.value)
                  setCurrentPage(1)
                }}
                className="rounded-lg border border-neutral-200 bg-white px-2.5 py-2 text-xs font-medium text-neutral-700 focus:border-[#C4161C] focus:outline-none"
              >
                <option value="ALL">All Discount Types</option>
                <option value="PERCENT">Percentage (%)</option>
                <option value="FIXED">Fixed Amount ($)</option>
              </select>

              {/* Status Filter */}
              <select
                aria-label="Filter by campaign status"
                value={statusFilter}
                onChange={(e) => {
                  setStatusFilter(e.target.value)
                  setCurrentPage(1)
                }}
                className="rounded-lg border border-neutral-200 bg-white px-2.5 py-2 text-xs font-medium text-neutral-700 focus:border-[#C4161C] focus:outline-none"
              >
                <option value="ALL">All Statuses</option>
                <option value="ACTIVE">Active Only</option>
                <option value="INACTIVE">Inactive / Expired</option>
              </select>

              {(searchQuery || typeFilter !== 'ALL' || statusFilter !== 'ALL') && (
                <button
                  type="button"
                  onClick={handleResetFilters}
                  className="flex items-center gap-1 rounded-lg border border-neutral-200 bg-neutral-100 px-2.5 py-2 text-xs font-semibold text-neutral-600 hover:bg-neutral-200 cursor-pointer"
                >
                  <RefreshCw className="size-3" />
                  <span>Reset</span>
                </button>
              )}
            </div>
          </div>

          {/* Promo Codes Data Table */}
          <div className="overflow-hidden rounded-2xl border border-neutral-200/90 bg-white shadow-xs">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse text-xs">
                <thead>
                  <tr className="border-b border-neutral-200 bg-[#F9FAFB] text-[10px] font-bold text-neutral-500 uppercase tracking-wider">
                    <th className="py-3 px-4">PROMO CODE</th>
                    <th className="py-3 px-4">CAMPAIGN DESCRIPTION</th>
                    <th className="py-3 px-3">DISCOUNT VALUE</th>
                    <th className="py-3 px-3">MAX DISCOUNT</th>
                    <th className="py-3 px-3">USAGE / LIMIT</th>
                    <th className="py-3 px-3">VALID DATES</th>
                    <th className="py-3 px-3 text-center">STATUS</th>
                    <th className="py-3 px-4 text-right">ACTIONS</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-neutral-100 font-medium">
                  {pagedPromos.length === 0 ? (
                    <tr>
                      <td colSpan={8} className="py-12 text-center text-neutral-400">
                        <AlertCircle className="mx-auto size-8 text-neutral-300 mb-2" />
                        <div>No promo codes matched your filters.</div>
                        <button
                          type="button"
                          onClick={handleResetFilters}
                          className="mt-2 text-xs text-[#C4161C] font-semibold hover:underline cursor-pointer"
                        >
                          Clear filters
                        </button>
                      </td>
                    </tr>
                  ) : (
                    pagedPromos.map((p) => {
                      const usagePercent = p.usageLimitTotal
                        ? Math.min(100, Math.round((p.usageCount / p.usageLimitTotal) * 100))
                        : 0

                      return (
                        <tr key={p.id} className="hover:bg-neutral-50/80 transition">
                          <td className="py-3.5 px-4 font-mono font-black text-neutral-900 text-sm">
                            <span className="rounded-md bg-neutral-100 px-2 py-1 border border-neutral-200/80">
                              {p.code}
                            </span>
                          </td>
                          <td className="py-3.5 px-4 text-neutral-700 max-w-xs">{p.description}</td>
                          <td className="py-3.5 px-3">
                            <span
                              className={`inline-block rounded-md px-2 py-0.5 text-xs font-black ${
                                p.type === 'PERCENT'
                                  ? 'bg-rose-50 text-rose-700 border border-rose-200'
                                  : 'bg-emerald-50 text-emerald-700 border border-emerald-200'
                              }`}
                            >
                              {p.type === 'PERCENT' ? `${p.value}% OFF` : `$${(p.value / 100).toFixed(2)} OFF`}
                            </span>
                          </td>
                          <td className="py-3.5 px-3 text-neutral-600 font-medium">
                            {p.maxDiscountCents ? `$${(p.maxDiscountCents / 100).toFixed(2)}` : 'None'}
                          </td>
                          <td className="py-3.5 px-3">
                            <div className="flex items-center gap-2">
                              <span className="font-bold text-neutral-900">{p.usageCount}</span>
                              <span className="text-neutral-400">/ {p.usageLimitTotal || '∞'}</span>
                            </div>
                            {p.usageLimitTotal && (
                              <div className="mt-1 h-1 w-20 overflow-hidden rounded-full bg-neutral-100">
                                <div
                                  className={`h-full ${usagePercent >= 90 ? 'bg-rose-500' : 'bg-emerald-500'}`}
                                  style={{ width: `${usagePercent}%` }}
                                />
                              </div>
                            )}
                          </td>
                          <td className="py-3.5 px-3 text-[11px] text-neutral-600">
                            <div>{p.startAt}</div>
                            <div className="text-neutral-400">to {p.endAt}</div>
                          </td>
                          <td className="py-3.5 px-3 text-center">
                            <button
                              type="button"
                              onClick={(e) => handleToggleActive(p.id, e)}
                              className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[11px] font-bold transition cursor-pointer ${
                                p.active
                                  ? 'bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100'
                                  : 'bg-neutral-100 text-neutral-500 border border-neutral-200 hover:bg-neutral-200'
                              }`}
                            >
                              <span
                                className={`size-1.5 rounded-full ${
                                  p.active ? 'bg-emerald-500' : 'bg-neutral-400'
                                }`}
                              />
                              <span>{p.active ? 'Active' : 'Inactive'}</span>
                            </button>
                          </td>
                          <td className="py-3.5 px-4 text-right">
                            <div className="flex items-center justify-end gap-1.5">
                              <button
                                type="button"
                                onClick={() => handleOpenEdit(p)}
                                title="Edit promo"
                                className="rounded-lg p-1.5 text-neutral-500 hover:bg-neutral-100 hover:text-neutral-800 transition cursor-pointer"
                              >
                                <Pencil className="size-3.5" />
                              </button>
                              <button
                                type="button"
                                onClick={(e) => handleDeletePromo(p.id, p.code, e)}
                                title="Delete promo"
                                className="rounded-lg p-1.5 text-neutral-400 hover:bg-rose-50 hover:text-rose-600 transition cursor-pointer"
                              >
                                <Trash2 className="size-3.5" />
                              </button>
                            </div>
                          </td>
                        </tr>
                      )
                    })
                  )}
                </tbody>
              </table>
            </div>

            {/* Table Footer & Dynamic Pagination */}
            <div className="flex flex-wrap items-center justify-between border-t border-neutral-200 bg-[#F9FAFB] px-4 py-3 text-xs text-neutral-500">
              <div className="flex items-center gap-2">
                <span>
                  Showing {filteredPromos.length === 0 ? 0 : (safeCurrentPage - 1) * pageSize + 1}–
                  {Math.min(safeCurrentPage * pageSize, filteredPromos.length)} of {filteredPromos.length} promo codes
                </span>
                <span>•</span>
                <span className="font-mono text-[10px] text-neutral-400">Marketing Ledger: #MKTG-2026-YQL</span>
              </div>

              <div className="flex items-center gap-1">
                <button
                  type="button"
                  disabled={safeCurrentPage <= 1}
                  onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                  className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-100 disabled:opacity-40 disabled:cursor-not-allowed text-xs cursor-pointer"
                >
                  &lt;
                </button>
                {Array.from({ length: totalPages }, (_, idx) => idx + 1).map((pageNum) => (
                  <button
                    key={pageNum}
                    type="button"
                    onClick={() => setCurrentPage(pageNum)}
                    className={`flex size-7 items-center justify-center rounded text-xs cursor-pointer ${
                      pageNum === safeCurrentPage
                        ? 'bg-[#C4161C] text-white font-bold shadow-2xs'
                        : 'border border-neutral-200 bg-white text-neutral-700 hover:bg-neutral-100'
                    }`}
                  >
                    {pageNum}
                  </button>
                ))}
                <button
                  type="button"
                  disabled={safeCurrentPage >= totalPages}
                  onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                  className="flex size-7 items-center justify-center rounded border border-neutral-200 bg-white text-neutral-600 hover:bg-neutral-100 disabled:opacity-40 disabled:cursor-not-allowed text-xs cursor-pointer"
                >
                  &gt;
                </button>
              </div>
            </div>
          </div>
        </main>
      </div>

      {/* Modal Dialog for Create / Edit Promo Code */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="w-full max-w-lg rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
              <div>
                <h3 className="text-base font-bold text-neutral-900">
                  {editingPromoId ? 'Edit Promo Code' : 'Create New Promo Code'}
                </h3>
                <p className="text-xs text-neutral-400 mt-0.5">
                  Set voucher discounts, percentage cuts, usage quotas, and expiry terms.
                </p>
              </div>
              <button
                type="button"
                onClick={() => setIsModalOpen(false)}
                className="rounded-lg p-1 text-neutral-400 hover:bg-neutral-100 hover:text-neutral-700 transition cursor-pointer"
              >
                <X className="size-4" />
              </button>
            </div>

            <form onSubmit={handleSavePromo} className="mt-4 space-y-4">
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-neutral-700 mb-1">Promo Code</label>
                  <input
                    type="text"
                    required
                    placeholder="e.g. SUMMER26"
                    value={formData.code}
                    onChange={(e) => setFormData({ ...formData, code: e.target.value.toUpperCase() })}
                    className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-xs font-mono font-bold text-neutral-900 uppercase focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-neutral-700 mb-1">Discount Type</label>
                  <select
                    value={formData.type}
                    onChange={(e) => setFormData({ ...formData, type: e.target.value as PromoCode['type'] })}
                    className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  >
                    <option value="PERCENT">Percentage (%)</option>
                    <option value="FIXED">Fixed Dollar Amount ($)</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-neutral-700 mb-1">Campaign Description</label>
                <input
                  type="text"
                  placeholder="e.g. 15% off first 3 rides across Lethbridge municipality"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                />
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="block text-[11px] font-semibold text-neutral-600 mb-1">
                    {formData.type === 'PERCENT' ? 'Percentage (%)' : 'Amount ($ CAD)'}
                  </label>
                  <input
                    type="number"
                    step={formData.type === 'PERCENT' ? '1' : '0.50'}
                    min="1"
                    required
                    value={formData.value}
                    onChange={(e) => setFormData({ ...formData, value: e.target.value })}
                    className="w-full rounded-lg border border-neutral-200 px-2.5 py-1.5 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-semibold text-neutral-600 mb-1">Max Discount ($)</label>
                  <input
                    type="number"
                    step="0.50"
                    min="0"
                    value={formData.maxDiscount}
                    onChange={(e) => setFormData({ ...formData, maxDiscount: e.target.value })}
                    className="w-full rounded-lg border border-neutral-200 px-2.5 py-1.5 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-semibold text-neutral-600 mb-1">Min Subtotal ($)</label>
                  <input
                    type="number"
                    step="0.50"
                    min="0"
                    value={formData.minSubtotal}
                    onChange={(e) => setFormData({ ...formData, minSubtotal: e.target.value })}
                    className="w-full rounded-lg border border-neutral-200 px-2.5 py-1.5 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div>
                  <label className="block text-[11px] font-semibold text-neutral-600 mb-1">Usage Limit</label>
                  <input
                    type="number"
                    min="1"
                    placeholder="Unlimited"
                    value={formData.usageLimit}
                    onChange={(e) => setFormData({ ...formData, usageLimit: e.target.value })}
                    className="w-full rounded-lg border border-neutral-200 px-2.5 py-1.5 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-semibold text-neutral-600 mb-1">Start Date</label>
                  <input
                    type="date"
                    required
                    value={formData.startAt}
                    onChange={(e) => setFormData({ ...formData, startAt: e.target.value })}
                    className="w-full rounded-lg border border-neutral-200 px-2.5 py-1.5 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-semibold text-neutral-600 mb-1">End Date</label>
                  <input
                    type="date"
                    required
                    value={formData.endAt}
                    onChange={(e) => setFormData({ ...formData, endAt: e.target.value })}
                    className="w-full rounded-lg border border-neutral-200 px-2.5 py-1.5 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
              </div>

              <div className="flex items-center gap-2 pt-2">
                <input
                  type="checkbox"
                  id="activePromoCheck"
                  checked={formData.active}
                  onChange={(e) => setFormData({ ...formData, active: e.target.checked })}
                  className="rounded border-neutral-300 text-[#C4161C] focus:ring-[#C4161C]"
                />
                <label htmlFor="activePromoCheck" className="text-xs font-semibold text-neutral-700 cursor-pointer">
                  Activate promo code immediately upon creation
                </label>
              </div>

              <div className="flex items-center justify-end gap-2.5 border-t border-neutral-100 pt-4 mt-2">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="rounded-lg border border-neutral-200 bg-white px-4 py-2 text-xs font-semibold text-neutral-700 hover:bg-neutral-50 cursor-pointer"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="rounded-lg bg-[#C4161C] px-4 py-2 text-xs font-bold text-white hover:bg-[#9E1017] shadow-xs cursor-pointer"
                >
                  {editingPromoId ? 'Save Changes' : 'Create Promo Code'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
