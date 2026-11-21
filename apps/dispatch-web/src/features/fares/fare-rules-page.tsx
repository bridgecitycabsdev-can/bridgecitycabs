import {
  AlertCircle,
  ChevronDown,
  Download,
  MapPin,
  Pencil,
  Plus,
  RefreshCw,
  Search,
  Tag,
  Trash2,
  X,
} from 'lucide-react'
import { useState } from 'react'
import { AdminSidebar } from '@/components/AdminSidebar'
import { toast } from '@/components/ui/toast'

export interface FareRule {
  id: string
  code: string
  title: string
  zone: 'DOWNTOWN' | 'AIRPORT' | 'SUBURB' | 'METRO' | 'RURAL'
  vehicleType: string
  baseFareCents: number
  perKmCents: number
  perMinuteCents: number
  minFareCents: number
  active: boolean
  updatedAt: string
}

const DEFAULT_FARE_RULES: FareRule[] = [
  {
    id: 'fr-001',
    code: 'YQL-STD-DT',
    title: 'Standard Meter - Downtown Core',
    zone: 'DOWNTOWN',
    vehicleType: 'Standard Sedan',
    baseFareCents: 380,
    perKmCents: 175,
    perMinuteCents: 45,
    minFareCents: 600,
    active: true,
    updatedAt: '18 Nov 2026',
  },
  {
    id: 'fr-002',
    code: 'YQL-HYB-DT',
    title: 'Hybrid Eco Meter - Lethbridge Central',
    zone: 'DOWNTOWN',
    vehicleType: 'Hybrid',
    baseFareCents: 380,
    perKmCents: 170,
    perMinuteCents: 45,
    minFareCents: 600,
    active: true,
    updatedAt: '15 Nov 2026',
  },
  {
    id: 'fr-003',
    code: 'YQL-WAV-MET',
    title: 'WAV Wheelchair Accessible Tariff',
    zone: 'METRO',
    vehicleType: 'WAV / Accessible',
    baseFareCents: 380,
    perKmCents: 175,
    perMinuteCents: 40,
    minFareCents: 600,
    active: true,
    updatedAt: '10 Nov 2026',
  },
  {
    id: 'fr-004',
    code: 'YQL-AIR-FLT',
    title: 'Lethbridge Airport Flat Corridor',
    zone: 'AIRPORT',
    vehicleType: 'Standard Sedan',
    baseFareCents: 2500,
    perKmCents: 0,
    perMinuteCents: 0,
    minFareCents: 2500,
    active: true,
    updatedAt: '05 Nov 2026',
  },
  {
    id: 'fr-005',
    code: 'YQL-SUB-REG',
    title: 'West Lethbridge & Campus Suburb',
    zone: 'SUBURB',
    vehicleType: 'Standard Sedan',
    baseFareCents: 420,
    perKmCents: 185,
    perMinuteCents: 50,
    minFareCents: 750,
    active: true,
    updatedAt: '01 Nov 2026',
  },
  {
    id: 'fr-006',
    code: 'YQL-RUR-OUT',
    title: 'County Rural Transit Out-of-Zone',
    zone: 'RURAL',
    vehicleType: 'Premium SUV',
    baseFareCents: 600,
    perKmCents: 220,
    perMinuteCents: 60,
    minFareCents: 1200,
    active: false,
    updatedAt: '20 Oct 2026',
  },
  {
    id: 'fr-007',
    code: 'YQL-SUV-PRM',
    title: 'Executive Fleet Surcharge',
    zone: 'METRO',
    vehicleType: 'Premium SUV',
    baseFareCents: 550,
    perKmCents: 210,
    perMinuteCents: 55,
    minFareCents: 1000,
    active: true,
    updatedAt: '12 Oct 2026',
  },
  {
    id: 'fr-008',
    code: 'YQL-AIR-WAV',
    title: 'Airport Corridor Accessible Van',
    zone: 'AIRPORT',
    vehicleType: 'WAV / Accessible',
    baseFareCents: 2500,
    perKmCents: 0,
    perMinuteCents: 0,
    minFareCents: 2500,
    active: true,
    updatedAt: '08 Oct 2026',
  },
]

export function FareRulesPage() {
  const [rules, setRules] = useState<FareRule[]>(DEFAULT_FARE_RULES)
  const [searchQuery, setSearchQuery] = useState('')
  const [zoneFilter, setZoneFilter] = useState('ALL')
  const [vehicleFilter, setVehicleFilter] = useState('ALL')
  const [statusFilter, setStatusFilter] = useState('ALL')
  const [currentPage, setCurrentPage] = useState(1)
  const pageSize = 5

  // Form modal state
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [editingRuleId, setEditingRuleId] = useState<string | null>(null)
  const [formData, setFormData] = useState({
    title: '',
    code: '',
    zone: 'DOWNTOWN' as FareRule['zone'],
    vehicleType: 'Standard Sedan',
    baseFare: '3.80',
    perKm: '1.75',
    perMinute: '0.45',
    minFare: '6.00',
    active: true,
  })

  // Filter calculation
  const filteredRules = rules.filter((r) => {
    if (zoneFilter !== 'ALL' && r.zone !== zoneFilter) return false
    if (vehicleFilter !== 'ALL' && r.vehicleType !== vehicleFilter) return false
    if (statusFilter === 'ACTIVE' && !r.active) return false
    if (statusFilter === 'INACTIVE' && r.active) return false

    if (searchQuery.trim()) {
      const q = searchQuery.toLowerCase()
      return (
        r.title.toLowerCase().includes(q) ||
        r.code.toLowerCase().includes(q) ||
        r.vehicleType.toLowerCase().includes(q) ||
        r.zone.toLowerCase().includes(q)
      )
    }
    return true
  })

  const totalPages = Math.max(1, Math.ceil(filteredRules.length / pageSize))
  const safeCurrentPage = Math.min(currentPage, totalPages)
  const pagedRules = filteredRules.slice(
    (safeCurrentPage - 1) * pageSize,
    safeCurrentPage * pageSize,
  )

  const activeCount = rules.filter((r) => r.active).length

  // Handlers
  const handleOpenCreate = () => {
    setEditingRuleId(null)
    setFormData({
      title: '',
      code: `YQL-${Math.floor(100 + Math.random() * 900)}`,
      zone: 'DOWNTOWN',
      vehicleType: 'Standard Sedan',
      baseFare: '3.80',
      perKm: '1.75',
      perMinute: '0.45',
      minFare: '6.00',
      active: true,
    })
    setIsModalOpen(true)
  }

  const handleOpenEdit = (rule: FareRule) => {
    setEditingRuleId(rule.id)
    setFormData({
      title: rule.title,
      code: rule.code,
      zone: rule.zone,
      vehicleType: rule.vehicleType,
      baseFare: (rule.baseFareCents / 100).toFixed(2),
      perKm: (rule.perKmCents / 100).toFixed(2),
      perMinute: (rule.perMinuteCents / 100).toFixed(2),
      minFare: (rule.minFareCents / 100).toFixed(2),
      active: rule.active,
    })
    setIsModalOpen(true)
  }

  const handleSaveRule = (e: React.FormEvent) => {
    e.preventDefault()
    if (!formData.title.trim()) {
      toast.error('Validation Error', 'Please enter a rule title.')
      return
    }

    const baseCents = Math.round(parseFloat(formData.baseFare || '0') * 100)
    const kmCents = Math.round(parseFloat(formData.perKm || '0') * 100)
    const minCents = Math.round(parseFloat(formData.perMinute || '0') * 100)
    const minimumCents = Math.round(parseFloat(formData.minFare || '0') * 100)

    if (editingRuleId) {
      setRules((prev) =>
        prev.map((r) =>
          r.id === editingRuleId
            ? {
                ...r,
                title: formData.title,
                code: formData.code,
                zone: formData.zone,
                vehicleType: formData.vehicleType,
                baseFareCents: baseCents,
                perKmCents: kmCents,
                perMinuteCents: minCents,
                minFareCents: minimumCents,
                active: formData.active,
                updatedAt: 'Just now',
              }
            : r,
        ),
      )
      toast.success('Fare Rule Updated', `Rule "${formData.title}" was updated successfully.`)
    } else {
      const newRule: FareRule = {
        id: `fr-${Date.now()}`,
        code: formData.code,
        title: formData.title,
        zone: formData.zone,
        vehicleType: formData.vehicleType,
        baseFareCents: baseCents,
        perKmCents: kmCents,
        perMinuteCents: minCents,
        minFareCents: minimumCents,
        active: formData.active,
        updatedAt: 'Just now',
      }
      setRules((prev) => [newRule, ...prev])
      toast.success('Fare Rule Created', `Rule "${formData.title}" added to tariff schedule.`)
    }

    setIsModalOpen(false)
  }

  const handleToggleActive = (id: string, e: React.MouseEvent) => {
    e.stopPropagation()
    setRules((prev) =>
      prev.map((r) => {
        if (r.id === id) {
          const nextState = !r.active
          toast.info(
            nextState ? 'Rule Activated' : 'Rule Deactivated',
            `${r.title} is now ${nextState ? 'active' : 'inactive'}.`,
          )
          return { ...r, active: nextState, updatedAt: 'Just now' }
        }
        return r
      }),
    )
  }

  const handleDeleteRule = (id: string, title: string, e: React.MouseEvent) => {
    e.stopPropagation()
    if (confirm(`Are you sure you want to delete fare rule "${title}"?`)) {
      setRules((prev) => prev.filter((r) => r.id !== id))
      toast.error('Rule Removed', `Fare rule "${title}" was deleted.`)
    }
  }

  const handleExportCSV = () => {
    const headers = ['Code', 'Title', 'Zone', 'Vehicle Type', 'Base ($)', 'Per Km ($)', 'Per Min ($)', 'Min Fare ($)', 'Status']
    const rows = filteredRules.map((r) => [
      r.code,
      `"${r.title}"`,
      r.zone,
      `"${r.vehicleType}"`,
      (r.baseFareCents / 100).toFixed(2),
      (r.perKmCents / 100).toFixed(2),
      (r.perMinuteCents / 100).toFixed(2),
      (r.minFareCents / 100).toFixed(2),
      r.active ? 'ACTIVE' : 'INACTIVE',
    ])
    const csvContent = 'data:text/csv;charset=utf-8,' + [headers.join(','), ...rows.map((e) => e.join(','))].join('\n')
    const encodedUri = encodeURI(csvContent)
    const link = document.createElement('a')
    link.setAttribute('href', encodedUri)
    link.setAttribute('download', `fare-rules-${new Date().toISOString().slice(0, 10)}.csv`)
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    toast.success('Export Complete', 'Fare rules exported to CSV.')
  }

  const handleResetFilters = () => {
    setSearchQuery('')
    setZoneFilter('ALL')
    setVehicleFilter('ALL')
    setStatusFilter('ALL')
    setCurrentPage(1)
  }

  return (
    <div className="flex h-screen w-screen overflow-hidden bg-[#F3F4F6] text-neutral-900 font-sans antialiased">
      <AdminSidebar activeSection="fare-rules" subtitle="Lethbridge Branch (YQL)" />

      <div className="flex flex-1 flex-col overflow-hidden">
        {/* Top Header Bar */}
        <header className="flex h-14 shrink-0 items-center justify-between border-b border-neutral-200/90 bg-white px-4 lg:px-6 shadow-xs z-20">
          <div className="flex items-center gap-2">
            <span className="text-xs text-neutral-400 font-medium">Pricing &gt;</span>
            <span className="text-xs font-bold text-neutral-800">Fare rules</span>
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
                <h1 className="text-2xl font-black tracking-tight text-neutral-900">Fare rules</h1>
                <span className="rounded-full bg-neutral-200 px-2.5 py-0.5 text-xs font-bold text-neutral-700">
                  {rules.length} tariffs
                </span>
                <span className="rounded-full border border-emerald-200 bg-emerald-50 px-2.5 py-0.5 text-xs font-semibold text-emerald-700">
                  {activeCount} Active
                </span>
              </div>
              <p className="mt-1 text-xs text-neutral-500">
                Municipal metered rates, zone tariffs, vehicle surcharges, and minimum fare policies.
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
                <span>+ New fare rule</span>
              </button>
            </div>
          </div>

          {/* KPI Summary Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <div className="rounded-xl border border-neutral-200/90 bg-white p-4 shadow-xs">
              <div className="flex items-center justify-between text-neutral-500 text-xs font-medium">
                <span>Active Tariff Count</span>
                <Tag className="size-4 text-[#C4161C]" />
              </div>
              <div className="mt-2 text-2xl font-black text-neutral-900">{activeCount}</div>
              <div className="mt-1 text-[11px] text-neutral-400">Of {rules.length} total municipal schedules</div>
            </div>

            <div className="rounded-xl border border-neutral-200/90 bg-white p-4 shadow-xs">
              <div className="flex items-center justify-between text-neutral-500 text-xs font-medium">
                <span>Base Flag Drop</span>
                <span className="text-xs font-bold text-emerald-600">Standard</span>
              </div>
              <div className="mt-2 text-2xl font-black text-neutral-900">$3.80 <span className="text-xs font-semibold text-neutral-400">CAD</span></div>
              <div className="mt-1 text-[11px] text-neutral-400">Lethbridge City Bylaw #6205</div>
            </div>

            <div className="rounded-xl border border-neutral-200/90 bg-white p-4 shadow-xs">
              <div className="flex items-center justify-between text-neutral-500 text-xs font-medium">
                <span>Average Distance Rate</span>
                <span className="text-xs font-bold text-neutral-600">Per Km</span>
              </div>
              <div className="mt-2 text-2xl font-black text-neutral-900">$1.75 <span className="text-xs font-semibold text-neutral-400">CAD</span></div>
              <div className="mt-1 text-[11px] text-neutral-400">Computed across sedan and hybrid</div>
            </div>

            <div className="rounded-xl border border-neutral-200/90 bg-white p-4 shadow-xs">
              <div className="flex items-center justify-between text-neutral-500 text-xs font-medium">
                <span>Airport Fixed Flat</span>
                <span className="text-xs font-bold text-blue-600">Direct</span>
              </div>
              <div className="mt-2 text-2xl font-black text-neutral-900">$25.00 <span className="text-xs font-semibold text-neutral-400">CAD</span></div>
              <div className="mt-1 text-[11px] text-neutral-400">YQL Terminal Corridor</div>
            </div>
          </div>

          {/* Search & Filter Bar */}
          <div className="flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between rounded-xl border border-neutral-200/90 bg-white p-3 shadow-xs">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-4 text-neutral-400" />
              <input
                type="text"
                placeholder="Search rule title, zone, code, or vehicle type..."
                value={searchQuery}
                onChange={(e) => {
                  setSearchQuery(e.target.value)
                  setCurrentPage(1)
                }}
                className="w-full rounded-lg border border-neutral-200 bg-neutral-50/50 pl-9 pr-3 py-2 text-xs text-neutral-800 placeholder-neutral-400 focus:border-[#C4161C] focus:bg-white focus:outline-none"
              />
            </div>

            <div className="flex flex-wrap items-center gap-2 text-xs">
              {/* Zone Filter */}
              <select
                aria-label="Filter by zone"
                value={zoneFilter}
                onChange={(e) => {
                  setZoneFilter(e.target.value)
                  setCurrentPage(1)
                }}
                className="rounded-lg border border-neutral-200 bg-white px-2.5 py-2 text-xs font-medium text-neutral-700 focus:border-[#C4161C] focus:outline-none"
              >
                <option value="ALL">All Zones</option>
                <option value="DOWNTOWN">Downtown</option>
                <option value="AIRPORT">Airport</option>
                <option value="SUBURB">Suburb</option>
                <option value="METRO">Metro</option>
                <option value="RURAL">Rural</option>
              </select>

              {/* Vehicle Type Filter */}
              <select
                aria-label="Filter by vehicle type"
                value={vehicleFilter}
                onChange={(e) => {
                  setVehicleFilter(e.target.value)
                  setCurrentPage(1)
                }}
                className="rounded-lg border border-neutral-200 bg-white px-2.5 py-2 text-xs font-medium text-neutral-700 focus:border-[#C4161C] focus:outline-none"
              >
                <option value="ALL">All Vehicles</option>
                <option value="Standard Sedan">Standard Sedan</option>
                <option value="Hybrid">Hybrid</option>
                <option value="WAV / Accessible">WAV / Accessible</option>
                <option value="Premium SUV">Premium SUV</option>
              </select>

              {/* Status Filter */}
              <select
                aria-label="Filter by status"
                value={statusFilter}
                onChange={(e) => {
                  setStatusFilter(e.target.value)
                  setCurrentPage(1)
                }}
                className="rounded-lg border border-neutral-200 bg-white px-2.5 py-2 text-xs font-medium text-neutral-700 focus:border-[#C4161C] focus:outline-none"
              >
                <option value="ALL">All Statuses</option>
                <option value="ACTIVE">Active Only</option>
                <option value="INACTIVE">Inactive</option>
              </select>

              {(searchQuery || zoneFilter !== 'ALL' || vehicleFilter !== 'ALL' || statusFilter !== 'ALL') && (
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

          {/* Fare Rules Data Table */}
          <div className="overflow-hidden rounded-2xl border border-neutral-200/90 bg-white shadow-xs">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse text-xs">
                <thead>
                  <tr className="border-b border-neutral-200 bg-[#F9FAFB] text-[10px] font-bold text-neutral-500 uppercase tracking-wider">
                    <th className="py-3 px-4">RULE TITLE &amp; CODE</th>
                    <th className="py-3 px-3">ZONE</th>
                    <th className="py-3 px-3">VEHICLE TYPE</th>
                    <th className="py-3 px-3 text-right">FLAG DROP</th>
                    <th className="py-3 px-3 text-right">PER KM</th>
                    <th className="py-3 px-3 text-right">PER MIN</th>
                    <th className="py-3 px-3 text-right">MIN FARE</th>
                    <th className="py-3 px-3 text-center">STATUS</th>
                    <th className="py-3 px-4 text-right">ACTIONS</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-neutral-100 font-medium">
                  {pagedRules.length === 0 ? (
                    <tr>
                      <td colSpan={9} className="py-12 text-center text-neutral-400">
                        <AlertCircle className="mx-auto size-8 text-neutral-300 mb-2" />
                        <div>No fare rules matched your filters.</div>
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
                    pagedRules.map((r) => (
                      <tr key={r.id} className="hover:bg-neutral-50/80 transition">
                        <td className="py-3.5 px-4">
                          <div className="font-bold text-neutral-900">{r.title}</div>
                          <div className="font-mono text-[10px] text-neutral-400 mt-0.5">{r.code}</div>
                        </td>
                        <td className="py-3.5 px-3">
                          <span
                            className={`inline-block rounded-md px-2 py-0.5 text-[10px] font-bold ${
                              r.zone === 'DOWNTOWN'
                                ? 'bg-blue-50 text-blue-700 border border-blue-200'
                                : r.zone === 'AIRPORT'
                                ? 'bg-amber-50 text-amber-700 border border-amber-200'
                                : r.zone === 'METRO'
                                ? 'bg-purple-50 text-purple-700 border border-purple-200'
                                : 'bg-neutral-100 text-neutral-700'
                            }`}
                          >
                            {r.zone}
                          </span>
                        </td>
                        <td className="py-3.5 px-3 text-neutral-700 font-semibold">{r.vehicleType}</td>
                        <td className="py-3.5 px-3 text-right font-bold text-neutral-900">
                          ${(r.baseFareCents / 100).toFixed(2)}
                        </td>
                        <td className="py-3.5 px-3 text-right font-medium text-neutral-700">
                          ${(r.perKmCents / 100).toFixed(2)}
                        </td>
                        <td className="py-3.5 px-3 text-right font-medium text-neutral-700">
                          ${(r.perMinuteCents / 100).toFixed(2)}
                        </td>
                        <td className="py-3.5 px-3 text-right font-bold text-neutral-900">
                          ${(r.minFareCents / 100).toFixed(2)}
                        </td>
                        <td className="py-3.5 px-3 text-center">
                          <button
                            type="button"
                            onClick={(e) => handleToggleActive(r.id, e)}
                            className={`inline-flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[11px] font-bold transition cursor-pointer ${
                              r.active
                                ? 'bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100'
                                : 'bg-neutral-100 text-neutral-500 border border-neutral-200 hover:bg-neutral-200'
                            }`}
                          >
                            <span
                              className={`size-1.5 rounded-full ${
                                r.active ? 'bg-emerald-500' : 'bg-neutral-400'
                              }`}
                            />
                            <span>{r.active ? 'Active' : 'Inactive'}</span>
                          </button>
                        </td>
                        <td className="py-3.5 px-4 text-right">
                          <div className="flex items-center justify-end gap-1.5">
                            <button
                              type="button"
                              onClick={() => handleOpenEdit(r)}
                              title="Edit tariff"
                              className="rounded-lg p-1.5 text-neutral-500 hover:bg-neutral-100 hover:text-neutral-800 transition cursor-pointer"
                            >
                              <Pencil className="size-3.5" />
                            </button>
                            <button
                              type="button"
                              onClick={(e) => handleDeleteRule(r.id, r.title, e)}
                              title="Delete tariff"
                              className="rounded-lg p-1.5 text-neutral-400 hover:bg-rose-50 hover:text-rose-600 transition cursor-pointer"
                            >
                              <Trash2 className="size-3.5" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>

            {/* Table Footer & Dynamic Pagination */}
            <div className="flex flex-wrap items-center justify-between border-t border-neutral-200 bg-[#F9FAFB] px-4 py-3 text-xs text-neutral-500">
              <div className="flex items-center gap-2">
                <span>
                  Showing {filteredRules.length === 0 ? 0 : (safeCurrentPage - 1) * pageSize + 1}–
                  {Math.min(safeCurrentPage * pageSize, filteredRules.length)} of {filteredRules.length} fare rules
                </span>
                <span>•</span>
                <span className="font-mono text-[10px] text-neutral-400">Tariff Ledger: #YQL-FARES-2026</span>
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

      {/* Modal Dialog for Create / Edit Fare Rule */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs p-4">
          <div className="w-full max-w-lg rounded-2xl border border-neutral-200 bg-white p-6 shadow-2xl animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
              <div>
                <h3 className="text-base font-bold text-neutral-900">
                  {editingRuleId ? 'Edit Fare Rule' : 'Create New Fare Rule'}
                </h3>
                <p className="text-xs text-neutral-400 mt-0.5">
                  Configure municipal tariff boundaries, flag drop, and kilometer meters.
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

            <form onSubmit={handleSaveRule} className="mt-4 space-y-4">
              <div>
                <label className="block text-xs font-semibold text-neutral-700 mb-1">Rule Title</label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Standard Meter - Downtown Core"
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-neutral-700 mb-1">Tariff Code</label>
                  <input
                    type="text"
                    required
                    value={formData.code}
                    onChange={(e) => setFormData({ ...formData, code: e.target.value })}
                    className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-xs text-neutral-900 font-mono focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-neutral-700 mb-1">Zone</label>
                  <select
                    value={formData.zone}
                    onChange={(e) => setFormData({ ...formData, zone: e.target.value as FareRule['zone'] })}
                    className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  >
                    <option value="DOWNTOWN">DOWNTOWN</option>
                    <option value="AIRPORT">AIRPORT</option>
                    <option value="SUBURB">SUBURB</option>
                    <option value="METRO">METRO</option>
                    <option value="RURAL">RURAL</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-neutral-700 mb-1">Vehicle Type</label>
                <select
                  value={formData.vehicleType}
                  onChange={(e) => setFormData({ ...formData, vehicleType: e.target.value })}
                  className="w-full rounded-lg border border-neutral-200 px-3 py-2 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                >
                  <option value="Standard Sedan">Standard Sedan</option>
                  <option value="Hybrid">Hybrid</option>
                  <option value="WAV / Accessible">WAV / Accessible</option>
                  <option value="Premium SUV">Premium SUV</option>
                </select>
              </div>

              <div className="grid grid-cols-2 sm:grid-cols-4 gap-2.5">
                <div>
                  <label className="block text-[11px] font-semibold text-neutral-600 mb-1">Flag Drop ($)</label>
                  <input
                    type="number"
                    step="0.05"
                    min="0"
                    required
                    value={formData.baseFare}
                    onChange={(e) => setFormData({ ...formData, baseFare: e.target.value })}
                    className="w-full rounded-lg border border-neutral-200 px-2.5 py-1.5 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-semibold text-neutral-600 mb-1">Per Km ($)</label>
                  <input
                    type="number"
                    step="0.05"
                    min="0"
                    required
                    value={formData.perKm}
                    onChange={(e) => setFormData({ ...formData, perKm: e.target.value })}
                    className="w-full rounded-lg border border-neutral-200 px-2.5 py-1.5 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-semibold text-neutral-600 mb-1">Per Min ($)</label>
                  <input
                    type="number"
                    step="0.05"
                    min="0"
                    required
                    value={formData.perMinute}
                    onChange={(e) => setFormData({ ...formData, perMinute: e.target.value })}
                    className="w-full rounded-lg border border-neutral-200 px-2.5 py-1.5 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-[11px] font-semibold text-neutral-600 mb-1">Min Fare ($)</label>
                  <input
                    type="number"
                    step="0.05"
                    min="0"
                    required
                    value={formData.minFare}
                    onChange={(e) => setFormData({ ...formData, minFare: e.target.value })}
                    className="w-full rounded-lg border border-neutral-200 px-2.5 py-1.5 text-xs text-neutral-900 focus:border-[#C4161C] focus:outline-none"
                  />
                </div>
              </div>

              <div className="flex items-center gap-2 pt-2">
                <input
                  type="checkbox"
                  id="activeCheck"
                  checked={formData.active}
                  onChange={(e) => setFormData({ ...formData, active: e.target.checked })}
                  className="rounded border-neutral-300 text-[#C4161C] focus:ring-[#C4161C]"
                />
                <label htmlFor="activeCheck" className="text-xs font-semibold text-neutral-700 cursor-pointer">
                  Activate tariff immediately upon save
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
                  {editingRuleId ? 'Save Changes' : 'Create Fare Rule'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  )
}
